using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class OuterGlowController : MonoBehaviour
{
    [SerializeField]
    private Shader outerGlowShader;
    
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    [SerializeField]
    private float transitionDuration;
    
    [Header("Threshold Settings"), SerializeField, Range(1f, 10f)]
    private float threshold = 1;

    [SerializeField, Range(0f, 1f)]
    private float softThreshold = 0.5f;
    
    [SerializeField, Range(0, 10)]
    private float intensity = 1;
    
    private CommandBuffer outerGlowCommandBuffer;
    private Material outerGlowMaterial;
    private Camera mainCamera;
    private Coroutine transitionCoroutine;

    private const int preFilterPass = 1;
    private const int downScalePass = 2;
    private const int upScalePass = 3;
    private const int outerGlowPass = 0;

    private static readonly int FILTER_ID = Shader.PropertyToID("_Filter");
    private static readonly int ORIGINAL_TEXTURE_ID = Shader.PropertyToID("_OriginalTexture");
    private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
    private const string BUFFER_NAME = "Outer Glow Buffer";
    private const CameraEvent CAMERA_EVENT = CameraEvent.AfterForwardAlpha;

    private void OnEnable()
    {
        if(outerGlowCommandBuffer != null)
            return;

        Startup();
    }

    private void OnDisable()
    {
        Cleanup();
    }

    public void SetActive(bool activate, bool isInstant = false)
    {
        if(enabled == activate)
            return;
        
        if(activate)
            enabled = true;

        if (transitionCoroutine != null)
        {
            StopCoroutine(transitionCoroutine);
            transitionCoroutine = null;
        }
        
        StartCoroutine(IntensityEnumerator(activate ? intensity : 0f, isInstant ? Mathf.Epsilon : transitionDuration));
    }
    
    private IEnumerator IntensityEnumerator(float targetIntensity, float transitionDuration)
    {
        float passedDuration = 0f;
        while (passedDuration <= transitionDuration)
        {
            float newIntensity = Mathf.Lerp(intensity - targetIntensity, targetIntensity, passedDuration / transitionDuration);
            passedDuration += Time.deltaTime;

            outerGlowMaterial.SetFloat(INTENSITY_ID, newIntensity);
            
            yield return null;
        }

        if (targetIntensity == 0f)
            enabled = false;
    }
    
    private void Startup()
    {
        Initialize();
        
        RenderOuterGlow();
    }

    private void Update()
    {
        if (outerGlowCommandBuffer == null)
            return;
        
        UpdateShaderProperties();
    }

    private void UpdateShaderProperties()
    {
        outerGlowMaterial.SetFloat(INTENSITY_ID, Mathf.GammaToLinearSpace(intensity));
        outerGlowMaterial.SetVector(FILTER_ID, GetFilter());
    }

    private void Initialize()
    {
        mainCamera = Camera.main;
        
        outerGlowCommandBuffer = new CommandBuffer
        {
            name = BUFFER_NAME
        };
        
        outerGlowMaterial = new Material(outerGlowShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    private void RenderOuterGlow()
    {
        SetCameraRenderTextureAsGlobal();
        
        DownScale();
        UpScale();
        
        BlitBlurredTextureToBuffer();
        
        mainCamera.AddCommandBuffer(CAMERA_EVENT, outerGlowCommandBuffer);
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

    private void Cleanup()
    {
        DestroyImmediate(outerGlowMaterial);

        if(outerGlowCommandBuffer == null)
            return;
        
        if(mainCamera != null)            
            mainCamera.RemoveCommandBuffer(CAMERA_EVENT, outerGlowCommandBuffer);
 
        outerGlowCommandBuffer.Clear();
        outerGlowCommandBuffer = null;
    }

    private void DownScale()
    {
        int width = Screen.width;
        int height = Screen.height;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        outerGlowCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        outerGlowCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, dest, outerGlowMaterial, preFilterPass);
        
        int currentIterationIndex = 1;
        int src = dest;
        for (; currentIterationIndex < downScaleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;
        
            dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");
            
            outerGlowCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
            outerGlowCommandBuffer.Blit(src, dest, outerGlowMaterial, downScalePass);

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

            outerGlowCommandBuffer.Blit(src, dest, outerGlowMaterial, upScalePass);
            
            outerGlowCommandBuffer.ReleaseTemporaryRT(previousDestination);
            previousDestination = currentIterationIndex;
        }
    }
    
    private void SetCameraRenderTextureAsGlobal()
    {
        outerGlowCommandBuffer.SetGlobalTexture(ORIGINAL_TEXTURE_ID, BuiltinRenderTextureType.CameraTarget);
    }

    private void BlitBlurredTextureToBuffer()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        outerGlowCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, outerGlowMaterial, outerGlowPass);
    }
}
