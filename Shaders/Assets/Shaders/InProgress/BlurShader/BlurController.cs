using UnityEngine;
using UnityEngine.Rendering;

public class BlurController : MonoBehaviour
{
    [SerializeField]
    private Material bloomMaterial;
    
    [SerializeField]
    private Camera mainCamera;
    
    [SerializeField]
    private Camera exclusionCamera;

    public Camera ExclusionCamera => exclusionCamera;
    
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    private CommandBuffer blurCommandBuffer;
    private bool isBlurActive;
    public bool IsBlurActive => isBlurActive;
    
    public const string EXCLUSION_LAYER_NAME = "BlurExclusion";

    private const int downScalePass = 0;
    private const int upScalePass = 1;

    private void Awake()
    {
        blurCommandBuffer = new CommandBuffer();
    }

    private void OnEnable()
    {
        RenderBlur();
    }

    private void OnDisable()
    {
        ClearBlur();
    }

    private void OnDestroy()
    {
        ClearBlur();
    }

    public void SetActive(bool activate)
    {
        if (activate)
            RenderBlur();
        else
            ClearBlur();
    }

    private void RenderBlur()
    {
        if(isBlurActive)
            return;
        
        isBlurActive = true;
        mainCamera.forceIntoRenderTexture = true;
        
        DownScale();
        UpScale();
        
        BlitBlurredTextureToBuffer();
        BlitExcludedCameraToBuffer();
        
        mainCamera.AddCommandBuffer(CameraEvent.AfterForwardAlpha, blurCommandBuffer);
    }

    private void ClearBlur()
    {
        if(!isBlurActive)
            return;
        
        if(mainCamera == null)
            return;
        
        isBlurActive = false;
        mainCamera.forceIntoRenderTexture = false;

        blurCommandBuffer.Clear();

        mainCamera.RemoveAllCommandBuffers();
    }

    private void DownScale()
    {
        int width = Screen.width;
        int height = Screen.height;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        blurCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        blurCommandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, dest, bloomMaterial, downScalePass);
        
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
            blurCommandBuffer.Blit(src, dest, bloomMaterial, downScalePass);

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

            blurCommandBuffer.Blit(src, dest, bloomMaterial, upScalePass);
            
            blurCommandBuffer.ReleaseTemporaryRT(previousDestination);
            previousDestination = currentIterationIndex;
        }
    }

    private void BlitBlurredTextureToBuffer()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");

        blurCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, bloomMaterial, upScalePass);
    }

    private void BlitExcludedCameraToBuffer()
    {
        blurCommandBuffer.Blit(exclusionCamera.targetTexture, BuiltinRenderTextureType.CameraTarget);
    }
}
