using System.Collections;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class PostProcessManager : MonoBehaviour
{
    [SerializeField] 
    private PostProcessVolume postProcessVolume;
    
    [SerializeField] 
    private PostProcessLayer postProcessLayer;

    private IEnumerator Start()
    {
        // Allow one frame for post processing initialization during boot time
        yield return null;
        TogglePostProcess(false);
    }

    private void Update()
    {
        if(Input.GetMouseButtonUp(0))
            TogglePostProcess(!postProcessVolume.enabled);
    }

    public void TogglePostProcess(bool isActive)
    {
        postProcessVolume.enabled  = isActive;
        postProcessLayer.enabled = isActive;
    }
}
