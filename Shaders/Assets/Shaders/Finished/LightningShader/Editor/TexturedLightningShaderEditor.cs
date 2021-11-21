using Shaders.Editor;

public class TexturedLightningShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[3]
    {
        new ShaderGUISectionData("Lightning", "_LightningTexture"),
        new ShaderGUISectionData("Noise", "_Noise", "_NoiseStrength", "_Speed", "_LightningColor"),
        new ShaderGUISectionData("UV", "_NoiseOffset", "_EdgeConstraintScale", "_EdgeInnerOffset",
            "_EdgeOuterOffset", "_RadialScale", "_RadialScaleCenter", "_RadialOffsetStrength"),
    };
}
