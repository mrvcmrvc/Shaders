using System.Collections.Generic;
using UnityEngine;

public class ToggleObjects : MonoBehaviour
{
    public List<GameObject> Objects;

    private bool isActivePrev = true;
    private bool isActive = true;
    
    void Toggle()
    {
        isActive = !isActive;
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
            Toggle();

        if(isActivePrev == isActive)
            return;

        isActivePrev = isActive;
        
        UpdateVisibility();
    }

    private void UpdateVisibility()
    {
        Objects.ForEach(obj => obj.SetActive(isActive));
    }
}
