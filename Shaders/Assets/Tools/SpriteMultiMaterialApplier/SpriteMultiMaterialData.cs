using System;
using System.Collections.Generic;
using UnityEngine;

public class SpriteMultiMaterialData : MonoBehaviour
{
    public static event Action<KeyValuePair<SpriteRenderer, Material[]>> SpriteMultiMaterialDataAddRequest;
    public static event Action<SpriteRenderer> SpriteMultiMaterialDataDiscardRequest;

    [SerializeField, Tooltip("Recommended! Disabling can allow to gain drawcall.")]
    private bool hideOriginalSprite;
    [SerializeField]
    private Material[] materials;
    
    private SpriteRenderer spriteRenderer;
    private SpriteRenderer SpriteRenderer
    {
        get
        {
            if (spriteRenderer == null)
                spriteRenderer = GetComponent<SpriteRenderer>();

            return spriteRenderer;
        }
    }

    [ContextMenu("Apply")]
    public void ApplyEffects()
    {
        SpriteRenderer.enabled = !hideOriginalSprite;

        SendData();
    }
    
    [ContextMenu("Discard")]
    public void DiscardEffects()
    {
        SpriteRenderer.enabled = true;

        RemoveData();
    }

    private void SendData()
    {
        SpriteMultiMaterialDataAddRequest?.Invoke(new KeyValuePair<SpriteRenderer, Material[]>(SpriteRenderer, materials));
    }
    
    private void RemoveData()
    {
        SpriteMultiMaterialDataDiscardRequest?.Invoke(SpriteRenderer);
    }
}
