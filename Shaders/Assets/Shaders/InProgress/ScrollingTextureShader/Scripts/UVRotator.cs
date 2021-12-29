using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UVRotator : BaseMeshEffect
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

    public float angle;
    public float aspectRatio;
    
    protected override void OnRectTransformDimensionsChange()
    {
        base.OnRectTransformDimensionsChange();
        
        enabled = false;
        size = Vector2.zero;
        enabled = true;
    }
    
    public override void ModifyMesh(VertexHelper vh)
    {
        if (!isActiveAndEnabled)
            return;
        
        ModifyExistingVertices(vh);
    }
    
    private void ModifyExistingVertices(VertexHelper vh)
    {
        UIVertex refVertex = UIVertex.simpleVert;
        int indexBL = vh.currentVertCount;

        float ratioRespectedY = Size.x * aspectRatio;
        
        float deltaX = 1 / ((ratioRespectedY / Size.x) * 2);
        float deltaY = ((ratioRespectedY / Size.x) - 1) / 2;
        
        // donen ustunden x hesapla
        // orjinal ustunden y hesapla
        
        for (int i = 0; i < indexBL; i++)
        {
            vh.PopulateUIVertex(ref refVertex, i);

            float remappedX = Remap(refVertex.position.x, -1 * Size.x / 2f, Size.x / 2f, 0.5f - deltaX, 0.5f + deltaX); // 1 / ((512 / 128) * 2) ; 0.375 - 0.625
            float remappedY = Remap(refVertex.position.y, -1 * ratioRespectedY / 2f, ratioRespectedY / 2f, -deltaY, 1 + deltaY); // ((512 / 128) - 1) / 2 ; -1.5 - +1.5
            
            refVertex.uv3 = new Vector2(remappedX, remappedY);
            
            vh.SetUIVertex(refVertex, i);
        }
    }
    
    private float Remap(float value, float from1, float to1, float from2, float to2)
    {
        return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
    }
}
