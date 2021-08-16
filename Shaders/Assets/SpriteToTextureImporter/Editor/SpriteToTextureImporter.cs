using System.Collections.Generic;
using System.IO;
using PDNWrapper;
using Unity.Collections;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using UnityEditor.Sprites;
using UnityEditor.U2D;
using UnityEditorInternal;
using UnityEngine;

public class SpriteToTextureImporter : EditorWindow
{
    [MenuItem("Window/Sprite To Texture Exporter")]
    public static void OpenWindow () {
        EditorWindow.GetWindow<SpriteToTextureImporter>(true, "Sprite To Texture Exporter");
    }

    private Sprite source;
    private Texture2D sampleResult;

    private static GUIContent
	    sourceTextureContent = new GUIContent(
		    "Source Texture",
		    "The alpha channel of this texture is used to compute distances.");
    
    void OnEnable () {
        source = Selection.activeObject as Sprite;
    }
    
	void OnGUI () {
		GUILayout.BeginArea(new Rect(2f, 2f, 220f, position.height - 4f));

		EditorGUI.BeginChangeCheck();
		source = (Sprite)EditorGUILayout.ObjectField(sourceTextureContent, source, typeof(Sprite), false);

		if(sampleResult != null)
			EditorGUILayout.ObjectField(sourceTextureContent, sampleResult, typeof(Texture2D), false);

		if (source != null && GUILayout.Button("Sample Texture")) {
			sampleResult = GetTextureFromSprite(source);
		}
		if (source != null && GUILayout.Button("Save PNG file")) {
			SaveTexture();
		}
		
		GUILayout.EndArea();
	}

	private Texture2D GetTextureFromSprite(Sprite sprite)
	{
		Texture2D croppedTexture = new Texture2D((int)sprite.rect.width, (int)sprite.rect.height);
		Color[] pixels = sprite.texture.GetPixels(
			(int)sprite.textureRect.x, 
			(int)sprite.textureRect.y, 
			(int)sprite.textureRect.width, 
			(int)sprite.textureRect.height);

		croppedTexture.SetPixels(pixels);
		croppedTexture.Apply();

		return croppedTexture;
	}
	
	void SaveTexture () {
		string filePath = EditorUtility.SaveFilePanel(
			"Save Signed Distance Field",
			new FileInfo(AssetDatabase.GetAssetPath(source)).DirectoryName,
			source.name,
			"png");
		if (filePath.Length == 0) {
			return;
		}
		
		bool isNewTexture = !File.Exists(filePath);
		File.WriteAllBytes(filePath, sampleResult.EncodeToPNG());
		AssetDatabase.Refresh();
		
		if (isNewTexture) {
			int relativeIndex = filePath.IndexOf("Assets/");
			if (relativeIndex >= 0) {
				filePath = filePath.Substring(relativeIndex);
				TextureImporter importer = TextureImporter.GetAtPath(filePath) as TextureImporter;
				if (importer != null) {
					importer.textureType = TextureImporterType.Sprite;
					importer.textureCompression = TextureImporterCompression.Uncompressed;
					AssetDatabase.ImportAsset(filePath);
					return;
				}
			}
			Debug.LogWarning("Failed to setup exported texture as uncompressed single channel. You have to configure it manually.");
		}
	}
}

