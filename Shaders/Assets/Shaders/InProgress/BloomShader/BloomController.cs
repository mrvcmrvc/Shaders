using System;
using UnityEngine;
using UnityEngine.Rendering;

public class BloomController : MonoBehaviour
{
    [SerializeField]
    private Shader bloomShader;
    
    [SerializeField]
    private Camera mainCamera;
    
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    [SerializeField, Range(1f, 10f)]
    private float threshold = 1;

    [SerializeField, Range(0f, 1f)]
    private float softThreshold = 0.5f;
    
    [SerializeField, Range(0, 10)]
    private float intensity = 1;
    
    private CommandBuffer bloomCommandBuffer;
    private bool isBloomActive;
    public bool IsBloomActive => isBloomActive;
    
    private Material bloomMaterial;

    private const int preFilterPass = 1;
    private const int downScalePass = 2;
    private const int upScalePass = 3;
    private const int bloomPass = 0;

    private static readonly int filterID = Shader.PropertyToID("_Filter");
    private static readonly int sourceTexID = Shader.PropertyToID("_SourceTex");
    private static readonly int intensityID = Shader.PropertyToID("_Intensity");

    private void Awake()
    {
        bloomCommandBuffer = new CommandBuffer();

        bloomMaterial = new Material(bloomShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    private void OnEnable()
    {
        RenderBloom();
    }

    private void OnDisable()
    {
        ClearBloom();
    }

    private void OnDestroy()
    {
        ClearBloom();
    }

    public void SetActive(bool activate)
    {
        if (activate)
            RenderBloom();
        else
            ClearBloom();
    }

    private void Update()
    {
        if(!isBloomActive)
            return;
        
        bloomMaterial.SetFloat(intensityID, Mathf.GammaToLinearSpace(intensity));
        bloomMaterial.SetVector(filterID, GetFilter());
    }

    private void RenderBloom()
    {
        if(isBloomActive)
            return;
        
        isBloomActive = true;
        mainCamera.forceIntoRenderTexture = true;

        DownScale();
        UpScale();
        
        BlitBlurredTextureToBuffer();
        
        mainCamera.AddCommandBuffer(CameraEvent.AfterForwardAlpha, bloomCommandBuffer);
    }

    private Vector4 GetFilter()
    {
        float knee = threshold * softThreshold;
        Vector4 filter;
        filter.x = threshold;
        filter.y = filter.x - knee;
        filter.z = 2f * knee;
        filter.w = 0.25f / (knee + 0.00001f);

        return filter;
    }

    private void ClearBloom()
    {
        if(!isBloomActive)
            return;
        
        if(mainCamera == null)
            return;
        
        isBloomActive = false;
        mainCamera.forceIntoRenderTexture = false;

        bloomCommandBuffer.Clear();

        mainCamera.RemoveAllCommandBuffers();
    }

    private void DownScale()
    {
        int width = Screen.width;
        int height = Screen.height;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        bloomCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        bloomCommandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, dest, bloomMaterial, preFilterPass);
        
        int currentIterationIndex = 1;
        int src = dest;
        for (; currentIterationIndex < downScaleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;
        
            dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");
            
            bloomCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
            bloomCommandBuffer.Blit(src, dest, bloomMaterial, downScalePass);

            src = dest;
        }
    }
    
    private void UpScale()
    {
        int currentIterationIndex = downScaleCount - 2;
        int previousDestination = downScaleCount - 1;

        for (; currentIterationIndex >= 0; currentIterationIndex--)
        {
            int src = Shader.PropertyToID($"currentDestination_{previousDestination}");
            int dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");

            bloomCommandBuffer.Blit(src, dest, bloomMaterial, upScalePass);
            
            bloomCommandBuffer.ReleaseTemporaryRT(previousDestination);
            previousDestination = currentIterationIndex;
        }
    }

    private void BlitBlurredTextureToBuffer()
    {
        bloomCommandBuffer.SetGlobalTexture(sourceTexID, BuiltinRenderTextureType.CameraTarget);

        int src = Shader.PropertyToID($"currentDestination_{0}");
        bloomCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, bloomMaterial, bloomPass);
    }
}
