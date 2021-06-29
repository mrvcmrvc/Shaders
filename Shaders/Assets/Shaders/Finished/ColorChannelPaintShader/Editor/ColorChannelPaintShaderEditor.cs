using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class ColorChannelPaintShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[2]
    {
        new ShaderGUISectionData("Main Channels", "_RColor", "_GColor", "_BColor"),
        new ShaderGUISectionData("Channel Combinations", "_RGColor", "_RBColor", "_GBColor")
    };
}