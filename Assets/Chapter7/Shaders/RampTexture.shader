
//渐变纹理
Shader "MyShader/Chapter7/RampTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_RampTex("Ramp Tex",2D) = "white" {}
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
			#include "UnityCG.cginc"

			fixed4 _Color;  //颜色
			sampler2D _RampTex;  //渐变纹理
			float4 _RampTex_ST;  //纹理的缩放和平移值
			fixed4 _Specular;  //高光颜色
			float _Gloss;  //高光区域

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;  //法线的世界空间方向
				float3 worldPos : TEXCOORD1;  //顶点的世界坐标
				float2 uv : TEXCOOR2;  //纹理坐标
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{

				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//光源入射方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//计算半兰伯特
				fixed halfLambert  = 0.5 * dot(worldNormal, worldLightDir) + 0.5;

				//漫反射颜色 使用halfLambert构建纹理坐标对渐变纹理采样
				fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				//视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				//Blinn模型需要的half向量
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);


				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}

