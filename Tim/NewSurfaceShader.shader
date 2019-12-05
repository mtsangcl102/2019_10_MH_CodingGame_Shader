Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent"  }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows alpha:fade
        #pragma debug
        
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float3 worldNormal;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 d = normalize(tex2D (_NoiseTex, IN.uv_NoiseTex)) ;
            float dd = (dot(d.rgb,d.rgb)-0.5)*2 ;
            
            float t = (sin(_Time.y/3)) ;
            float tt = (cos(_Time.y/3)) ;
            fixed4 color ;
            
            color.r = abs(t) ;
            color.g = 1-abs(t) ;
            color.b = tt ;

                                    
            if(dd > t)
               o.Albedo = c.rgb;   
            else
               o.Albedo = c.rgb * color ;
            
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            
            if(dd > t-0.1)
                o.Alpha = _Color.a;
            else if(dd > t-0.2)
                o.Alpha = (dd-(t-0.2))*10;
            else 
                o.Alpha = 0 ;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
