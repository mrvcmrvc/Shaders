using UnityEngine;

public class UIMaterialAnimationFloatExpose : UIMaterialAnimationExpose
{
    [SerializeField] 
    private float propertyValue;
    
    protected override void CustomLateUpdate(Material material)
    {
        material.SetFloat(propertyName, propertyValue);
    }
}
