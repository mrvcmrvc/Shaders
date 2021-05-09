using System;
using UnityEngine;

namespace Shaders.Editor.Exceptions
{
    public class PropertyCouldNotFoundException : Exception
    {
        private readonly string propertyName;
        private readonly string targetShaderName;
        
        public override string Message => $"Property {propertyName} could not be found in {targetShaderName}";

        public PropertyCouldNotFoundException(string propertyName, Shader targetMaterialShader)
        {
            this.propertyName = propertyName;
            targetShaderName = targetMaterialShader.name;
        }
    }
}
