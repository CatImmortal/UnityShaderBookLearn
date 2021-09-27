
//世界空间下的法线纹理凹凸贴图
Shader "MyShader/Chapter7/NormalMapWorldSpace"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
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
			float4 _BumpMap_ST;
			float _BumpScale;
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
				float4 uv : TEXCOOR0;  //纹理坐标
				float4 TtoW0 : TEXCOORD0;
				float4 TtoW1 : TEXCOORD1;
				float4 TtoW2 : TEXCOORD2;
			};

			v2f vert (a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

				fixed3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent);
				fixed3 worldBinormal = cross(worldNormal,worldTangent);
				
				//切线空间转换到世界空间的矩阵
				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));


				//采样切线空间下的法线，然后转换到世界空间
				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

				//采样纹理
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump,worldLightDir));


				//Blinn模型需要的half向量
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);

				//高光反射颜色
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump,halfDir)),_Gloss);


				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}

