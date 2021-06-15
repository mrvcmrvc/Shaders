using UnityEngine;

public class UIMaterialAnimationColorExpose : UIMaterialAnimationExpose
{
    [SerializeField]
    private Color color;

    protected override void CustomLateUpdate(Material material)
    {
        material.SetColor(propertyName, color);
    }
}
