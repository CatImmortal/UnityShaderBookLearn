using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 边缘检测的屏幕后处理
/// </summary>
public class EdgeDetection : PostEffectsBase
{
    public float EdgesOnly = 0.0f;

    public Color EdgeColor = Color.black;

    public Color BackgroundColor = Color.white;

    public Shader EdgeDetectShader;

    private Material EdgeDetectMat;
    public Material Mat
    {
        get
        {
            EdgeDetectMat = CheckShaderAndCreateMaterial(EdgeDetectShader, EdgeDetectMat);
            return EdgeDetectMat;
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Mat != null)
        {
            Mat.SetFloat("_EdgeOnly", EdgesOnly);
            Mat.SetColor("_EdgeColor", EdgeColor);
            Mat.SetColor("_BackgroundColor", BackgroundColor);

            Graphics.Blit(src, dest, Mat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

}
