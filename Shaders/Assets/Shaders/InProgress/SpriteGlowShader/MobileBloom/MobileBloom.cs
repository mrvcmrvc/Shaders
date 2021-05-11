using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class MobileBloom : MonoBehaviour{
    [Range(1, 5)]
    public int NumberOfPasses = 3;
    [Range(0, 5)]
    public float BlurAmount = 2f;
    public Color BloomColor = Color.white;
    [Range(0, 5)]
    public float BloomAmount = 1f;
	[Range(0, 1)]
	public float BloomThreshold = 0.2f;

    static readonly int blurAmountString = Shader.PropertyToID("_BlurAmount");
    static readonly int bloomColorString = Shader.PropertyToID("_BloomColor");
    static readonly int blAmountString = Shader.PropertyToID("_BloomAmount");
	static readonly int thresholdString = Shader.PropertyToID("_Threshold");
    static readonly int bloomTexString = Shader.PropertyToID("_BloomTex");

    public Material material=null;

	void  OnRenderImage (RenderTexture source ,   RenderTexture destination){

        material.SetFloat(blurAmountString, BlurAmount);
        material.SetColor(bloomColorString, BloomColor);
        material.SetFloat(blAmountString, BloomAmount);
		material.SetFloat(thresholdString, BloomThreshold);

        RenderTexture bloomTex = null;

        if (NumberOfPasses == 1 || BlurAmount == 0)
        {
            bloomTex = RenderTexture.GetTemporary(Screen.width / 2, Screen.height / 2, 0, source.format);
            Graphics.Blit(source, bloomTex, material, 0);
        }
        else if (NumberOfPasses == 2)
        {
            bloomTex = RenderTexture.GetTemporary(Screen.width / 2, Screen.height / 2, 0, source.format);
            var temp1 = RenderTexture.GetTemporary(Screen.width / 4, Screen.height / 4, 0, source.format);
            Graphics.Blit(source, temp1, material, 0);
            Graphics.Blit(temp1, bloomTex, material, 1);
            RenderTexture.ReleaseTemporary(temp1);
        }
        else if (NumberOfPasses == 3)
        {
            bloomTex = RenderTexture.GetTemporary(Screen.width / 4, Screen.height / 4, 0, source.format);
            var temp1 = RenderTexture.GetTemporary(Screen.width / 8, Screen.height / 8, 0, source.format);
            Graphics.Blit(source, bloomTex, material, 0);
            Graphics.Blit(bloomTex, temp1, material, 1);
            Graphics.Blit(temp1, bloomTex, material, 1);
            RenderTexture.ReleaseTemporary(temp1);
        }
        else if (NumberOfPasses == 4)
        {
            bloomTex = RenderTexture.GetTemporary(Screen.width / 8, Screen.height / 8, 0, source.format);
            var temp1 = RenderTexture.GetTemporary(Screen.width / 16, Screen.height / 16, 0, source.format);
            var temp2 = RenderTexture.GetTemporary(Screen.width / 4, Screen.height / 4, 0, source.format);
            Graphics.Blit(source, temp2, material, 0);
            Graphics.Blit(temp2, bloomTex, material, 1);
            Graphics.Blit(bloomTex, temp1, material, 1);
            Graphics.Blit(temp1, bloomTex, material, 1);
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }
        else if (NumberOfPasses == 5)
        {
            bloomTex = RenderTexture.GetTemporary(Screen.width / 4, Screen.height / 4, 0, source.format);
            var temp1 = RenderTexture.GetTemporary(Screen.width / 8, Screen.height / 8, 0, source.format);
            var temp2 = RenderTexture.GetTemporary(Screen.width / 16, Screen.height / 16, 0, source.format);
            Graphics.Blit(source, bloomTex, material, 0);
            Graphics.Blit(bloomTex, temp1, material, 1);
            Graphics.Blit(temp1, temp2, material, 1);
            Graphics.Blit(temp2, temp1, material, 1);
            Graphics.Blit(temp1, bloomTex, material, 1);
            RenderTexture.ReleaseTemporary(temp1);
            RenderTexture.ReleaseTemporary(temp2);
        }

        material.SetTexture(bloomTexString, bloomTex);
        RenderTexture.ReleaseTemporary(bloomTex);

        Graphics.Blit(source, destination, material, 2);
    }
}
