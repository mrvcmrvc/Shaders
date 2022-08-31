using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SpriteMultiMaterialApplier : MonoBehaviour
{    
    [SerializeField]
    private Camera renderCamera;

    private CommandBuffer buffer;
    private Dictionary<SpriteRenderer, Material[]> spriteRendererToMaterials = new Dictionary<SpriteRenderer, Material[]>();
    private Shader transparencyShader;
    private Material transparencyMaterial;
    
    private const string BufferName = "Apply Sprite Multi Material";
    private const CameraEvent CameraEvent = UnityEngine.Rendering.CameraEvent.AfterForwardAlpha;
    private const string RtNamePrefix = "currentDestination_";
    private readonly int finalId = Shader.PropertyToID($"{RtNamePrefix}_final");

    private void Awake()
    {
        SpriteMultiMaterialData.SpriteMultiMaterialDataAddRequest += AddData;
        SpriteMultiMaterialData.SpriteMultiMaterialDataDiscardRequest += DiscardData;
    }

    private void OnDestroy()
    {
        SpriteMultiMaterialData.SpriteMultiMaterialDataAddRequest -= AddData;
        SpriteMultiMaterialData.SpriteMultiMaterialDataDiscardRequest -= DiscardData;
    }

    private void Restart()
    {
        if (buffer != null)
            BufferCleanup();
        
        Initialize();

        BlitMaterials();
        
        BlitToCamera();

        renderCamera.AddCommandBuffer(CameraEvent, buffer);
    }

    private void Initialize()
    {        
        buffer = new CommandBuffer
        {
            name = BufferName,
        };
        
        transparencyShader = Shader.Find("Unlit/TransparentShader");
        transparencyMaterial = new Material(transparencyShader);
    }

    [ContextMenu("Clear")]
    public void Cleanup()
    {
        BufferCleanup();

        foreach (KeyValuePair<SpriteRenderer, Material[]> rendererToMaterial in spriteRendererToMaterials)
            rendererToMaterial.Key.enabled = true;
        
        spriteRendererToMaterials.Clear();
    }
    
    private void BufferCleanup()
    {
        if (buffer == null)
            return;

        if (renderCamera != null)
            renderCamera.RemoveCommandBuffer(CameraEvent, buffer);

        DestroyImmediate(transparencyMaterial);

        buffer.Clear();
        buffer = null;
    }

    private void AddData(KeyValuePair<SpriteRenderer, Material[]> data)
    {
        if (data.Value.Length == 0)
            return;
        
        if (spriteRendererToMaterials.ContainsKey(data.Key))
            spriteRendererToMaterials.Remove(data.Key);
        
        spriteRendererToMaterials.Add(data.Key, data.Value);
        
        Restart();
    }

    private void DiscardData(SpriteRenderer spriteRenderer)
    {
        if (spriteRendererToMaterials.ContainsKey(spriteRenderer))
            spriteRendererToMaterials.Remove(spriteRenderer);

        Restart();
    }

    private void BlitMaterials()
    {
        GenerateNewRT(finalId, true, true);

        foreach (KeyValuePair<SpriteRenderer, Material[]> rendererToMaterial in spriteRendererToMaterials)
            BlitSpriteWithMaterials(rendererToMaterial);
    }

    private void BlitSpriteWithMaterials(KeyValuePair<SpriteRenderer,Material[]> rendererToMaterial)
    {        
        int latestId = -1;
        for (int i = 0; i < rendererToMaterial.Value.Length; i++)
        {
            if (IndexFirstButNotLast(i, rendererToMaterial.Value.Length))
                latestId = DrawToOriginal(rendererToMaterial.Key, rendererToMaterial.Value[i]);
            else if (IndexNotFirstAndNotLast(i, rendererToMaterial.Value.Length))
                latestId = BlitToLatest(i, latestId, rendererToMaterial.Value[i]);
            else if (IndexNotFirstButLast(i, rendererToMaterial.Value.Length))
                BlitToFinal(latestId, rendererToMaterial.Value[i]);
            else if (IndexFirstAndLast(i, rendererToMaterial.Value.Length))
                DrawToFinal(rendererToMaterial.Key, rendererToMaterial.Value[i]);
        }
    }

    private bool IndexFirstButNotLast(int index, int count)
    {
        return index == 0 && index < count - 1;
    }
    
    private bool IndexNotFirstAndNotLast(int index, int count)
    {
        return index > 0 && index < count - 1;
    }
    
    private bool IndexNotFirstButLast(int index, int count)
    {
        return index > 0 && index == count - 1;
    }
    
    private bool IndexFirstAndLast(int index, int count)
    {
        return index == 0 && count == 1;
    }

#region Blit & Draw

    private int DrawToOriginal(SpriteRenderer renderer, Material material)
    {
        GenerateNewRT($"{RtNamePrefix}Original", true, true, out int originalId);
        
        buffer.DrawRenderer(renderer, material);

        return originalId;
    }
    
    private int BlitToLatest(int index, int latestId, Material material)
    {
        GenerateNewRT($"{RtNamePrefix}{index}", true, true, out int id);

        buffer.Blit(latestId, BuiltinRenderTextureType.CurrentActive, material);
        buffer.ReleaseTemporaryRT(latestId);

        return id;
    }
    
    private void BlitToFinal(int latestId, Material material)
    {
        buffer.Blit(latestId, finalId, material);
        buffer.ReleaseTemporaryRT(latestId);
    }
    
    private void DrawToFinal(SpriteRenderer renderer, Material material)
    {
        buffer.SetRenderTarget(finalId);
        buffer.DrawRenderer(renderer, material);
    }

    private void BlitToCamera()
    {
        buffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);
        buffer.Blit(finalId, BuiltinRenderTextureType.CurrentActive, transparencyMaterial);
        buffer.ReleaseTemporaryRT(finalId);
    }
    
#endregion

    private void GenerateNewRT(string rtName, bool setRenderTarget, bool clearRenderTarget, out int id)
    {
        id = Shader.PropertyToID(rtName);

        GenerateNewRT(id, setRenderTarget, clearRenderTarget);
    }
    
    private void GenerateNewRT(int id, bool setRenderTarget, bool clearRenderTarget)
    {
        buffer.GetTemporaryRT(
            id,
            1920,
            1080,
            0,
            FilterMode.Bilinear,
            RenderTextureFormat.DefaultHDR
        );
        
        if (setRenderTarget)
            buffer.SetRenderTarget(id);
        
        if (clearRenderTarget)
            buffer.ClearRenderTarget(false, true, Color.clear);
    }
}
