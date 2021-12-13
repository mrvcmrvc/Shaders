using UnityEngine;

public class UIMaterialAnimationTextureExpose : UIMaterialAnimationExpose
{
    [SerializeField]
    private Texture texture;

    protected override void CustomLateUpdate(Material material)
    {
        material.SetTexture(propertyName, texture);
    }
}
