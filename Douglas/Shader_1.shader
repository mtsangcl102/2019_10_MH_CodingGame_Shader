Shader "CodeinGame/Shader_1"
{
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BumpTex ("Bump", 2D) = "bump" {}
        _NoiseTex ("Noise", 2D) = "white"{}
        _Speed ("Speed", Float) = 2.0
        _Snow ("Snow Level", Range(0,1) ) = 0
        _SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)
        _Color ("Color", Color) = (1.0,1.0,1.0,1.0)
        _SnowDirection ("Snow Direction", Vector) = (0,1,0)
        _SnowDepth ("Snow Depth", Range(0,0.2)) = 0.1
        _Test ("TEST", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" "RenderType"="TransparentCutout"}
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert alpha
 
        sampler2D _MainTex;
        sampler2D _BumpTex;
        sampler2D _NoiseTex;
        float4 _SnowColor;
        float4 _Color;
        float _Speed;
        float _Snow;
        float4 _SnowDirection;
        float _SnowDepth; 
        float _Test;
        
        struct Input {
             float2 uv_MainTex;
             float2 uv_Bump;
             float3 worldNormal;
             INTERNAL_DATA
        };
        void vert (inout appdata_full v) {
             float4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);
 
             if(dot(v.normal, sn.xyz) >= lerp(1,-1, (_Snow*2)/3)){
                  v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
             }
        } 
        void surf (Input IN, inout SurfaceOutput o) { 
            half4 _MainColor = tex2D (_MainTex, IN.uv_MainTex);// * _Color;
            half4 _BumpColor = tex2D (_BumpTex, IN.uv_Bump);
            half4 _Noise = tex2D (_NoiseTex, IN.uv_MainTex);
            o.Normal = UnpackNormal (_BumpColor);
            o.Albedo = _MainColor.rgb;
            //o.Alpha = _MainColor.a;
            
            //clip(_Noise - _Test);
            //clip(_Noise - abs(_SinTime.y * _Speed));
            o.Alpha =  _Noise -_SinTime.y * _Speed;
            if(o.Alpha > 0.2 && o.Alpha < 0.5){
                o.Albedo = _MainColor * _Color;
            }else if(o.Alpha < 0.2){
                o.Alpha = 0;
            }
            else{
                o.Alpha = 1;
            }
            
            //fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            //float ca = tex2D(_CutTex, IN.uv_MainTex).a;
            //o.Albedo = c.rgb;
     
            //if (ca > _Cutoff)
            //    o.Alpha = c.a;
            //else
                //o.Alpha = 0;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}