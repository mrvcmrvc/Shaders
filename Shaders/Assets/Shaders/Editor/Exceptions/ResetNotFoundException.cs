using System;
using UnityEditor;

namespace Shaders.Editor.Exceptions
{
    public class ResetNotDefinedException : Exception
    {
        private readonly MaterialProperty.PropType propertyType;
        
        public override string Message => $"Reset is not defined for this type: {propertyType}";

        public ResetNotDefinedException(MaterialProperty.PropType propertyType)
        {
            this.propertyType = propertyType;
        }
    }
}
