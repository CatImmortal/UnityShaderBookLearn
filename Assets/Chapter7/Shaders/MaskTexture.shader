
//遮罩纹理
Shader "MyShader/Chapter7/MaskTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_SpecularMask("Specular Mask",2D) = "white" {}
		_SpecularScale("Specular Scale",Float) = 1.0
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
			sampler2D _MainTex;  //纹理
			float4 _MainTex_ST;  //纹理的缩放和平移值
			sampler2D _BumpMap;  //法线纹理
			float _BumpScale;
			sampler2D _SpecularMask;  //高光遮罩
			float _SpecularScale;
			fixed4 _Specular;  //高光颜色
			float _Gloss;  //高光区域

			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOOR0;  //纹理坐标
				float3 lightDir : TEXCOORD1;  //切线空间下的光照方向
				float3 viewDir : TEXCOORD2;  //切线空间下的视角方向
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				//模型空间到切线空间的转换矩阵
				TANGENT_SPACE_ROTATION;

				//计算切线空间下的光源方向和视角方向
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex));

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//采样切线空间下的法线纹理
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv)); //映射回法线方向
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));  //计算z分量

				//采样纹理
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));


				//Blinn模型需要的half向量
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				//采样遮罩纹理的r通道
				fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;


				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}

