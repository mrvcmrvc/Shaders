using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class TexturedShineShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[2]
    {
        new ShaderGUISectionData("Transform", "_ShineLocation", "_XMovement", "_YMovement"),
        new ShaderGUISectionData("Visual", "_ShineTexture", "_ShineMask", "_ShineGlow", "_ShineColor")
    };
}
