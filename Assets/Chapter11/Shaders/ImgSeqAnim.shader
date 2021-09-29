//序列帧动画
Shader "MyShader/Chapter11/ImgSeqAnim"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Image Sequence", 2D) = "white" {}
    	_HorizontalAmount ("Horizontal Amount", Float) = 4
    	_VerticalAmount ("Vertical Amount", Float) = 4
    	_Speed ("Speed", Range(1, 100)) = 30
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;
			  
			struct a2v {  
			    float4 vertex : POSITION; 
			    float2 texcoord : TEXCOORD0;
			};  
			
			struct v2f {  
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float time = floor(_Time.y * _Speed);

				//行索引
				float row = floor(time / _HorizontalAmount);

				//除法结果的余数是列索引
				float column = time - row * _HorizontalAmount;

				//子图像内部的偏移量 偏移范围是单个子图像
				half2 uv = float2(i.uv.x / _HorizontalAmount,i.uv.y / _VerticalAmount);

				//再使用当前行列索引进行偏移 偏移范围是整个图像
				uv.x += column / _HorizontalAmount;
				uv.y -= row / _VerticalAmount;

				fixed4 c = tex2D(_MainTex,uv);
				c.rgb *= _Color;

				return c;
			}
			ENDCG
		}
	}
	FallBack "Transparent/VertexLit"
}
