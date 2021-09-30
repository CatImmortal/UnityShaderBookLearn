using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 修改亮度，饱和度和对比度的屏幕后处理
/// </summary>
public class BrightnessSaturationAndContrast : PostEffectsBase {

    [Range(0.0f,3.0f)]
    public float Brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float Contrast = 1.0f;

	public Shader briSatConShader;

	private Material briSatConMat;
	public Material Mat
    {
        get
        {
            briSatConMat = CheckShaderAndCreateMaterial(briSatConShader, briSatConMat);
            return briSatConMat;
        }
    }
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat != null)
        {
            Mat.SetFloat("_Brightness", Brightness);
            Mat.SetFloat("_Saturation", Saturation);
            Mat.SetFloat("_Contrast", Contrast);

            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
    
}
