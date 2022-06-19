using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BlurController : MonoBehaviour
{    
    [SerializeField]
    private Shader blurShader;
    [SerializeField]
    private Camera renderCamera;
    [SerializeField]
    private Camera exclusionCamera;
    public Camera ExclusionCamera => exclusionCamera;
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 2;
    [SerializeField, Range(0f, 1f)]
    private float resolutionScaling = 0.5f;
    [SerializeField]
    private float transitionDuration = 0.1f;
    
    public event Action OnBlurStackUpdatedEvent;

    public bool ShouldBlurEverything
    {
        get
        {
            if (blurCallStack.Count > 0)
                return blurCallStack.Peek();
            
            return false;
        }
    }

    public bool IsActive => enabled && blurCallStack.Count > 0;

    private Stack<bool> blurCallStack;
    private CommandBuffer blurCommandBuffer;
    private Material blurMaterial;
    private Coroutine transitionCoroutine;
    private Vector2Int startingResolution;
    
    private const int downScalePass = 0;
    private const int upScalePass = 1;
    
    private static readonly int originalTextureId = Shader.PropertyToID("_OriginalTexture");
    private static readonly int intensityId = Shader.PropertyToID("_Intensity");
    
    public const string ExclusionLayerName = "BlurExclusion";
    private const string BufferName = "Blur Buffer";
    private const CameraEvent CameraEvent = UnityEngine.Rendering.CameraEvent.AfterForwardAlpha;
    
    private void Awake()
    {
        blurCallStack = new Stack<bool>();
    }

    private void OnEnable()
    {
        if (blurCommandBuffer != null)
            return;

        Startup();
    }
    
    private void OnDisable()
    {
        Cleanup();
    }

    public void Activate(bool blurAll = false, bool isInstant = false)
    {
        blurCallStack.Push(blurAll);

        SetActive(true, isInstant);
    }

    public void Deactivate(bool isInstant = false)
    {
        blurCallStack.Pop();

        SetActive(false, isInstant);
    }

    private void SetActive(bool activate, bool isInstant = false)
    {
        if (activate)
            enabled = true;

        OnBlurStackUpdatedEvent?.Invoke();
        
        if ((activate && blurCallStack.Count > 1) || (!activate && blurCallStack.Count > 0))
            return;
        
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

            blurMaterial.SetFloat(intensityId, newIntensity);
            
            yield return null;
        }
        
        blurMaterial.SetFloat(intensityId, targetIntensity);

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
        blurCommandBuffer = new CommandBuffer
        {
            name = BufferName
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
        
        renderCamera.AddCommandBuffer(CameraEvent, blurCommandBuffer);
        
        blurMaterial.SetFloat(intensityId, 1f);
    }

    private void Cleanup()
    {
        DestroyImmediate(blurMaterial);

        if (blurCommandBuffer == null)
            return;
        
        if (renderCamera != null)
            renderCamera.RemoveCommandBuffer(CameraEvent, blurCommandBuffer);
        
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
            
            if (width < 2 || height < 2)
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
        blurCommandBuffer.SetGlobalTexture(originalTextureId, BuiltinRenderTextureType.CameraTarget);
    }
}
