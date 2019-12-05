// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Sprite/DecayWithDirectionalLight" 
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D)		= "white" {}
		_MaskTex("Mask (A)", 2D)		= "white" {}
		_OtherTex("Other (A)", 2D)		= "white" {}
		_BorderColor("Border Color", Color) = ( 0, 0, 0, 1)
		
	}
	SubShader 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "LightMode" = "Vertex" }
		Zwrite OFF
		Lighting On
		Blend SrcAlpha OneMinusSrcAlpha 
		Lighting Off
		Fog { Mode Off }			

		pass
		{			
			CGPROGRAM			
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"
            

			uniform sampler2D _MainTex;
			uniform sampler2D _MaskTex;
			uniform sampler2D _OtherTex;
			uniform float4 _BorderColor;

			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float4 _OtherTex_ST;

			struct vertexInput {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;		
                float4 normal: NORMAL;
			};
			
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float2 tex : TEXCOORD0;
				float3 color : COLOR;
			};

			
			vertexOutput vert(vertexInput input){
				vertexOutput output;				
				output.tex = input.texcoord;
				output.pos = UnityObjectToClipPos(input.vertex);
				output.color = ShadeVertexLightsFull( input.vertex, input.normal, 4, false );
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR{
				float4 main = tex2D( _MainTex, input.tex);
				float maskA = tex2D(_MaskTex, input.tex).r;
				float4 other = tex2D(_OtherTex, input.tex);

				float _decayValue = (_CosTime.a + 1) * 0.5;
				_decayValue = _decayValue * 1.25 - 0.25;
				float showRedWhenLargerA = _decayValue + 0.2;
				float showBlackWhenLargerA = _decayValue + 0.05;
				float showWhenLargerA = _decayValue;
            
				if( maskA < showWhenLargerA ){
					main= float4( 0, 0, 0, 0 );
				}
				else if( maskA < showBlackWhenLargerA ){
					main = float4( _BorderColor.rgb, main.a);
				}
				else if( maskA < showRedWhenLargerA ){
					main = float4(lerp( main, other, _decayValue ).rgb, main.a);
				}

				return float4( main.rgb * input.color * 2, main.a );
			}
	         ENDCG				
		}
	}
	FallBack "Diffuse"
}
