using UnityEngine;
using UnityEngine.Rendering;

public class BlurEffect : MonoBehaviour
{
    [SerializeField]
    private Material bloomMaterial;
    
    [SerializeField]
    private Camera camera;
    
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;

    private CommandBuffer commandBuffer;
    private bool isBlurActive;
    private static readonly int BlurPowerID = Shader.PropertyToID("_BlurPower");
    
    private void Awake()
    {
        commandBuffer = new CommandBuffer();
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

    public void ToggleBlur(bool activate)
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
        camera.forceIntoRenderTexture = true;
        
        bloomMaterial.SetFloat(BlurPowerID, 1);

        DownScale();
        UpScale();
        RenderToCamera();
    }

    private void ClearBlur()
    {
        if(!isBlurActive)
            return;
        
        isBlurActive = false;
        camera.forceIntoRenderTexture = false;

        bloomMaterial.SetFloat(BlurPowerID, 0);

        commandBuffer.Clear();

        camera.RemoveAllCommandBuffers();
    }

    private void DownScale()
    {
        int width = Screen.width;
        int height = Screen.height;
        
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        commandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
        commandBuffer.Blit(BuiltinRenderTextureType.CurrentActive, dest, bloomMaterial);
        
        int currentIterationIndex = 1;
        int src = dest;
        for (; currentIterationIndex < downScaleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;
        
            dest = Shader.PropertyToID($"currentDestination_{currentIterationIndex}");
            
            commandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.BGRA32);
            commandBuffer.Blit(src, dest, bloomMaterial);

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

            commandBuffer.Blit(src, dest, bloomMaterial);
            
            commandBuffer.ReleaseTemporaryRT(previousDestination);
            previousDestination = currentIterationIndex;
        }
    }

    private void RenderToCamera()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        
        commandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, bloomMaterial);

        camera.AddCommandBuffer(CameraEvent.AfterForwardAlpha, commandBuffer);
    }
}
