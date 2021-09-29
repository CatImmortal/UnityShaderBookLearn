Shader "MyShader/Chapter11/Billboard"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1 
	}
	SubShader
	{
		//需要在模型空间进行顶点动画 所以需要关闭合批
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboarding;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v)
			{
				v2f o;

				//以原点作为锚点
				float3 center = float3(0,0,0);

				//获取模型空间下的视角位置
				float3 viewer = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos,1));
				
				//计算3个正交方向

				//1.根据观察位置和锚点计算法线方向
				float3 normalDir = viewer - center;
				normalDir.y =normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);

				//2.得到粗略的上方向和右方向
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));

				//3.得到准确的上方向
				upDir = normalize(cross(normalDir, rightDir));

				//根据原始位置相对于锚点的偏移量和三个基向量 计算新的顶点位置
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
		
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D (_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			}
			ENDCG
		}
	}
		FallBack "Transparent/VertexLit"
}
