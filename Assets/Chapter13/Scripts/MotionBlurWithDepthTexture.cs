using UnityEngine;
using System.Collections;

/// <summary>
/// 基于深度图的运动模糊
/// </summary>
public class MotionBlurWithDepthTexture : PostEffectsBase
{

	public Shader motionBlurShader;
	private Material motionBlurMaterial = null;

	public Material material
	{
		get
		{
			motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
			return motionBlurMaterial;
		}
	}

	private Camera myCamera;
	public new Camera camera
	{
		get
		{
			if (myCamera == null)
			{
				myCamera = GetComponent<Camera>();
			}
			return myCamera;
		}
	}

	[Range(0.0f, 1.0f)]
	public float blurSize = 0.5f;

	/// <summary>
	/// 上一帧摄像机的视角*投影矩阵
	/// </summary>
	private Matrix4x4 previousViewProjectionMatrix;

	void OnEnable()
	{
		camera.depthTextureMode |= DepthTextureMode.Depth;

		previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		if (material != null)
		{
			material.SetFloat("_BlurSize", blurSize);

			material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);

			//计算当前帧的视角*投影矩阵的逆矩阵
			Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;

			material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit(src, dest, material);
		}
		else
		{
			Graphics.Blit(src, dest);
		}
	}
}
