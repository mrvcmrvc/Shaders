using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SpriteMultiMaterialApplier : MonoBehaviour
{
    [SerializeField]
    private Camera renderCamera;
    [SerializeField]
    public Material[] materials;
    
    private const int DepthOffset = 10;

    private CommandBuffer buffer;
    private SpriteRenderer spriteRenderer;
    private Shader transparencyShader;
    private Material transparencyMaterial;
    private int depthOffset;
    
    private const string BufferName = "Apply Sprite Multi Material";
    private const CameraEvent CameraEvent = UnityEngine.Rendering.CameraEvent.AfterForwardAlpha;
    private const string RtNamePrefix = "currentDestination_";

    [ContextMenu("Apply")]
    private void ApplyEffects()
    {
        if (materials.Length == 0)
            return;

        if (buffer != null)
            Cleanup();

        Initialize();

        BlitMaterials();
        
        renderCamera.AddCommandBuffer(CameraEvent, buffer);
    }

    private void Initialize()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        spriteRenderer.enabled = false;
        buffer = new CommandBuffer
        {
            name = BufferName,
        };

        depthOffset = renderCamera.GetCommandBuffers(CameraEvent).Length * DepthOffset;
        
        transparencyShader = Shader.Find("Unlit/TransparentShader");
        transparencyMaterial = new Material(transparencyShader);
    }

    [ContextMenu("Clear")]
    private void Cleanup()
    {
        if (buffer == null)
            return;

        if (renderCamera != null)
            renderCamera.RemoveCommandBuffer(CameraEvent, buffer);

        DestroyImmediate(transparencyMaterial);
        spriteRenderer.enabled = true;

        buffer.Clear();
        buffer = null;
    }

    private void BlitMaterials()
    {        
        GenerateNewRT($"{RtNamePrefix}Original.{Random.value}", depthOffset, out int originalId);
        
        buffer.SetRenderTarget(originalId);
        buffer.ClearRenderTarget(false, true, Color.clear);
        
        buffer.DrawRenderer(spriteRenderer, spriteRenderer.sharedMaterial);

        int latestId = originalId;
        for (int i = 0; i < materials.Length; i++)
        {
            GenerateNewRT($"{RtNamePrefix}{i}.{Random.value}", depthOffset + i + 1, out int id);

            buffer.SetRenderTarget(id);
            buffer.ClearRenderTarget(false, true, Color.clear);

            buffer.Blit(latestId, BuiltinRenderTextureType.CurrentActive, materials[i]);
            buffer.ReleaseTemporaryRT(latestId);

            latestId = id;
        }
        
        buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        buffer.Blit(latestId, BuiltinRenderTextureType.CurrentActive, transparencyMaterial);
        buffer.ReleaseTemporaryRT(latestId);
    }

    private void GenerateNewRT(string rtName, int depth, out int id)
    {
        id = Shader.PropertyToID(rtName);

        buffer.GetTemporaryRT(
            id,
            1920,
            1080,
            depth,
            FilterMode.Bilinear,
            RenderTextureFormat.DefaultHDR
        );
    }
}
