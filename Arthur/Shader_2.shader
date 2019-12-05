// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Shader_2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        
        _AlphaTex ("ALpha (A)", 2D) = "white" {}
        
        _GlowColor ("GlowColor", Color) = (1,1,1,1)
        _GlowWidth ("Glow Width", Range(0,1)) = 0.1
    }
    
    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" "LightMode"="ForwardBase"}
        LOD 200

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                
                fixed4 diff : COLOR0;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AlphaTex;
            float4 _AlphaTex_ST;
            
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
            
            v2f vert (appdata v, float3 normal : NORMAL, float4 tangent : TANGENT)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                half3 wNormal = UnityObjectToWorldNormal(normal);
                half nl = max(0, dot(wNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0;
                o.diff.rgb += ShadeSH9(half4(wNormal,1));
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed _Cutoff = (_SinTime.z + 1) / 2;
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_AlphaTex, i.uv);
                
                if(mask.a >= _Cutoff){
                    col *= i.diff;
                    col *= _Color;
                }else{
                    float3 hsv = rgb2hsv(_GlowColor.rgb);
                    hsv.x += _Time.w * 0.1;
                    float3 rgb = hsv2rgb(hsv);
                    
                    col = fixed4(rgb * _Color, 0);
                }
                
                clip(mask.a - _Cutoff + _GlowWidth);
                return col;
            }
            
            ENDCG
        }

    }
    FallBack "Diffuse"
}
