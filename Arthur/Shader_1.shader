Shader "Custom/Shader_1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        
        _AlphaTex ("ALpha (A)", 2D) = "white" {}
        
        _GlowColor ("GlowColor", Color) = (1,1,1,1)
        _GlowWidth ("Glow Width", Range(0,1)) = 0.1
    }
    
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _AlphaTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_AlphaTex;
        };

        fixed4 _Color;
        fixed4 _GlowColor;
        fixed _Cutoff;
        fixed _GlowWidth;


        float Epsilon = 1e-10;

        float3 rgb2hsv(in float3 RGB)
        {
            fixed4 k = fixed4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            fixed4 p = lerp(fixed4(RGB.zy, k.wz), fixed4(RGB.yz, k.xy), (RGB.z < RGB.y) ? 1.0 : 0.0);
            fixed4 q = lerp(fixed4(p.xyw, RGB.x), fixed4(RGB.x, p.yzx), (p.x < RGB.x) ? 1.0 : 0.0);
            fixed d = q.x - min(q.w, q.y);
            return float3(abs(q.z + (q.w - q.y) / (6.0 * d + Epsilon)), d / (q.x + Epsilon), q.x);
        }

        float3 hsv2rgb(float3 c)
        {
            fixed4 k = fixed4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            float3 p = abs(frac(c.xxx + k.xyz) * 6.0 - k.www);
            return c.z * lerp(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
        }
        

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed _Cutoff = (_SinTime.z + 1) / 2;
            
        
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 a = tex2D (_AlphaTex, IN.uv_AlphaTex) * _Color;
            if(a.a >= _Cutoff)
                o.Albedo = c.rgb;
            else{
                float3 hsv = rgb2hsv(_GlowColor.rgb);
                hsv.x += _Time.w * 0.1;
                float3 rgb = hsv2rgb(hsv);
                
                o.Albedo = rgb * _Color;
                o.Emission = rgb;
            }
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
 
            o.Alpha = a.a;
            
            clip(a.a - _Cutoff + _GlowWidth);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
