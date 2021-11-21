using UnityEngine;

public class UIMaterialAnimationVectorExpose : UIMaterialAnimationExpose
{
    [SerializeField]
    private Vector4 vector;

    protected override void CustomLateUpdate(Material material)
    {
        material.SetVector(propertyName, vector);
    }
}
