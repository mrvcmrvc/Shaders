using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class GenericShineShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[2]
    {
        new ShaderGUISectionData("Transform", "_Enable", "_Speed", "_Delay", "_ShineWidth", "_RotateAngle"),
        new ShaderGUISectionData("Visual", "_ShineMask", "_ShineGlow", "_ImageType", "_ShineColor")
    };
    
    protected override string[] additionalRenderingProperties { get; } = new string[1]
    {
        "_Blending"
    };
}
