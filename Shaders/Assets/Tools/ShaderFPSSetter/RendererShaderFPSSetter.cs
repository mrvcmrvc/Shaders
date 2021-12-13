using UnityEngine;

namespace Shaders.ShaderFPSSetter
{
    public class RendererShaderFPSSetter : ShaderFPSSetterBase
    {
        [SerializeField]
        private Renderer targetRenderer;

        protected override Material targetMaterial => targetRenderer.material;
    }
}
