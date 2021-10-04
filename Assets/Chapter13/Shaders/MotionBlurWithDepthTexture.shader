Shader "MyShader/Chapter13/MotionBlurWithDepthTexture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;
			
			//处理平台差异导致的图像翻转问题
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1 - o.uv_depth.y;
			#endif
					 
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
			//获取当前像素的深度值
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			#if defined(UNITY_REVERSED_Z)
				d = 1.0 - d;
			#endif

			//把深度值重新映射回NDC
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			
			//计算当前帧的世界空间坐标
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			float4 worldPos = D / D.w;
			
			//计算前一帧的世界空间坐标
			float4 currentPos = H;
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			previousPos /= previousPos.w;
			
			//计算速度
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0;
			
			//使用速度值对临域像素采样 相加后取平均值得到一个模糊效果
			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);
			uv += velocity * _BlurSize;
			for (int it = 1; it < 3; it++, uv += velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= 3;
			
			return fixed4(c.rgb, 1.0);
		}
		
		ENDCG
		
		Pass {      
			ZTest Always Cull Off ZWrite Off
			    	
			CGPROGRAM  
			
			#pragma vertex vert  
			#pragma fragment frag  
			  
			ENDCG  
		}
	} 
	FallBack Off
}
