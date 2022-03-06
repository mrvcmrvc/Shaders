using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class TexturedShineShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[2]
    {
        new ShaderGUISectionData("Transform", "_Enable", "_XSpeed", "_YSpeed", "_Delay"),
        new ShaderGUISectionData("Visual", "_ShineMask", "_ShineTexture", "_ImageType", "_ShineColor", "_Glow")
    };

    protected override string[] additionalRenderingProperties { get; } = new string[1]
    {
        "_Blending"
    };
}
