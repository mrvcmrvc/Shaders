using System;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways, RequireComponent(typeof(Graphic))]
public class UIMaterialAnimationExposer : MonoBehaviour
{
    [SerializeField, HideInInspector]
    private Graphic targetGraphic;
    [SerializeField, HideInInspector]
    private Material originalMaterial;
    [SerializeField, HideInInspector]
    private Material instancedMaterial;
    [SerializeField, HideInInspector]
    private UIMaterialAnimationExpose[] exposes;
    
    private void OnEnable()
    {
        if(instancedMaterial != null)
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

    private void OnValidate()
    {
        exposes = GetComponentsInChildren<UIMaterialAnimationExpose>();
    }

    private void Awake()
    {
        targetGraphic = GetComponent<Graphic>();

        exposes = GetComponentsInChildren<UIMaterialAnimationExpose>();
    }

    private void LateUpdate()
    {
        for (int i = 0; i < exposes.Length; i++)
        {
            UIMaterialAnimationExpose expose = exposes[i];
            
            expose.LateUpdateExpose(targetGraphic.material);
        }
    }
}
