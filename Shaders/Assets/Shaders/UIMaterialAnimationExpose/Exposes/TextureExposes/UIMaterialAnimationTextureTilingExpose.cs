using UnityEngine;

public class UIMaterialAnimationTextureTilingExpose : UIMaterialAnimationExpose
{
    [SerializeField]
    private Vector2 tiling;

    protected override void CustomLateUpdate(Material material)
    {
        material.SetTextureScale(propertyName, tiling);
    }
}
