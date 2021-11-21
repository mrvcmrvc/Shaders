using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class BloomController : MonoBehaviour
{
    [SerializeField]
    private bool startOnAwake;
    [SerializeField]
    private bool useMainCamera;
    [SerializeField]
    private Camera renderCamera;
    [SerializeField]
    private Shader bloomShader;
    [SerializeField, Range(1, 16)]
    private int downScaleCount = 1;
    [SerializeField, Range(0f, 1f)]
    private float resolutionScaling = 0.5f;
    [SerializeField]
    private float transitionDuration;
    [Header("Threshold Settings"), SerializeField, Range(1f, 10f)]
    private float threshold = 1;
    [SerializeField, Range(0f, 1f)]
    private float softThreshold = 0.5f;
    [SerializeField, Range(0, 10)]
    private float intensity = 1;
    
    public bool IsEnabled { get; private set; }
    
    private CommandBuffer bloomCommandBuffer;
    private Material bloomMaterial;
    private Coroutine transitionCoroutine;
    private Vector2Int startingResolution;

    private const int preFilterPass = 1;
    private const int downScalePass = 2;
    private const int upScalePass = 3;
    private const int bloomPass = 0;

    private static readonly int FILTER_ID = Shader.PropertyToID("_Filter");
    private static readonly int ORIGINAL_TEXTURE_ID = Shader.PropertyToID("_OriginalTexture");
    private static readonly int INTENSITY_ID = Shader.PropertyToID("_Intensity");
    private const string BUFFER_NAME = "Bloom Buffer";
    private const CameraEvent CAMERA_EVENT = CameraEvent.AfterForwardAlpha;

    private void Awake()
    {
        if (useMainCamera)
            renderCamera = Camera.main;
        
        if (startOnAwake)
            SetActive(true);
    }

    private void OnEnable()
    {
        SetActive(true);
    }

    private void OnDisable()
    {
        SetActive(false, true);
    }

    public void SetActive(bool activate, bool isInstant = false)
    {
        if (IsEnabled == activate)
            return;
        
        IsEnabled = activate;
        
        if (activate)
            Startup();

        if (transitionCoroutine != null)
        {
            StopCoroutine(transitionCoroutine);
            transitionCoroutine = null;
        }

        float targetIntensity = activate ? intensity : 0f;
        if (isInstant)
        {
            bloomMaterial.SetFloat(INTENSITY_ID, targetIntensity);

            if (activate)
                return;
            
            Cleanup();
        }
        else
        {
            StartCoroutine(IntensityEnumerator(targetIntensity));
        }
    }
    
    private IEnumerator IntensityEnumerator(float targetIntensity)
    {
        float passedDuration = 0f;
        while (passedDuration <= transitionDuration)
        {
            float newIntensity = Mathf.Lerp(intensity - targetIntensity, targetIntensity, passedDuration / transitionDuration);
            passedDuration += Time.deltaTime;

            bloomMaterial.SetFloat(INTENSITY_ID, newIntensity);
            
            yield return null;
        }

        if (targetIntensity == 0f)
            Cleanup();

        transitionCoroutine = null;
    }
    
    private void Startup()
    {
        Initialize();
        
        RenderBloom();
    }
    
    private void Cleanup()
    {
        if (transitionCoroutine != null)
        {
            StopCoroutine(transitionCoroutine);
            transitionCoroutine = null;
        }
        
        if(bloomCommandBuffer == null)
            return;
        
        if(renderCamera != null)            
            renderCamera.RemoveCommandBuffer(CAMERA_EVENT, bloomCommandBuffer);
         
        DestroyImmediate(bloomMaterial);

        bloomCommandBuffer.Clear();
        bloomCommandBuffer = null;
    }

    private void Update()
    {
        if (bloomCommandBuffer == null)
            return;
        
        UpdateShaderProperties();
    }

    private void UpdateShaderProperties()
    {
        bloomMaterial.SetFloat(INTENSITY_ID, Mathf.GammaToLinearSpace(intensity));
        bloomMaterial.SetVector(FILTER_ID, GetFilter());
    }

    private void Initialize()
    {        
        bloomCommandBuffer = new CommandBuffer
        {
            name = BUFFER_NAME
        };
        
        bloomMaterial = new Material(bloomShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
        
        startingResolution = new Vector2Int(
            Mathf.RoundToInt(Screen.width * resolutionScaling), 
            Mathf.RoundToInt(Screen.height * resolutionScaling));
    }

    private void RenderBloom()
    {
        SetCameraRenderTextureAsGlobal();

        AddCameraRenderTextureToBuffer();
        DownScale();
        UpScale();
        
        BlitBlurredTextureToBuffer();
        
        renderCamera.AddCommandBuffer(CAMERA_EVENT, bloomCommandBuffer);
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
            
            bloomCommandBuffer.GetTemporaryRT(dest, width, height, 0, FilterMode.Bilinear, RenderTextureFormat.DefaultHDR);
            bloomCommandBuffer.Blit(src, dest, bloomMaterial, downScalePass);

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

            bloomCommandBuffer.Blit(src, dest, bloomMaterial, upScalePass);
            bloomCommandBuffer.ReleaseTemporaryRT(src);
            
            previousDestination = currentIterationIndex;
        } 
    }

    private void BlitBlurredTextureToBuffer()
    {
        int src = Shader.PropertyToID($"currentDestination_{0}");
        bloomCommandBuffer.Blit(src, BuiltinRenderTextureType.CameraTarget, bloomMaterial, bloomPass);
    }
    
    private void AddCameraRenderTextureToBuffer()
    {
        int dest = Shader.PropertyToID($"currentDestination_{0}");
        bloomCommandBuffer.GetTemporaryRT(dest, startingResolution.x, startingResolution.y, 0, FilterMode.Bilinear, RenderTextureFormat.DefaultHDR);
        bloomCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, dest, bloomMaterial, preFilterPass);
    }
    
    private void SetCameraRenderTextureAsGlobal()
    {
        bloomCommandBuffer.SetGlobalTexture(ORIGINAL_TEXTURE_ID, BuiltinRenderTextureType.CameraTarget);
    }
}
