using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class SpriteEmissionShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[1]
    {
        new ShaderGUISectionData("Emission", "_Emission", "_HDR")
    };
}
