
//逐像素的半兰伯特漫反射光照
Shader "MyShader/Chapter6/HalfLambert"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;  //漫反射系数

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;  //法线的世界空间方向
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				
				//顶点法线方向
				fixed3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldNormal = worldNormal;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//在片元着色器里计算漫反射

				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//光源入射方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//漫反射颜色
				fixed halfLambert = dot(worldNormal,worldLightDir) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}

