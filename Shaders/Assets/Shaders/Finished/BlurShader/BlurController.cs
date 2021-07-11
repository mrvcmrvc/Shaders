using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class BlurController : MonoBehaviour
{    
    [SerializeField]
    private Shader blurShader;
    
    [SerializeField]
    private Camera exclusionCamera;
    public Camera ExclusionCamera => exclusionCamera;
        
    [SerializeField, Range(0, 16)]
    private int downScaleCount = 2;

    [SerializeField, Range(0f, 1f)]
    private float resolutionScaling = 0.5f;
    
    [SerializeField]
    private float transitionDuration = 0.1f;

    private CommandBuffer blurCommandBuffer;
    private Material blurMaterial;
    private Camera mainCamera;
    private Coroutine transitionCoroutine;
    private Vector2Int startingResolution;
    
    private const int downScalePass = 0;
    private const int upScalePass = 1;
    
    private static readonly int ORIGINAL_TEXTURE_ID = Shader.PropertyToID("_OriginalTexture");
    private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
    
    public const string ExclusionLayerName = "BlurExclusion";
    private const string bufferName = "Blur Buffer";
    private const CameraEvent cameraEvent = CameraEvent.AfterForwardAlpha;
    
    private void OnEnable()
    {
        if(blurCommandBuffer != null)
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

        if (activate)
            enabled = true;

        if (transitionCoroutine != null)
            StopCoroutine(transitionCoroutine);
        
        transitionCoroutine = StartCoroutine(IntensityEnumerator(activate ? 1f : 0f, isInstant ? Mathf.Epsilon : transitionDuration));
    }
    
    private IEnumerator IntensityEnumerator(float targetIntensity, float transitionDuration)
    {
        float passedDuration = 0f;
        while (passedDuration <= transitionDuration)
        {
            float newIntensity = Mathf.Lerp(1 - targetIntensity, targetIntensity, passedDuration / transitionDuration);
            passedDuration += Time.deltaTime;

            blurMaterial.SetFloat(INTENSITY_ID, newIntensity);
            
            yield return null;
        }
        
        blurMaterial.SetFloat(INTENSITY_ID, targetIntensity);

        if (Mathf.Approximately(targetIntensity, 0f))
            enabled = false;

        transitionCoroutine = null;
    }
    
    private void Startup()
    {
        Initialize();
        
        RenderBlur();
    }

    private void Initialize()
    {
        mainCamera = Camera.main;
        
        blurCommandBuffer = new CommandBuffer
        {
            name = bufferName
        };
        
        blurMaterial = new Material(blurShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
        
        startingResolution = new Vector2Int(
            Mathf.RoundToInt(Screen.width * resolutionScaling), 
            Mathf.RoundToInt(Screen.height * resolutionScaling));
    }

    private void RenderBlur()
    {
        SetCameraRenderTextureAsGlobal();

        AddCameraRenderTextureToBuffer();
        
        DownScale();
        UpScale();
        
        BlitBlurredTextureToBuffer();
        BlitExcludedCameraToBuffer();
        
        mainCamera.AddCommandBuffer(cameraEvent, blurCommandBuffer);
        
        blurMaterial.SetFloat(INTENSITY_ID, 1f);
    }

    private void Cleanup()
    {
        DestroyImmediate(blurMaterial);

        if(blurCommandBuffer == null)
            return;
        
        if(mainCamera != null)
            mainCamera.RemoveCommandBuffer(cameraEvent, blurCommandBuffer);
        
        blurCommandBuffer.Clear();
        blurCommandBuffer = null;
    }

    private void DownScale()
    {
        int width = startingResolution.x;
        int height = startingResolution.y;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        int src = dest;

        for (int currentIterationIndex = 1; currentIterationIndex <= downScaleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;
        
            dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");
            
            blurCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.DefaultHDR);
            blurCommandBuffer.Blit(src, dest, blurMaterial, downScalePass);

            src = dest;
        }
    }
    
    private void UpScale()
    {
        int currentIterationIndex = downScaleCount - 1;
        int previousDestination = downScaleCount;

        for (; currentIterationIndex >= 0; currentIterationIndex--)
        {
            int src = Shader.PropertyToID($"currentDestination_{previousDestination}");
            int dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");

            blurCommandBuffer.Blit(src, dest, blurMaterial, upScalePass);
            blurCommandBuffer.ReleaseTemporaryRT(src);
            
            previousDestination = currentIterationIndex;
        } 
    }

    private void BlitBlurredTextureToBuffer()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget);
    }

    private void BlitExcludedCameraToBuffer()
    {
        blurCommandBuffer.Blit(exclusionCamera.targetTexture, BuiltinRenderTextureType.CameraTarget);
    }

    private void AddCameraRenderTextureToBuffer()
    {
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.GetTemporaryRT(dest, startingResolution.x, startingResolution.y, 0, FilterMode.Bilinear, RenderTextureFormat.DefaultHDR);
        blurCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, dest, blurMaterial, downScalePass);
    }
    
    private void SetCameraRenderTextureAsGlobal()
    {
        blurCommandBuffer.SetGlobalTexture(ORIGINAL_TEXTURE_ID, BuiltinRenderTextureType.CameraTarget);
    }
}
