using UnityEngine;

public abstract class UIMaterialAnimationExpose : MonoBehaviour
{    
    [SerializeField]
    protected string propertyName;
    
    protected abstract void CustomLateUpdate(Material material);
    
    public void LateUpdateExpose(Material material)
    {
        if(!Validate())
            return;

        CustomLateUpdate(material);
    }

    private bool Validate()
    {
        return !string.IsNullOrEmpty(propertyName);
    }
}
