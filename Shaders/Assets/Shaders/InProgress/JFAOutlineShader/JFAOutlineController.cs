using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

public class JFAOutlineController : MonoBehaviour
{
    [SerializeField][ColorUsageAttribute(true, true)]
    private Color outlineColor = Color.white;
    [SerializeField][Range(0.0f, 1000.0f)]
    private float outlinePixelWidth = 4f;
    [SerializeField]
    private Shader outlineShader;
    [SerializeField]
    private Camera renderCamera;
    
    public RenderTexture silhouetteRT, sobelRT, closestPointRT, outlineRT;
    
    private const int stencilPass = 1;
    private const int silhouettePass = 2;
    private const int sobelPass = 3;
    private const int closestDistancePass = 4;
    private const int outlinePass = 0;
    
    private CommandBuffer outlineCommandBuffer;
    private Material outlineMaterial;
    private RenderTextureDescriptor silhouetteRenderTextureDescriptor;
    private List<Renderer> texturesToOutline = new List<Renderer>();
    
    private readonly int outlineColorId = Shader.PropertyToID("OutlineColor");
    private readonly int outlineWidthId = Shader.PropertyToID("OutlineWidth");
    private int axisWidthID = Shader.PropertyToID("AxisWidth");
    private readonly int silhouetteBufferId = Shader.PropertyToID("SilhouetteBuffer");
    private readonly int closestPointId = Shader.PropertyToID("ClosestPointBuffer");
    private int closestPointPingPongId = Shader.PropertyToID("ClosestPointPingPongBuffer");
    private const string BufferName = "Outline Buffer";
    private const CameraEvent CameraEvent = UnityEngine.Rendering.CameraEvent.AfterForwardAlpha;
    
    public void AddToOutline(Renderer targetTexture)
    {
        texturesToOutline.Add(targetTexture);
        
        Cleanup();
        Startup();
    }

    public void RemoveFromOutline(Renderer targetTexture)
    {
        texturesToOutline.Remove(targetTexture);
        
        Cleanup();
        Startup();
    }
    
    private void OnEnable()
    {
        if (outlineCommandBuffer != null)
            return;

        Startup();
    }
    
    private void OnDisable()
    {
        Cleanup();
    }
    
    public void SetActive(bool activate)
    {
        enabled = activate;
    }

    private void Startup()
    {
        Initialize();
        
        DrawRenderers();
    }
    
    private void Cleanup()
    {
        DestroyImmediate(outlineMaterial);

        if (outlineCommandBuffer == null)
            return;
        
        if (renderCamera != null)
            renderCamera.RemoveCommandBuffer(CameraEvent, outlineCommandBuffer);
        
        outlineCommandBuffer.Clear();
        outlineCommandBuffer = null;
    }
    
    private void Initialize()
    {
        outlineCommandBuffer = new CommandBuffer
        {
            name = BufferName
        };
        
        outlineMaterial = new Material(outlineShader)
        {
            hideFlags = HideFlags.HideAndDontSave
        };
        
        silhouetteRenderTextureDescriptor = new RenderTextureDescriptor
        {
            dimension = TextureDimension.Tex2D,
            graphicsFormat = GraphicsFormat.R8_UNorm,
            width = Screen.width,
            height = Screen.height,
            msaaSamples = 1,
            depthBufferBits = 0,
            sRGB = false,
            useMipMap = false,
            autoGenerateMips = false
        };
    }
    
    private void DrawRenderers()
    {
        DrawRenderersForStencil();

        DrawRenderersForSilhouette();

        SetShaderGlobalVariables();

        PrepareBufferForClosestPoints();

        ApplySobelToSilhouetteBuffer();
        
        FillClosestPointBuffers();

        ApplyOutline();

        ClearTemporaryRenderTextureBuffers();
    }

    private void DrawRenderersForStencil()
    {
        outlineCommandBuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        
        for (int i = 0; i < texturesToOutline.Count; i++)
            outlineCommandBuffer.DrawRenderer(texturesToOutline[i], outlineMaterial, 0, stencilPass);
    }

