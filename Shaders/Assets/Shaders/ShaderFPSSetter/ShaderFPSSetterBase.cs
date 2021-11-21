using UnityEngine;

namespace Shaders.ShaderFPSSetter
{
    public abstract class ShaderFPSSetterBase : MonoBehaviour
    {
        [SerializeField, Range(1, 60)]
        private int targetFPS = 60;
        [SerializeField]
        private string timePropertyName;
    
        private float curTime;
        private int remainingFramePerRender;

        protected abstract Material targetMaterial { get; }
    
        private void Awake()
        {
            curTime = 0f;
            remainingFramePerRender = 60 / targetFPS;
        }

        private void Update()
        {
            remainingFramePerRender--;

            if (remainingFramePerRender != 0)
                return;
            
            remainingFramePerRender = 60 / targetFPS;
            curTime += Time.deltaTime;
            
            UpdateShader();
        }

        private void UpdateShader()
        {
            targetMaterial.SetFloat(timePropertyName, curTime);
        }
    }
}