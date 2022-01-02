using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Graphic))]
public class FillBarScript : MonoBehaviour
{
    private class FillData
    {
        public float StartingValue;
        public float TargetValue;
        public float CurrentTime;
        public float TargetDuration;
    }
    
    private static readonly int MainFillPropertyID = Shader.PropertyToID("_MainBarFill");
    private static readonly int IncreaseFillPropertyID = Shader.PropertyToID("_IncreaseFill");
    private static readonly int DecreaseFillPropertyID = Shader.PropertyToID("_DecreaseFill");

    [SerializeField]
    private Graphic graphic;
    [SerializeField]
    private float fullBarIncreaseDuration;
    [SerializeField]
    private float fullBarDecreaseDuration;

    private Dictionary<int, FillData> propertyIDToFillValue = new Dictionary<int, FillData>()
    {
        { MainFillPropertyID, new FillData() },
        { IncreaseFillPropertyID, new FillData() },
        { DecreaseFillPropertyID, new FillData() },
    };

    private void Awake()
    {
        UpdateFillData(MainFillPropertyID, graphic.material.GetFloat(MainFillPropertyID), 0f);
        UpdateFillData(IncreaseFillPropertyID, graphic.material.GetFloat(IncreaseFillPropertyID), 0f);
        UpdateFillData(DecreaseFillPropertyID, graphic.material.GetFloat(DecreaseFillPropertyID), 0f);
    }

    private void Update()
    {
        UpdateFill(MainFillPropertyID);
        UpdateFill(IncreaseFillPropertyID);
        UpdateFill(DecreaseFillPropertyID);
        
        //Basic Tests
        if (Input.GetKeyDown(KeyCode.Q))
            SetBarTo(0.6f);
        if (Input.GetKeyDown(KeyCode.A))
            SetBarTo(0.4f);
        
        // Full / Empty
        if (Input.GetKeyDown(KeyCode.E))
            SetBarTo(1f);
        if (Input.GetKeyDown(KeyCode.D))
            SetBarTo(0f);
        
        //ComplexTests
        if (Input.GetKeyDown(KeyCode.W))
            SetBarTo(0.7f);
        if (Input.GetKeyDown(KeyCode.S))
            SetBarTo(0.3f);
        
        // Q -> A Main & Increase Fill Drop
        // W -> Q Main & Increase Fill Drop
    }

    private void UpdateFill(int propertyID)
    {
        FillData targetFillData = propertyIDToFillValue[propertyID];

        if (Math.Abs(targetFillData.CurrentTime - targetFillData.TargetDuration) < Mathf.Epsilon)
            return;

        float newCurrentValue = Mathf.Lerp(targetFillData.StartingValue,
            targetFillData.TargetValue,
            targetFillData.CurrentTime / targetFillData.TargetDuration);
        
        graphic.material.SetFloat(propertyID, newCurrentValue);

        targetFillData.CurrentTime = Mathf.Min(targetFillData.CurrentTime + Time.smoothDeltaTime, targetFillData.TargetDuration);

        if (Math.Abs(targetFillData.CurrentTime - targetFillData.TargetDuration) < Mathf.Epsilon)
            SetFloat(targetFillData.TargetValue, propertyID);
    }

    /// <summary>
    /// Sets fill bar to given value
    /// </summary>
    /// <param name="normalizedValue">Target value between 0 and 1</param>
    /// <param name="instant">Should fill instantly?</param>
    public void SetBarTo(float normalizedValue, bool instant = false)
    {
        float fillDirection = GetFillDirection(normalizedValue);

        switch (fillDirection)
        {
            case -1:
                DecreaseFillBarTo(normalizedValue, instant);
                break;
            case 1:
                IncreaseFillBarTo(normalizedValue, instant);
                break;
        }
    }
    
    private float GetFillDirection(float targetValue)
    {
        float currentValue = graphic.material.GetFloat(IncreaseFillPropertyID);

        if (Math.Abs(targetValue - currentValue) < Mathf.Epsilon)
            return 0f;

        return Mathf.Sign(targetValue - currentValue);
    }

    private void DecreaseFillBarTo(float normalizedValue, bool instant)
    {
        UpdateFillData(MainFillPropertyID, normalizedValue, fullBarDecreaseDuration);
        UpdateFillData(IncreaseFillPropertyID, normalizedValue, fullBarDecreaseDuration);
        UpdateFillData(DecreaseFillPropertyID, normalizedValue, fullBarDecreaseDuration);
        
        SetFloat(normalizedValue, DecreaseFillPropertyID);
        
        if (instant)
            SetFloat(normalizedValue, MainFillPropertyID, IncreaseFillPropertyID);
    }

    private void IncreaseFillBarTo(float normalizedValue, bool instant)
    {
        UpdateFillData(MainFillPropertyID, normalizedValue, fullBarIncreaseDuration);
        UpdateFillData(IncreaseFillPropertyID, normalizedValue, fullBarIncreaseDuration);
        UpdateFillData(DecreaseFillPropertyID, normalizedValue, fullBarIncreaseDuration);
        
        SetFloat(normalizedValue, IncreaseFillPropertyID, DecreaseFillPropertyID);
        
        if (instant)
            SetFloat(normalizedValue, MainFillPropertyID);
    }

    private void UpdateFillData(int propertyID, float targetValue, float maxDuration)
    {
        FillData targetFillData = propertyIDToFillValue[propertyID];
        
        targetFillData.StartingValue = graphic.material.GetFloat(propertyID);
        targetFillData.TargetValue = targetValue;
        targetFillData.CurrentTime = 0f;
        targetFillData.TargetDuration = Mathf.Abs(targetFillData.StartingValue - targetValue) * maxDuration;
    }

    private void SetFloat(float value, params int[] propertyIDs)
    {
        for (int i = 0; i < propertyIDs.Length; i++)
        {
            int propertyID = propertyIDs[i];
            
            graphic.material.SetFloat(propertyID, value);
            propertyIDToFillValue[propertyID].StartingValue = value;
        }
    }
}