
//逐像素的高光反射光照
Shader "MyShader/Chapter6/SpecularPixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
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

			fixed4 _Diffuse;  //漫反射颜色
			fixed4 _Specular;  //高光颜色
			float _Gloss;  //高光区域

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;  //法线的世界空间方向
				float3 worldPos : TEXCOORD1;  //顶点的世界坐标
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

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
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//光源出射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));

				//视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}

