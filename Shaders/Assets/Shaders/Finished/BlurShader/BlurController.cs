using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class BlurController : MonoBehaviour
{    
    [SerializeField]
    private Shader blurShader;
    
    [SerializeField]
    private Shader blurTransitionShader;
    
    [SerializeField]
    private Camera exclusionCamera;
    public Camera ExclusionCamera => exclusionCamera;
        
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    [SerializeField]
    private float transitionDuration;

    private CommandBuffer blurCommandBuffer;
    private Material blurMaterial;
    private Material blurTransitionMaterial;
    private Camera mainCamera;

    private const int downScalePass = 0;
    private const int upScalePass = 1;
    
    public const string EXCLUSION_LAYER_NAME = "BlurExclusion";

    private static readonly int BLUR_STRENGTH_ID = Shader.PropertyToID("_BlurStrength");
    private const string BUFFER_NAME = "Blur Buffer";
    private const CameraEvent CAMERA_EVENT = CameraEvent.AfterForwardAlpha;

    private void OnDisable()
    {
        Cleanup();
    }
    
    private void OnEnable()
    {
        Cleanup();
    }

    public void SetActive(bool activate, bool isInstant = false)
    {
        if(activate)
            enabled = true;

        StartCoroutine(TransitionBlurStrengthTo(activate ? 1f : 0f, isInstant ? Mathf.Epsilon : transitionDuration));
    }
    
    private IEnumerator TransitionBlurStrengthTo(float targetStrength, float transitionDuration)
    {
        float passedDuration = 0f;
        while (passedDuration <= transitionDuration)
        {
            float newStrength = Mathf.Lerp(1 - targetStrength, targetStrength, passedDuration / transitionDuration);
            passedDuration += Time.deltaTime;

            blurTransitionMaterial.SetFloat(BLUR_STRENGTH_ID, newStrength);
            
            yield return null;
        }

        if (targetStrength == 0f)
            enabled = false;
    }

    private void Update()
    {
        if(blurCommandBuffer != null)
            return;

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
        
        blurTransitionMaterial = new Material(blurTransitionShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
    }

    private void RenderBlur()
    {
        SetOriginalTextureAsGlobal();
        
        DownScale();
        UpScale();
        
        SetBlurredTextureAsGlobal();

        BlitBlurredTextureToBuffer();
        BlitExcludedCameraToBuffer();
        
        mainCamera.AddCommandBuffer(CAMERA_EVENT, blurCommandBuffer);
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
        blurCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        blurCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, dest, blurMaterial, downScalePass);
        
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
        blurCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, blurTransitionMaterial);
    }

    private void BlitExcludedCameraToBuffer()
    {
        blurCommandBuffer.Blit(exclusionCamera.targetTexture, BuiltinRenderTextureType.CameraTarget);
    }
    
    private void SetOriginalTextureAsGlobal()
    {
        blurCommandBuffer.SetGlobalTexture("_OriginalTexture", BuiltinRenderTextureType.CameraTarget);
    }
    
    private void SetBlurredTextureAsGlobal()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.SetGlobalTexture("_BlurredTexture", src);
    }
}
