using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways, RequireComponent(typeof(Graphic))]
public class UIMaterialAnimationExposer : MonoBehaviour
{
    private Graphic targetGraphic;
    private Material originalMaterial;
    private Material instancedMaterial;
    private UIMaterialAnimationExpose[] exposes;

    private void OnEnable()
    {
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

        exposes = GetComponents<UIMaterialAnimationExpose>();
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
