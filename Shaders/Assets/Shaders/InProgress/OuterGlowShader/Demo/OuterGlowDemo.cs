using UnityEngine;

public class OuterGlowDemo : MonoBehaviour
{
    [SerializeField]
    private OuterGlowController outerGlowController;

    private void Awake()
    {
        Application.targetFrameRate = 60;
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.A))
            outerGlowController.SetActive(!outerGlowController.enabled);
    }
}
