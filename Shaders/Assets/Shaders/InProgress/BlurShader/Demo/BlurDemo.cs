using UnityEngine;

public class BlurDemo : MonoBehaviour
{
    [SerializeField]
    private BlurEffect blurEffect;
    
    private void Update()
    {
        if(Input.GetKeyUp(KeyCode.A))
            blurEffect.ToggleBlur(true);
        
        if(Input.GetKeyUp(KeyCode.S))
            blurEffect.ToggleBlur(false);
    }
}
