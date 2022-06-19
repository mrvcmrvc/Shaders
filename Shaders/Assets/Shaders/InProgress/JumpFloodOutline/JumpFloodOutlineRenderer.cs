using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteInEditMode]
public class JumpFloodOutlineRenderer : MonoBehaviour
{
    [ColorUsageAttribute(true, true)] public Color outlineColor = Color.white;
    [Range(0.0f, 1000.0f)] public float outlinePixelWidth = 4f;

    [SerializeField] private Shader outlineShader;
    [SerializeField] private RenderTexture rt;

    public RenderTexture silhouetteRT, sobelRT, closestPointRT, outlineRT;
    
    public List<Renderer> renderers = new List<Renderer>();
    
    const CameraEvent cameraEvent = CameraEvent.AfterForwardAlpha;
    const bool useSeparableAxisMethod = true;

    // shader pass indices
    const int SHADER_PASS_INTERIOR_STENCIL = 0;
    const int SHADER_PASS_SILHOUETTE_BUFFER_FILL = 1;
    const int SHADER_PASS_JFA_INIT = 2;
    const int SHADER_PASS_JFA_FLOOD = 3;
    const int SHADER_PASS_JFA_FLOOD_SINGLE_AXIS = 4;
    const int SHADER_PASS_JFA_OUTLINE = 5;

    // render texture IDs
    private int silhouetteBufferID = Shader.PropertyToID("_SilhouetteBuffer");
    private int nearestPointID = Shader.PropertyToID("_NearestPoint");
    private int nearestPointPingPongID = Shader.PropertyToID("_NearestPointPingPong");

    // shader properties
    private int outlineColorID = Shader.PropertyToID("_OutlineColor");
    private int outlineWidthID = Shader.PropertyToID("_OutlineWidth");
    private int stepWidthID = Shader.PropertyToID("_StepWidth");
    private int axisWidthID = Shader.PropertyToID("_AxisWidth");

    // private variables
    private CommandBuffer cb;
    private Material outlineMat;
    private Camera bufferCam;

    private void CreateCommandBuffer(Camera cam)
    {
        if (renderers == null || renderers.Count == 0)
            return;

        if (cb == null)
        {
            cb = new CommandBuffer();
            cb.name = "JumpFloodOutlineRenderer: " + gameObject.name;
        }
        else
        {
            cb.Clear();
        }

        if (outlineMat == null)
            outlineMat = new Material(outlineShader);

        // do nothing if no outline will be visible
        if (outlineColor.a <= (1f/255f) || outlinePixelWidth <= 0f)
        {
            cb.Clear();
            return;
        }

        int renderersCount = renderers.Count;

        // render meshes to main buffer for the interior stencil mask
        cb.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        for (int i=0; i<renderersCount; i++)
        {
            cb.DrawRenderer(renderers[i], outlineMat, 0, SHADER_PASS_INTERIOR_STENCIL);
        }
        
        cb.Blit(BuiltinRenderTextureType.CameraTarget, rt);

        // match current quality settings' MSAA settings
        // doesn't check if current camera has MSAA enabled
        // also could just always do MSAA if you so pleased
        int msaa = Mathf.Max(1,QualitySettings.antiAliasing);

        int width = cam.scaledPixelWidth;
        int height = cam.scaledPixelHeight;

        // setup descriptor for silhouette render texture
        RenderTextureDescriptor silhouetteRTD = new RenderTextureDescriptor() {
            dimension = TextureDimension.Tex2D,
            graphicsFormat = GraphicsFormat.R8_UNorm,

            width = width,
            height = height,

            msaaSamples = msaa,
            depthBufferBits = 0,

            sRGB = false,

            useMipMap = false,
            autoGenerateMips = false
        };

        // create silhouette buffer and assign it as the current render target
        cb.GetTemporaryRT(silhouetteBufferID, silhouetteRTD, FilterMode.Point);
        cb.SetRenderTarget(silhouetteBufferID);
        cb.ClearRenderTarget(false, true, Color.clear);

        // render meshes to silhouette buffer
        for (int i=0; i<renderersCount; i++)
        {
            cb.DrawRenderer(renderers[i], outlineMat, 0, SHADER_PASS_SILHOUETTE_BUFFER_FILL);
        }
        
        // RT: Silhouette
        cb.Blit(silhouetteBufferID, silhouetteRT);

        // Humus3D wire trick, keep line 1 pixel wide and fade alpha instead of making line smaller
        // slightly nicer looking and no more expensive
        Color adjustedOutlineColor = outlineColor;
        adjustedOutlineColor.a *= Mathf.Clamp01(outlinePixelWidth);
        cb.SetGlobalColor(outlineColorID, adjustedOutlineColor.linear);
        cb.SetGlobalFloat(outlineWidthID, Mathf.Max(1f, outlinePixelWidth));

        // setup descriptor for jump flood render textures
        var jfaRTD = silhouetteRTD;
        jfaRTD.msaaSamples = 1;
        jfaRTD.graphicsFormat = GraphicsFormat.R16G16_SNorm;

        // create jump flood buffers to ping pong between
        cb.GetTemporaryRT(nearestPointID, jfaRTD, FilterMode.Point);
        cb.GetTemporaryRT(nearestPointPingPongID, jfaRTD, FilterMode.Point);

        // calculate the number of jump flood passes needed for the current outline width
        // + 1.0f to handle half pixel inset of the init pass and antialiasing
        int numMips = Mathf.CeilToInt(Mathf.Log(outlinePixelWidth + 1.0f, 2f));
        int jfaIter = numMips-1;

        // Alan Wolfe's separable axis JFA - https://www.shadertoy.com/view/Mdy3D3
        if (useSeparableAxisMethod)
        {

            // jfa init
            cb.Blit(silhouetteBufferID, nearestPointID, outlineMat, SHADER_PASS_JFA_INIT);

            // RT: Sobel
            cb.Blit(nearestPointID, sobelRT);
            
            // jfa flood passes
            for (int i=jfaIter; i>=0; i--)
            {
                // calculate appropriate jump width for each iteration
                // + 0.5 is just me being cautious to avoid any floating point math rounding errors
                float stepWidth = Mathf.Pow(2, i) + 0.5f;

                // the two separable passes, one axis at a time
                cb.SetGlobalVector(axisWidthID, new Vector2(stepWidth, 0f));
                cb.Blit(nearestPointID, nearestPointPingPongID, outlineMat, SHADER_PASS_JFA_FLOOD_SINGLE_AXIS);
                cb.SetGlobalVector(axisWidthID, new Vector2(0f, stepWidth));
                cb.Blit(nearestPointPingPongID, nearestPointID, outlineMat, SHADER_PASS_JFA_FLOOD_SINGLE_AXIS);
            }
            
            // RT: ClosestPoint
            cb.Blit(nearestPointPingPongID, closestPointRT);
        }

        // traditional JFA
        else
        {
            // choose a starting buffer so we always finish on the same buffer
            int startBufferID = (jfaIter % 2 == 0) ? nearestPointPingPongID : nearestPointID;

            // jfa init
            cb.Blit(silhouetteBufferID, startBufferID, outlineMat, SHADER_PASS_JFA_INIT);

            // jfa flood passes
            for (int i=jfaIter; i>=0; i--)
            {
                // calculate appropriate jump width for each iteration
                // + 0.5 is just me being cautious to avoid any floating point math rounding errors
                cb.SetGlobalFloat(stepWidthID, Mathf.Pow(2, i) + 0.5f);

                // ping pong between buffers
                if (i % 2 == 1)
                    cb.Blit(nearestPointID, nearestPointPingPongID, outlineMat, SHADER_PASS_JFA_FLOOD);
                else
                    cb.Blit(nearestPointPingPongID, nearestPointID, outlineMat, SHADER_PASS_JFA_FLOOD);
            }
        }

        // jfa decode & outline render
        cb.Blit(nearestPointID, BuiltinRenderTextureType.CameraTarget, outlineMat, SHADER_PASS_JFA_OUTLINE);
        
        // RT: Outline
        cb.Blit(BuiltinRenderTextureType.CameraTarget, outlineRT);

        cb.ReleaseTemporaryRT(silhouetteBufferID);
        cb.ReleaseTemporaryRT(nearestPointID);
        cb.ReleaseTemporaryRT(nearestPointPingPongID);
    }

