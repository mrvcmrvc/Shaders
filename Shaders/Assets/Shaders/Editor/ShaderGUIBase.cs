using Shaders.Editor.Exceptions;
using UnityEditor;
using UnityEngine;

namespace Shaders.Editor
{
    public abstract class ShaderGUIBase : ShaderGUI
    {
        protected abstract ShaderGUISectionData[] shaderSectionData { get; }
        protected virtual string[] additionalRenderingProperties { get; }

        private Material targetMaterial;
        private Material originalMaterialCopy;
        private MaterialEditor materialEditor;
        private MaterialProperty[] materialProperties;
    
        private GUIStyle labelStyle;
        private const int fontSize = 14;
        
        protected virtual bool CanDrawRenderingProperties()
        {
            return true;
        }
    
        public sealed override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Setup(materialEditor, properties);

            DrawSections();

            if (CanDrawRenderingProperties())
                DrawRenderingProperties();
        }

        private void DrawSections()
        {
            for (int i = 0; i < shaderSectionData.Length; i++)
                DrawSection(shaderSectionData[i].Header, shaderSectionData[i].Properties);
        }

        private void DrawRenderingProperties()
        {
            GUILayout.Label("Rendering Settings", labelStyle);

            if(targetMaterial.HasProperty("_UseUIAlphaClip"))
                DrawProperty(GetPropertyIndex("_UseUIAlphaClip"));

            EditorGUI.indentLevel++;
            materialEditor.RenderQueueField();
            EditorGUI.indentLevel--;

            if (additionalRenderingProperties != null && additionalRenderingProperties.Length > 0)
                DrawAdditionalRenderingSectionData();
        }

        private void DrawAdditionalRenderingSectionData()
        {
            for (int i = 0; i < additionalRenderingProperties.Length; i++)
                DrawProperty(GetPropertyIndex(additionalRenderingProperties[i]));
        }

        private void Setup(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            this.materialEditor = materialEditor;
            materialProperties = properties;
            targetMaterial = materialEditor.target as Material;

            labelStyle = new GUIStyle(EditorStyles.boldLabel)
            {
                fontSize = fontSize
            };
        }

        private void DrawSection(string header, params string[] propertyIndexes)
        {
            GUILayout.Label(header, labelStyle);

            for (int i = 0; i < propertyIndexes.Length; i++)
                DrawProperty(GetPropertyIndex(propertyIndexes[i]));
        
            DrawLine(Color.grey, 1, 3);
            EditorGUILayout.Separator();
        }
    
        private int GetPropertyIndex(string propertyName)
        {
            for (int i = 0; i < materialProperties.Length; i++)
            {
                if (materialProperties[i].name == propertyName)
                    return i;
            }

            throw new PropertyCouldNotFoundException(propertyName, targetMaterial.shader);
        }
    
        private void DrawProperty(int index)
        {
            MaterialProperty targetProperty = materialProperties[index];

            EditorGUILayout.BeginHorizontal();
            EditorGUI.indentLevel++;

            GUIContent propertyLabel = new GUIContent
            {
                text = targetProperty.displayName
            };

            materialEditor.ShaderProperty(targetProperty, propertyLabel);

            DrawPropertyCopyButton(targetProperty);
            DrawResetButton(targetProperty);
        
            EditorGUI.indentLevel--;
            EditorGUILayout.EndHorizontal();
        }

        private void DrawResetButton(MaterialProperty targetProperty)
        {
            GUIContent buttonLabel = new GUIContent
            {
                text = "R",
                tooltip = "Resets to default value"
            };
            
            if (GUILayout.Button(buttonLabel, GUILayout.Width(20)))
                ResetProperty(targetProperty);
        }
        
        private void DrawPropertyCopyButton(MaterialProperty targetProperty)
        {
            GUIContent buttonLabel = new GUIContent
            {
                text = "C",
                tooltip = "Copies property name to clipboard"
            };
            
            if (GUILayout.Button(buttonLabel, GUILayout.Width(20)))
                CopyPropertyNameToClipboard(targetProperty);
        }
    
        private void ResetProperty(MaterialProperty targetProperty)
        {
            if (originalMaterialCopy == null)
                originalMaterialCopy = new Material(targetMaterial.shader);

            switch (targetProperty.type)
            {
                case MaterialProperty.PropType.Float:
                case MaterialProperty.PropType.Range:
                    targetProperty.floatValue = originalMaterialCopy.GetFloat(targetProperty.name);
                    break;
                case MaterialProperty.PropType.Vector:
                    targetProperty.vectorValue = originalMaterialCopy.GetVector(targetProperty.name);
                    break;
                case MaterialProperty.PropType.Color:
                    targetProperty.colorValue = originalMaterialCopy.GetColor(targetProperty.name);
                    break;
                case MaterialProperty.PropType.Texture:
                    targetProperty.textureValue = originalMaterialCopy.GetTexture(targetProperty.name);
                    break;
                default:
                    throw new ResetNotDefinedException(targetProperty.type);
            }
            
            EditorUtility.SetDirty(targetMaterial);
        }
        
        private void CopyPropertyNameToClipboard(MaterialProperty targetProperty)
        {
            TextEditor textEditor = new TextEditor
            {
                text = targetProperty.name
            };
            
            textEditor.SelectAll();
            textEditor.Copy();
        }
    
        private static void DrawLine(Color color, int thickness = 2, int padding = 10)
        {
            Rect r = EditorGUILayout.GetControlRect(GUILayout.Height(padding + thickness));
            r.height = thickness;
            r.y += (padding / 2f);
            r.x -= 2;
            r.width += 6;
            EditorGUI.DrawRect(r, color);
        }
    }
}
