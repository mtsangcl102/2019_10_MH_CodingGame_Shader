// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Sprite/DecaySurface" 
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
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        
        uniform sampler2D _MainTex;
        uniform sampler2D _MaskTex;
        uniform sampler2D _OtherTex;
        uniform float4 _BorderColor;
        
        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input input, inout SurfaceOutput o) 
        {
            float4 main = tex2D( _MainTex, input.uv_MainTex);
            float maskA = tex2D(_MaskTex, input.uv_MainTex).r;
            float4 other = tex2D(_OtherTex, input.uv_MainTex);
            float _decayValue = (_CosTime.a + 1) * 0.5;
            _decayValue = _decayValue * 1.25 - 0.25;
            float showRedWhenLargerA = _decayValue + 0.2;
            float showBlackWhenLargerA = _decayValue + 0.05;
            float showWhenLargerA = _decayValue;
        
            if( maskA < showWhenLargerA ){
                o.Alpha = 0;
            }
            else if( maskA < showBlackWhenLargerA ){
                o.Albedo = _BorderColor.rgb;
                o.Alpha = main.a;
            }
            else if( maskA < showRedWhenLargerA ){
                o.Albedo = lerp( main, other, _decayValue ).rgb;
                o.Alpha = main.a;
            }
            else
            {
                o.Albedo.rgb = main.rgb;
                o.Alpha = main.a;
            }

        }
        ENDCG
    }
    Fallback "Diffuse"
}