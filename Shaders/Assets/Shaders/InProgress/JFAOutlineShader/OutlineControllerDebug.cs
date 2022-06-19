using UnityEngine;

public class OutlineControllerDebug : MonoBehaviour
{
    public JFAOutlineController outlineController;
    
    private SpriteRenderer[] renderers;

    private void Awake()
    {
        renderers = GetComponentsInChildren<SpriteRenderer>();
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.S))
            foreach (SpriteRenderer spriteRenderer in renderers)
                outlineController.AddToOutline(spriteRenderer);
        
        if (Input.GetKeyUp(KeyCode.X))
            foreach (SpriteRenderer spriteRenderer in renderers)
                outlineController.RemoveFromOutline(spriteRenderer);
        
        if (Input.GetKeyUp(KeyCode.A))
            outlineController.SetActive(true);
        
        if (Input.GetKeyUp(KeyCode.D))
            outlineController.SetActive(false);
    }
}
