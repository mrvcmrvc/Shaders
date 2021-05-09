using JetBrains.Annotations;
using Shaders.Editor;
using UnityEditor;

[CanEditMultipleObjects]
[UsedImplicitly]
public class OverlayShaderEditor : ShaderGUIBase
{
    private static readonly string[] overlayGlowProperties = new string[1]
    {
        "_Glow"
    };
    
    protected override void OnGUICustomActions()
    {
        DrawSection("Glow", overlayGlowProperties);
    }
}
