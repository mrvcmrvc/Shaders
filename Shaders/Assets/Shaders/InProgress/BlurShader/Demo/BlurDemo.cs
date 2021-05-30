using UnityEngine;

public class BlurDemo : MonoBehaviour
{
    [SerializeField]
    private BlurController blurController;

    [SerializeField]
    private GameObject targetObject;

    [SerializeField]
    private Canvas targetCanvas;
    

    private void Awake()
    {
        Application.targetFrameRate = 60;
    }

    private void Update()
    {
        #region Activate / Deactivate Blur

        if (Input.GetKeyUp(KeyCode.A))
            blurController.SetActive(!blurController.IsBlurActive);

        #endregion

        #region World Object Blur Inclusion / Exclusion

        if (Input.GetKeyUp(KeyCode.Alpha1))
            targetObject.layer = LayerMask.NameToLayer(BlurController.EXCLUSION_LAYER_NAME);
        
        if (Input.GetKeyUp(KeyCode.Alpha2))
            targetObject.layer = LayerMask.NameToLayer("Default");

        #endregion

        #region UI Blur Inclusion / Exclusion

        if (Input.GetKeyUp(KeyCode.Alpha4))
            targetCanvas.worldCamera = blurController.ExclusionCamera;

        if (Input.GetKeyUp(KeyCode.Alpha5))
            targetCanvas.worldCamera = Camera.main;

        #endregion
    }
}
