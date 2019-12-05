Shader "Custom/SnowShader2" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Noise("Noise (A)", 2D) = "white" {}
        _EdgeColor("Edge Color", Color) = (1,1,1,0)
        _Snow ("Snow Level", Range(0,1)) = 0
        _SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)
        _SnowDirection ("Snow Direction", Vector) = (0,-1,0)
        _SnowDepth ("Snow Depth", Range(0,0.3)) = 0.1
        _Wetness ("Wetness", Range(0, 1)) = 0.3
        
    }
    SubShader {
        Tags { "Queue"="transparent" "RenderType" = "TransparentCutout" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert alpha vertex:vert
        sampler2D _MainTex;
        sampler2D _Bump;
        sampler2D _Noise;
        
        float4 _EdgeColor;
        float _Snow;
        float4 _SnowColor;
        float4 _SnowDirection;
        float _SnowDepth;
        float _Wetness;
        
        struct Input {
            float2 uv_MainTex;  
            float2 uv_Bump;
            float2 uv_Noise;
            float3 worldNormal;
            INTERNAL_DATA
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);                       
            half4 n = tex2D (_Noise, IN.uv_Noise);            
 
            o.Normal = UnpackNormal (tex2D (_Bump, IN.uv_Bump));
            half difference = dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) - lerp(1,-1,_Snow);;
            difference = saturate(difference / _Wetness);
            o.Albedo = difference*_SnowColor.rgb + (1-difference) *c;
            
            o.Alpha = clamp( 1 - (n.r*n.b) - abs(_SinTime.w)  , 0, 1);
            
            if ( o.Alpha > 0.3)
                o.Alpha = 1; 
            else if ( o.Alpha > 0.15 ) {
                o.Albedo.r = _EdgeColor.r * abs( _SinTime.w) ;
                o.Albedo.g = _EdgeColor.g * abs( _SinTime.y) ;
                o.Albedo.b = _EdgeColor.b * abs( _SinTime.z) ;
            }
        }
           
        void vert (inout appdata_full v) {
            float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);

            if(dot(v.normal, _SnowDirection.xyz) >= lerp(1,-1, ((1-_Wetness) * _Snow*2)/3))
            {
                v.vertex.xyz += (_SnowDirection.xyz + v.normal) * _SnowDepth * _Snow;
            }
        }
        ENDCG
    } 
    FallBack "Diffuse"
}
