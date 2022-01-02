using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways, RequireComponent(typeof(Graphic))]
public class UIMaterialAnimationExposer : MonoBehaviour
{
    [SerializeField, HideInInspector]
    private Graphic targetGraphic;
    [SerializeField, HideInInspector]
    private UIMaterialAnimationExpose[] exposes;

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
