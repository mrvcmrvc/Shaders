using UnityEngine;
using UnityEngine.UI;

namespace Shaders.ShaderFPSSetter
{
    public class UIShaderFPSSetter : ShaderFPSSetterBase
    {
        [SerializeField]
        private Image targetImage;
   
        protected override Material targetMaterial => targetImage.material;
    }
}