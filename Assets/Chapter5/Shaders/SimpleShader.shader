Shader "MyShader/Chapter5/SimpleShader"
{
	Properties{
		_Color ("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;

			struct a2v {
				float4 vertex:POSITION;  //顶点坐标
				float3 normal:NORMAL;	//法线方向
				float4 texcoord:TEXCOORD;	//纹理坐标
			};

			struct v2f{
				float4 pos : SV_POSITION;  //顶点的裁剪空间坐标
				fixed3 color : COLOR0;	//顶点颜色
			};

			v2f vert (a2v v) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.color = v.normal *0.5 + fixed3(0.5,0.5,0.5);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 c = i.color;

				c *= _Color.rgb;
				return fixed4(c,1.0);
			}
			ENDCG
		}
	}
}
