using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SpriteMultiMaterialApplier : MonoBehaviour
{
    [SerializeField]
    private Camera renderCamera;
    [SerializeField]
    public Material[] materials;

    [SerializeField, HideInInspector]
    private CommandBuffer buffer;
    private SpriteRenderer spriteRenderer;
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

        int latestId = BlitMaterials();

        FinishBlit();
    }

    private void Initialize()
    {
        spriteRenderer = GetComponent<SpriteRenderer>();
        spriteRenderer.enabled = false;
        buffer = new CommandBuffer
        {
            name = BufferName,
        };
    }

    [ContextMenu("Clear")]
    private void Cleanup()
    {
        if (buffer == null)
            return;

        if (renderCamera != null)
            renderCamera.RemoveCommandBuffer(CameraEvent, buffer);

        spriteRenderer.enabled = true;

        buffer.Clear();
        buffer = null;
    }

    private int BlitMaterials()
    {
        GenerateNewRT($"{RtNamePrefix}Screen", out int screenId);
        buffer.Blit(BuiltinRenderTextureType.CameraTarget, screenId);

        GenerateNewRT($"{RtNamePrefix}Original", out int originalId);
        buffer.SetRenderTarget(originalId);
        buffer.ClearRenderTarget(true, true, new Color(0, 0, 0, 0));
        buffer.DrawRenderer(spriteRenderer, spriteRenderer.sharedMaterial);

        int latestId = originalId;
        for (int i = 0; i < materials.Length; i++)
        {
            GenerateNewRT($"{RtNamePrefix}{i}", out int id);

            buffer.Blit(latestId, id, materials[i]);
            buffer.ReleaseTemporaryRT(latestId);

            latestId = id;
        }

        buffer.Blit(latestId, BuiltinRenderTextureType.CameraTarget);
        buffer.Blit(screenId, BuiltinRenderTextureType.CameraTarget);

        return latestId;
    }

    private void GenerateNewRT(string rtName, out int id)
    {
        id = Shader.PropertyToID(rtName);

        buffer.GetTemporaryRT(
            id,
            1920,
            1080,
            0,
            FilterMode.Bilinear,
            RenderTextureFormat.DefaultHDR
        );
    }

    private void FinishBlit()
    {
        renderCamera.AddCommandBuffer(CameraEvent, buffer);
    }
}
