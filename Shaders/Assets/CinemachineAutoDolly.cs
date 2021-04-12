using Cinemachine;
using UnityEngine;

public class CinemachineAutoDolly : MonoBehaviour
{
    [SerializeField] private float speed;
    
    private CinemachineTrackedDolly trackedDolly;
    
    private void Awake()
    {
        trackedDolly = GetComponent<CinemachineVirtualCamera>().GetCinemachineComponent<CinemachineTrackedDolly>();
    }

    private void Update()
    {
        trackedDolly.m_PathPosition += Time.deltaTime * speed;
    }
}
