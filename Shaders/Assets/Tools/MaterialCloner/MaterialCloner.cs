using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways, RequireComponent(typeof(Graphic))]
public class MaterialCloner : MonoBehaviour
{
    [SerializeField, HideInInspector]
    private Graphic targetGraphic;
    [SerializeField, HideInInspector]
    private Material originalMaterial;
    [SerializeField, HideInInspector]
    private Material instancedMaterial;
    
    private void OnEnable()
    {
        if (instancedMaterial != null)
            return;
        
        originalMaterial = targetGraphic.material;
        instancedMaterial = targetGraphic.material = Instantiate(targetGraphic.material);
    }

    private void OnDisable()
    {
        targetGraphic.material = originalMaterial;

#if UNITY_EDITOR
        DestroyImmediate(instancedMaterial);
#else
        Destroy(instancedMaterial);
#endif
    }
    
    private void Awake()
    {
        targetGraphic = GetComponent<Graphic>();
    }
}
