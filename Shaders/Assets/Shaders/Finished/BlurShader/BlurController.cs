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
        
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    [SerializeField]
    private float transitionDuration;

    private CommandBuffer blurCommandBuffer;
    private Material blurMaterial;
    private Camera mainCamera;
    private Coroutine transitionCoroutine;
    
    private const int downScalePass = 0;
    private const int upScalePass = 1;
    
    public const string EXCLUSION_LAYER_NAME = "BlurExclusion";
    private static readonly int ORIGINAL_TEXTURE_ID = Shader.PropertyToID("_OriginalTexture");
    private static readonly int BLURRED_TEXTURE_ID = Shader.PropertyToID("_BlurredTexture");
    private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
    private const string BUFFER_NAME = "Blur Buffer";
    private const CameraEvent CAMERA_EVENT = CameraEvent.AfterForwardAlpha;
    
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
        {
            StopCoroutine(transitionCoroutine);
            transitionCoroutine = null;
        }
        
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

        if (targetIntensity == 0f)
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
            name = BUFFER_NAME
        };
        
        blurMaterial = new Material(blurShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    private void RenderBlur()
    {
        SetCameraRenderTextureAsGlobal();

        AddCameraRenderTextureToBuffer();
        
        DownScale();
        UpScale();
        
        SetBlurredTextureAsGlobal();

        BlitBlurredTextureToBuffer();
        BlitExcludedCameraToBuffer();
        
        mainCamera.AddCommandBuffer(CAMERA_EVENT, blurCommandBuffer);
        
        blurMaterial.SetFloat(INTENSITY_ID, 1f);
    }

    private void Cleanup()
    {
        DestroyImmediate(blurMaterial);

        if(blurCommandBuffer == null)
            return;
        
        if(mainCamera != null)
            mainCamera.RemoveCommandBuffer(CAMERA_EVENT, blurCommandBuffer);
        
        blurCommandBuffer.Clear();
        blurCommandBuffer = null;
    }

    private void DownScale()
    {
        int width = Screen.width;
        int height = Screen.height;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        
        int currentIterationIndex = 1;
        int src = dest;
        for (; currentIterationIndex < downScaleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;
        
            dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");
            
            blurCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
            blurCommandBuffer.Blit(src, dest, blurMaterial, downScalePass);

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

            blurCommandBuffer.Blit(src, dest, blurMaterial, upScalePass);
            blurCommandBuffer.ReleaseTemporaryRT(src);
            
            previousDestination = currentIterationIndex;
        } 
    }

    private void BlitBlurredTextureToBuffer()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, blurMaterial, downScalePass);
    }

    private void BlitExcludedCameraToBuffer()
    {
        blurCommandBuffer.Blit(exclusionCamera.targetTexture, BuiltinRenderTextureType.CameraTarget);
    }

    private void AddCameraRenderTextureToBuffer()
    {
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.GetTemporaryRT(dest, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        blurCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, dest, blurMaterial, downScalePass);
    }
    
    private void SetCameraRenderTextureAsGlobal()
    {
        blurCommandBuffer.SetGlobalTexture(ORIGINAL_TEXTURE_ID, BuiltinRenderTextureType.CameraTarget);
    }
    
    private void SetBlurredTextureAsGlobal()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.SetGlobalTexture(BLURRED_TEXTURE_ID, src);
    }
}