    void ApplyCommandBuffer(Camera cam)
    {
        #if UNITY_EDITOR
        // hack to avoid rendering in the inspector preview window
        if (cam.gameObject.name == "Preview Scene Camera")
            return;
        #endif

        if (bufferCam != null)
        {
            if(bufferCam == cam)
                return;
            else
                RemoveCommandBuffer(cam);
        }

        Plane[] planes = GeometryUtility.CalculateFrustumPlanes(cam);

        // skip rendering if none of the renderers are in view
        bool visible = false;
        for (int i=0; i<renderers.Count; i++)
        {
            if (GeometryUtility.TestPlanesAABB(planes, renderers[i].bounds))
            {
                visible = true;
                break;
            }
        }

        if (!visible)
            return;

        CreateCommandBuffer(cam);
        if (cb == null)
            return;

        bufferCam = cam;
        bufferCam.AddCommandBuffer(cameraEvent, cb);
    }

    void RemoveCommandBuffer(Camera cam)
    {
        if (bufferCam != null && cb != null)
        {
            bufferCam.RemoveCommandBuffer(cameraEvent, cb);
            bufferCam = null;
        }
    }

    void OnEnable()
    {
        Camera.onPreRender += ApplyCommandBuffer;
        Camera.onPostRender += RemoveCommandBuffer;
    }

    void OnDisable()
    {
        Camera.onPreRender -= ApplyCommandBuffer;
        Camera.onPostRender -= RemoveCommandBuffer;
    }

#if UNITY_EDITOR
    public void FindActiveMeshes()
    {
        Undo.RecordObject(this, "Filling with all active Renderer components");

        SpriteRenderer[] spriteRenderers = gameObject.GetComponentsInChildren<SpriteRenderer>(true);
        if (spriteRenderers.Length > 0)
        {
            foreach (var spriteRenderer in spriteRenderers)
            {
                if (spriteRenderer.gameObject.activeSelf)
                    renderers.Add(spriteRenderer);
            }
        }
    }
#endif
}

#if UNITY_EDITOR
[CustomEditor(typeof(JumpFloodOutlineRenderer))]
public class JumpFloodOutlineRendererEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Get Active Children Renderers"))
        {
            UnityEngine.Object[] objs = serializedObject.targetObjects;

            foreach (var obj in objs)
            {
                var mh = (obj as JumpFloodOutlineRenderer);
                mh.FindActiveMeshes();
            }
        }
    }
}
#endif