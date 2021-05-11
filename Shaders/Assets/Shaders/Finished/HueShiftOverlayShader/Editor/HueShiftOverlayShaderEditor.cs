using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class HueShiftOverlayShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[3]
    {
        new ShaderGUISectionData("Light Shift", "_HueChangeLit", "_SaturationChangeLit"),
        new ShaderGUISectionData("Dark Shift", "_HueChangeUnlit", "_SaturationChangeUnlit"),
        new ShaderGUISectionData("Glow", "_OverlayGlow")
    };
}
