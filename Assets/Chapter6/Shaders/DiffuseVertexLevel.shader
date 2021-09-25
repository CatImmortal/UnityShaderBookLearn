
//逐顶点的漫反射光照
Shader "MyShader/Chapter6/DiffuseVertexLevel"
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

			fixed4 _Diffuse;  

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : Color;
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				
				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//顶点法线方向
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				//光源入射方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}

