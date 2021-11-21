using Shaders.Editor;

public class GenericLightningShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[3]
    {
        new ShaderGUISectionData("Transform", "_Width", "_Height"),
        new ShaderGUISectionData("Noise", "_Noise", "_NoiseStrength", "_Speed", "_LightningColor"),
        new ShaderGUISectionData("UV", "_NoiseOffset", "_EdgeConstraintScale", "_EdgeInnerOffset",
            "_EdgeOuterOffset", "_RadialScale", "_RadialScaleCenter", "_RadialOffsetStrength"),
    };
}
