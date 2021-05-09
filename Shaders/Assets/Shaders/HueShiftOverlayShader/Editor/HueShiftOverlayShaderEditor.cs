using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class HueShiftOverlayShaderEditor : ShaderGUIBase
{
    private static readonly string[] lightAreaShiftProperties = new string[2]
    {
        "_HueChangeLit",
        "_SaturationChangeLit"
    };

    private static readonly string[] darkAreaShiftProperties = new string[2]
    {
        "_HueChangeUnlit",
        "_SaturationChangeUnlit"
    };

    private static readonly string[] overlayGlowProperties = new string[1]
    {
        "_OverlayGlow"
    };
    
    protected override void OnGUICustomActions()
    {
        DrawSection("Light Shift", lightAreaShiftProperties);
        DrawSection("Dark Shift", darkAreaShiftProperties);
        DrawSection("Glow", overlayGlowProperties);
    }
}
