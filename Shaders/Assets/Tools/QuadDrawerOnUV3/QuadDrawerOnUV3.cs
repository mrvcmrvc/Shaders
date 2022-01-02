using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class QuadDrawerOnUV3 : BaseMeshEffect
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

        for (int i = 0; i < indexBL; i++)
        {
            vh.PopulateUIVertex(ref refVertex, i);
            
            float remappedX = Remap(refVertex.position.x, -1 * Size.x / 2f, Size.x / 2f, 0, 1);
            float remappedY = Remap(refVertex.position.y, -1 * Size.y / 2f, Size.y / 2f, 0, 1);
            
            refVertex.uv3 = new Vector2(remappedX, remappedY);
            
            vh.SetUIVertex(refVertex, i);
        }
    }
    
    private float Remap(float value, float from1, float to1, float from2, float to2)
    {
        return (value - from1) / (to1 - from1) * (to2 - from2) + from2;
    }
}