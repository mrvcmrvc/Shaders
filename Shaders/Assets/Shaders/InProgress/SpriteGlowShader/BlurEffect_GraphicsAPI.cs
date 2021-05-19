using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BlurEffect_GraphicsAPI : MonoBehaviour
{
    [SerializeField]
    private Material bloomMaterial;
    
    [SerializeField]
    private Shader bloomShader;
    
    [SerializeField, Range(1, 16)]
    private int downsampleCount = 1;
    
    private RenderTexture[] textures = new RenderTexture[16];

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(bloomMaterial == null)
            return;
        
        int width = src.width >> 1;
        int height = src.height >> 1;
        
        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, src.format);
            
        Graphics.Blit(src, currentDestination, bloomMaterial);
        RenderTexture currentSource = currentDestination;

        int currentIterationIndex = 1;
        for (; currentIterationIndex < downsampleCount; currentIterationIndex++)
        {
            width >>= 1;
            height >>= 1;
            
            if(width < 2 || height < 2)
                break;

            currentDestination = textures[currentIterationIndex] = RenderTexture.GetTemporary(width, height, 0, src.format);
            
            Graphics.Blit(currentSource, currentDestination, bloomMaterial);
                        
            currentSource = currentDestination;
        }

        for (currentIterationIndex -= 2;  currentIterationIndex >= 0; currentIterationIndex--)
        {
            currentDestination = textures[currentIterationIndex];
            textures[currentIterationIndex] = null;
            
            Graphics.Blit(currentSource, currentDestination, bloomMaterial);
            
            RenderTexture.ReleaseTemporary(currentSource);

            currentSource = currentDestination;
        }
        
        Graphics.Blit(currentSource, dest, bloomMaterial);
        
        RenderTexture.ReleaseTemporary(currentDestination);
        RenderTexture.ReleaseTemporary(currentSource);
    }
}
