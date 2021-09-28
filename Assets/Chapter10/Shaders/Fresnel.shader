//菲涅尔反射
Shader "MyShader/Chapter10/Fresnel"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_ReflectColor("Refract Color",Color) = (1,1,1,1)  
		_FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
		_Cubemap("Reflection Cubemap",Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				fixed3 worldViewDir : TEXCOORD2;
				fixed3 worldRefl : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				
				//计算反射方向 视角方向关于顶点法线的反射方向
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
				
				TRANSFER_SHADOW(o);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));		
				fixed3 worldViewDir = normalize(i.worldViewDir);		
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
				
				//使用反射方向对Cubemap采样
				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb;
				
				//计算菲涅尔系数
				fixed fresnel = _FresnelScale + (1-_FresnelScale) * pow(1 - dot(worldViewDir,worldNormal),5);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				


				//使用菲涅尔系数混合漫反射颜色和反射颜色
				fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
				
				return fixed4(color, 1.0);
			}
			ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}
