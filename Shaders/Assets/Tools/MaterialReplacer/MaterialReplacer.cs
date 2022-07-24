using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteAlways]
public class MaterialReplacer : MonoBehaviour
{
    [Serializable]
    private struct GraphicsData
    {
        public bool IsUIComponent => Graphic != null;

        public Graphic Graphic;
        public Renderer TargetRenderer;
        public Material OriginalMaterial;

        public void SetMaterial(Material material)
        {
            if (IsUIComponent)
                Graphic.material = material;
            else
                TargetRenderer.sharedMaterial = material;
        }
    }

    [SerializeField]
    private Material materialToApply;
    [SerializeField]
    private bool applyOnAwake;

    [SerializeField]
    private bool useOnlyList = false, excludeList = false;
    [SerializeField]
    private Transform[] targetTransforms;

    [SerializeField, HideInInspector]
    private GraphicsData[] graphicsData;

    [field: SerializeField, HideInInspector]
    public bool IsMaterialApplied { get; private set; } = false;

    private void OnValidate()
    {
        if (graphicsData.Length > 0)
            return;

        ResetTargets();

        Debug.Assert(graphicsData.Length > 0);
        Debug.Assert(useOnlyList && excludeList);
    }

    private void Awake()
    {
        if (!applyOnAwake)
            return;

        ApplyMaterial();
    }

    [ContextMenu("Reset Targets")]
    public void ResetTargets()
    {
        if (IsMaterialApplied)
            RevertMaterial();

        GraphicsData[] rendererData = GatherRenderers();
        GraphicsData[] uiGraphicData = GatherUIGraphic();

        graphicsData = new GraphicsData[rendererData.Length + uiGraphicData.Length];
        for (int i = 0; i < graphicsData.Length; i++)
        {
            if (i < rendererData.Length)
                graphicsData[i] = rendererData[i];
            else
                graphicsData[i] = uiGraphicData[i - rendererData.Length];
        }
    }

    [ContextMenu("Apply Material")]
    public void ApplyMaterial()
    {
        if (IsMaterialApplied)
            return;

        if (!CheckIfApplicable())
            return;

        IsMaterialApplied = true;

        for (int i = 0; i < graphicsData.Length; i++)
        {
            graphicsData[i].SetMaterial(materialToApply);
        }
    }

    [ContextMenu("Revert Material")]
    public void RevertMaterial()
    {
        if (!IsMaterialApplied)
            return;

        if (!CheckIfApplicable())
            return;

        IsMaterialApplied = false;

        for (int i = 0; i < graphicsData.Length; i++)
        {
            graphicsData[i].SetMaterial(graphicsData[i].OriginalMaterial);
        }
    }

    private GraphicsData[] GatherRenderers()
    {
        Renderer[] renderers = GatherByFiltering<Renderer>();

        GraphicsData[] result = new GraphicsData[renderers.Length];
        for (int i = 0; i < result.Length; i++)
        {
            result[i] = new GraphicsData()
            {
                Graphic = null,
                TargetRenderer = renderers[i],
                OriginalMaterial = renderers[i].sharedMaterial,
            };
        }

        return result;
    }

    private GraphicsData[] GatherUIGraphic()
    {
        Graphic[] uiGraphic = GatherByFiltering<Graphic>();

        GraphicsData[] result = new GraphicsData[uiGraphic.Length];
        for (int i = 0; i < result.Length; i++)
        {
            result[i] = new GraphicsData()
            {
                Graphic = uiGraphic[i],
                TargetRenderer = null,
                OriginalMaterial = uiGraphic[i].material,
            };
        }

        return result;
    }

    private bool CheckIfApplicable()
    {
        if (materialToApply == null)
            return false;

        if (graphicsData.Length == 0)
            return false;

        return true;
    }

    private T[] GatherByFiltering<T>() where T : Component
    {
        T[] result;

        if (!useOnlyList)
            result = GetComponentsInChildren<T>();
        else
        {
            List<T> resultList = new List<T>();
            for (int i = 0; i < targetTransforms.Length; i++)
            {
                T targetComponent = targetTransforms[i].GetComponent<T>();

                if (targetComponent == null)
                    continue;

                resultList.Add(targetComponent);
            }

            return resultList.ToArray();
        }

        if (excludeList)
        {
            List<T> resultList = new List<T>(result);
            for (int i = 0; i < targetTransforms.Length; i++)
            {
                T excludedItem = resultList.Find(
                    (T candidate) => candidate.transform == targetTransforms[i]);

                resultList.Remove(excludedItem);
            }

            return resultList.ToArray();
        }

        return result;
    }
}
