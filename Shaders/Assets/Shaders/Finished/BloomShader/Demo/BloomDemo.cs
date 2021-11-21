﻿using UnityEngine;

public class BloomDemo : MonoBehaviour
{
    [SerializeField]
    private BloomController bloomController;

    private void Awake()
    {
        Application.targetFrameRate = 60;
    }

    private void Update()
    {
        if (Input.GetKeyUp(KeyCode.A))
            bloomController.SetActive(true);
        
        if (Input.GetKeyUp(KeyCode.D))
            bloomController.SetActive(false);
    }
}
