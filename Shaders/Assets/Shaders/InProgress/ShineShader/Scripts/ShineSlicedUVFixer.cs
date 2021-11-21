using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShineSlicedUVFixer : BaseMeshEffect
{
    private Vector2 size = Vector2.zero;
    private Vector2 Size
    {
        get
        {
            if (size == Vector2.zero)
                size = GetComponent<RectTransform>().rect.size;

            return size;
        }
    }

    public override void ModifyMesh(VertexHelper vh)
    {
        if (!isActiveAndEnabled)
            return;
        
        //vh.Clear();

        UIVertex vertex = UIVertex.simpleVert;
        int indexBL = vh.currentVertCount;
        List<Vector2> targetUVs = new List<Vector2>
        {
            Vector2.zero,
            Vector2.up,
            Vector2.one,
            Vector2.right,
        };
        
        // vh.PopulateUIVertex(ref vertex, 0);
        // vertex.uv3 = targetUVs[0];
        // vh.SetUIVertex(vertex, 0);
        //
        // vh.PopulateUIVertex(ref vertex, 9);
        // vertex.uv3 = targetUVs[1];
        // vh.SetUIVertex(vertex, 9);
        //
        // vh.PopulateUIVertex(ref vertex, 34);
        // vertex.uv3 = targetUVs[2];
        // vh.SetUIVertex(vertex, 34);
        //
        // vh.PopulateUIVertex(ref vertex, 27);
        // vertex.uv3 = targetUVs[3];
        // vh.SetUIVertex(vertex, 27);
        //
        // vh.AddTriangle(0, 9, 34);
        // vh.AddTriangle(34, 27, 0);
        
        for (int i = 0; i < targetUVs.Count; i++)
        {
            vertex.normal = Vector3.back;
            vertex.uv3 = targetUVs[i];
            vertex.position = new Vector3(
                (-Size.x / 2f) + (Size.x * vertex.uv3.x),
                (-Size.y / 2f) + (Size.y * vertex.uv3.y),
                0f);
            
            vh.AddVert(vertex);
            
            vertex = UIVertex.simpleVert;
        }
        
        vh.AddTriangle(indexBL, indexBL + 1, indexBL + 2);
        vh.AddTriangle(indexBL + 2, indexBL + 3, indexBL);
    }
}