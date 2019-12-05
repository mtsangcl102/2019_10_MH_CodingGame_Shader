Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "white" {}
        _Color ("Color", Color) = (0,0,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" "LightMode"="Vertex"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
    
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 sc : TEXCOORD2;
                float4 vertex : SV_POSITION;
                fixed4 diff : COLOR0;
                fixed4 diff2 : COLOR1;
             
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            fixed4 _Color;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _NoiseTex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);

                half nl = max(0, dot(worldNormal, -unity_LightPosition[0].xyz));
                o.diff = nl * unity_LightColor[0];
                                
                nl = max(0, dot(worldNormal, -unity_LightPosition[1].xyz));
                o.diff2 = nl * unity_LightColor[1];
                
                o.sc.x = sin(_Time.y/3) ;
                o.sc.y = cos(_Time.y/3) ;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 noise = normalize(tex2D(_NoiseTex, i.uv2));
                float dd = (dot(noise.rgb,noise.rgb)-0.5)*2 ;
                fixed4 color ;
            
                color.r = abs(i.sc.x) ;
                color.g = 1-abs(i.sc.x) ;
                color.b = i.sc.y ;

                if(dd <= i.sc.x)
                    col.rgb = col.rgb * color ;
                    
                if(dd > i.sc.x-0.1)
                    col.a = 1;
                else if(dd > i.sc.x-0.2)
                    col.a = (dd-(i.sc.x-0.2))*10;
                else 
                    col.a = 0 ;

                col.rgb *= (i.diff.rgb+i.diff2.rgb) ;
                return col;
            }
            ENDCG
        }
    }
}