    private void DrawRenderersForSilhouette()
    {
        outlineCommandBuffer.GetTemporaryRT(silhouetteBufferId, silhouetteRenderTextureDescriptor, FilterMode.Point);
        outlineCommandBuffer.SetRenderTarget(silhouetteBufferId);
        outlineCommandBuffer.ClearRenderTarget(false, true, Color.clear);

        for (int i = 0; i < texturesToOutline.Count; i++)
            outlineCommandBuffer.DrawRenderer(texturesToOutline[i], outlineMaterial, 0, silhouettePass);
        
        // RT: Silhouette
        outlineCommandBuffer.Blit(silhouetteBufferId, silhouetteRT);
    }

    // Apply Phone-Wire AA (https://www.humus.name/index.php?page=3D&ID=89)
    private void SetShaderGlobalVariables()
    {
        Color adjustedOutlineColor = outlineColor;
        adjustedOutlineColor.a *= Mathf.Clamp01(outlinePixelWidth);
        
        outlineCommandBuffer.SetGlobalColor(outlineColorId, adjustedOutlineColor.linear);
        outlineCommandBuffer.SetGlobalFloat(outlineWidthId, Mathf.Max(1f, outlinePixelWidth));
    }

    private void PrepareBufferForClosestPoints()
    {
        RenderTextureDescriptor jfaRenderTextureDescriptor = silhouetteRenderTextureDescriptor;
        jfaRenderTextureDescriptor.graphicsFormat = GraphicsFormat.R16G16_SNorm;
        
        outlineCommandBuffer.GetTemporaryRT(closestPointId, jfaRenderTextureDescriptor, FilterMode.Point);
        outlineCommandBuffer.GetTemporaryRT(closestPointPingPongId, jfaRenderTextureDescriptor, FilterMode.Point);
    }

    private void ApplySobelToSilhouetteBuffer()
    {
        outlineCommandBuffer.Blit(silhouetteBufferId, closestPointId, outlineMaterial, sobelPass);
        
        // RT: Sobel
        outlineCommandBuffer.Blit(closestPointId, sobelRT);
    }

    private void FillClosestPointBuffers()
    {
        int numberOfMips = Mathf.CeilToInt(Mathf.Log(outlinePixelWidth + 1.0f, 2f));
        int jfaIterationCount = numberOfMips - 1;

        for (int i = jfaIterationCount; i >= 0; i--)
        {
            float stepWidth = Mathf.Pow(2, i) + 0.5f;

            outlineCommandBuffer.SetGlobalVector(axisWidthID, new Vector2(stepWidth, 0f));
            outlineCommandBuffer.Blit(closestPointId, closestPointPingPongId, outlineMaterial, closestDistancePass);

            outlineCommandBuffer.SetGlobalVector(axisWidthID, new Vector2(0f, stepWidth));
            outlineCommandBuffer.Blit(closestPointPingPongId, closestPointId, outlineMaterial, closestDistancePass);
        }
        
        // RT: ClosestPoint
        outlineCommandBuffer.Blit(closestPointId, closestPointRT);
    }

    private void ApplyOutline()
    {
        outlineCommandBuffer.Blit(closestPointId, BuiltinRenderTextureType.CameraTarget, outlineMaterial, outlinePass);
        
        // RT: Outline
        outlineCommandBuffer.Blit(BuiltinRenderTextureType.CameraTarget, outlineRT);

        renderCamera.AddCommandBuffer(CameraEvent, outlineCommandBuffer);        
    }

    private void ClearTemporaryRenderTextureBuffers()
    {
        outlineCommandBuffer.ReleaseTemporaryRT(silhouetteBufferId);
        outlineCommandBuffer.ReleaseTemporaryRT(closestPointId);
        outlineCommandBuffer.ReleaseTemporaryRT(closestPointPingPongId);
    }
}
