
//单张纹理采样
Shader "MyShader/Chapter7/SingleTexture"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white" {}
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
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//在片元着色器里计算漫反射

				//采样纹理
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

				//环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;


				//法线
				fixed3 worldNormal = normalize(i.worldNormal);

				//光源入射方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));


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

