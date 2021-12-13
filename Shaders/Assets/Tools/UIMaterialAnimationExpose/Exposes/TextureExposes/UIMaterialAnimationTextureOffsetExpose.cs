using UnityEngine;

public class UIMaterialAnimationTextureOffsetExpose : UIMaterialAnimationExpose
{
    [SerializeField]
    private Vector2 offset;

    protected override void CustomLateUpdate(Material material)
    {
        material.SetTextureOffset(propertyName, offset);
    }
}
