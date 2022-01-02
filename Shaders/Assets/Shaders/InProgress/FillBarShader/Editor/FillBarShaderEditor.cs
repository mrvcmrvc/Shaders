using Shaders.Editor;

public class FillBarShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[4]
    {
        new ShaderGUISectionData("Transform", "_ImageType", "_EdgeAngle", "_LeftOffset", "_RightOffset"),
        new ShaderGUISectionData("Bar 1", "_BarMinPoint1", "_BarMaxPoint1"),
        new ShaderGUISectionData("Bar 2", "_BarTexture2", "_BarColor2", "_BarMinPoint2", "_BarMaxPoint2"),
        new ShaderGUISectionData("Bar 3", "_BarTexture3", "_BarColor3", "_BarMinPoint3", "_BarMaxPoint3")
    };

    protected override string[] additionalRenderingProperties { get; } = new string[1]
    {
        "_DrawOrder"
    };
}