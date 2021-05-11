using System;

namespace Shaders.Editor
{
    [Serializable]
    public class ShaderGUISectionData
    {
        private string header;
        public string Header => header;
        
        private string[] properties;
        public string[] Properties => properties;
        
        public ShaderGUISectionData(string header, params string[] properties)
        {
            this.header = header;
            this.properties = properties;
        }
    }
}
