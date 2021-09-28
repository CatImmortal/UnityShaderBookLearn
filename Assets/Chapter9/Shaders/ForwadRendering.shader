// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'


//前向渲染
Shader "MyShader/Chapter9/ForwadRendering"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		//Base Pass
		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#pragma multi_compile_fwdbase
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
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
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
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//Blinn模型需要的half向量
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

				//衰减 平行光没有衰减
				fixed atten = 1.0;

				fixed3 color = ambient + (diffuse + specular) * atten;

				return fixed4(color,1.0);
			}

			ENDCG
		}

		//Additional Pass
		Pass
		{
			Tags { "LightMode"="ForwardAdd" }

			Blend One One

			CGPROGRAM



			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

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
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//在片元着色器里计算漫反射


				//法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//光源入射方向 判断是否是平行光
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
				

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//Blinn模型需要的half向量
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);


				//衰减
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;  //平行光没有衰减
				#else
					//通过衰减纹理查找到衰减
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif
				

				fixed3 color = (diffuse + specular) * atten;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}

