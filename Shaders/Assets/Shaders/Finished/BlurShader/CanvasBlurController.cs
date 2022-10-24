using UnityEngine;

[RequireComponent(typeof(Canvas))]
public class CanvasBlurController : MonoBehaviour
{
    private Canvas canvas;
    private Camera originCamera;
    private BlurController blurController;
    
    private void Awake()
    {
        canvas = GetComponent<Canvas>();
        blurController = FindObjectOfType<BlurController>();
    }

    private void Start()
    {
        if (!blurController)
            return;
        
        originCamera = canvas.worldCamera;
        SetCameraBasedOnBlur();
        
        blurController.OnBlurStackUpdatedEvent += OnBlurStackUpdated;
    }

    private void OnDestroy()
    {
        if (!blurController)
            return;

        blurController.OnBlurStackUpdatedEvent -= OnBlurStackUpdated;
    }
    
    private void OnBlurStackUpdated() => SetCameraBasedOnBlur();

    private void SetCameraBasedOnBlur()
    {
        if (blurController.IsActive && blurController.ShouldBlurEverything)
            canvas.worldCamera = Camera.main;
        else if (blurController.IsActive)
            canvas.worldCamera = blurController.ExclusionCamera;
        else
            canvas.worldCamera = originCamera;
    }
}