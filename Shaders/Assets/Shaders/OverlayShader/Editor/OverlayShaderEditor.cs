using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class OverlayShaderEditor : ShaderGUIBase
{
    protected override ShaderGUISectionData[] shaderSectionData { get; } = new ShaderGUISectionData[1]
    {
        new ShaderGUISectionData("Glow", "_Glow")
    };
}
