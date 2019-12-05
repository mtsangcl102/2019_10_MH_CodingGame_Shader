Shader "Custom/Q1Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpTex ("Bump", 2D) = "bump" {}
        _NoiseTex ("Noise Tex (RGB)" , 2D) = "white" {}
        _Edge ("EdgeThickness", Range(0,1)) = 0.2
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha:fade
        // Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        //#pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpTex;
        sampler2D _NoiseTex;
        
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float4 _Time; 
        };

        fixed4 _Color;
        half _Edge;
      
        float3 hue2rgb(float hue) {
            hue = frac(hue); //only use fractional part
            float r = abs(hue * 6 - 3) - 1; //red
            float g = 2 - abs(hue * 6 - 2); //green
            float b = 2 - abs(hue * 6 - 4); //blue
            float3 rgb = float3(r,g,b); //combine components
            rgb = saturate(rgb); //clamp between 0 and 1
            return rgb;
        }

        float3 hsv2rgb(float3 hsv)
        {
            float3 rgb = hue2rgb(hsv.x); //apply hue
            rgb = lerp(1, rgb, hsv.y); //apply saturation
            rgb = rgb * hsv.z; //apply value
            return rgb;
        }        
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) ;
            fixed4 noiceValue = tex2D( _NoiseTex, IN.uv_NoiseTex);
            fixed threshold = _SinTime.w * 0.5 + 0.5;
            fixed alpha = lerp(0,1, saturate((noiceValue.x - threshold) / _Edge));            
            
            float3 hsv = float3( _Time.y * 0.2  , 1 , 1);
            float3 edgeColor = hsv2rgb( hsv ) ;
            
            o.Albedo = lerp( edgeColor , c.rgb , alpha ) ;
            o.Alpha = alpha;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
