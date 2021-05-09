using Shaders.Editor.Exceptions;
using UnityEditor;
using UnityEngine;

namespace Shaders.Editor
{
    public abstract class ShaderGUIBase : ShaderGUI
    {    
        private Material targetMaterial;
        private Material originalMaterialCopy;
        private MaterialEditor materialEditor;
        private MaterialProperty[] materialProperties;
    
        private GUIStyle labelStyle;
        private const int fontSize = 14;
    
        protected abstract void OnGUICustomActions();

        protected virtual bool CanDrawRenderingProperties()
        {
            return true;
        }
    
        public sealed override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            Setup(materialEditor, properties);

            OnGUICustomActions();

            if (CanDrawRenderingProperties())
                DrawRenderingProperties();
        }

        private void DrawRenderingProperties()
        {
            GUILayout.Label("Rendering Settings", labelStyle);

            DrawProperty(8);

            EditorGUI.indentLevel++;
            materialEditor.RenderQueueField();
            EditorGUI.indentLevel--;
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

        protected void DrawSection(string header, params int[] propertyIndexes)
        {
            GUILayout.Label(header, labelStyle);

            for (int i = 0; i < propertyIndexes.Length; i++)
                DrawProperty(propertyIndexes[i]);
        
            DrawLine(Color.grey, 1, 3);
            EditorGUILayout.Separator();
        }
    
        protected void DrawSection(string header, params string[] propertyIndexes)
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

            DrawResetButton(targetProperty);
        
            EditorGUI.indentLevel--;
            EditorGUILayout.EndHorizontal();
        }

        private void DrawResetButton(MaterialProperty targetProperty)
        {
            GUIContent resetButtonLabel = new GUIContent
            {
                text = "R",
                tooltip = "Resets to default value"
            };
            
            if (GUILayout.Button(resetButtonLabel, GUILayout.Width(20)))
                ResetProperty(targetProperty);
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
