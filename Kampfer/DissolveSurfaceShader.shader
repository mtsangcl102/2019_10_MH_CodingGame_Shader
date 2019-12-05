Shader "Unlit/DissolveEffectShader"
{
	Properties {
        
        _MainTex ("Main Texture (RGB)", 2D) = "white" {}
        _NoiseTex("Noise Texture (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        
        _EmissionColorFrom ("Color From", Color) = (1,1,1,1)
        _EmissionColorTo ("Color To", Color) = (1,1,1,1)
        _EmissionSize("Emission Size", Range(0,1)) = 0
        
        _Speed("Speed", Range(0,1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _MainTex;
        sampler2D _NoiseTex;
        sampler2D _Bump;
        
        fixed4 _EmissionColorFrom;
        fixed4 _EmissionColorTo;
        half _EmissionSize;
        half _Speed;
        
        struct Input {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float2 uv_Bump;
            float3 worldPos;
            
        };
 
        float Pingpong()
        {
            int remainder = fmod(floor(_Time.y * _Speed), 2);
            return remainder == 1 ? 1 - frac(_Time.y * _Speed) : frac(_Time.y * _Speed);
        }
        
        void surf (Input IN, inout SurfaceOutput o) {
  
            float _DissolvePercentage = Pingpong();
            half gradient = tex2D(_NoiseTex, IN.uv_NoiseTex.rg).r;
            clip(gradient - _DissolvePercentage);

            float4 texColor = tex2D( _MainTex, IN.uv_MainTex );
            float4 emissionColor = lerp(_EmissionColorFrom, _EmissionColorTo, _DissolvePercentage);
 
            //从_Bump纹理中提取法向信息
            o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));
            o.Emission = emissionColor * step( gradient - _DissolvePercentage, _EmissionSize);
            o.Albedo = texColor.rgb;
            o.Alpha = gradient;
        }
        
        ENDCG
    }
}