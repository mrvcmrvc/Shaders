using Shaders.Editor;

public class GrayscaleShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[1]
    {
        new ShaderGUISectionData("Effect", "_RedChannelBrightness", "_GreenChannelBrightness", "_BlueChannelBrightness", "_GrayScaleAmount")
    };
}