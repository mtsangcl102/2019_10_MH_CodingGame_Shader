Shader "Custom/Shader 2 (Dissolve Fragment Shader)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DissolveTex ("Dissolve Map", 2D) = "white" {}        
        _DissolveEdgeRange("Dissolve Edge Range", float) = 0.1
    }
    SubShader
    {
        LOD 100

        Pass
        {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 col : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _DissolveTex;
            float _DissolveEdgeRange;
            float4 _MainTex_ST;
            uniform float4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;
                float3 normalDirection = UnityObjectToWorldNormal(v.normal);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuseReflection = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));
               
                o.col = float4(diffuseReflection, 1.0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half dissolveIntensity = _SinTime.z / 2 + 0.5;
                      
                float4 dissolveColor = tex2D(_DissolveTex, i.uv) ;      	      	
                half dissolveClip = dissolveColor.r - dissolveIntensity;
                half edgeRamp = max(0, _DissolveEdgeRange - dissolveClip) * 50;
                
                clip( dissolveClip );
                
                float4 texColor = tex2D(_MainTex, i.uv) * i.col;                
                float4 edgeColor = float4(_SinTime.x / 2 + 0.5, _SinTime.y / 2 + 0.5, _SinTime.z / 2 + 0.5, 1);
                fixed4 col = lerp( texColor, edgeColor, edgeRamp );    
                
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode" = "ForwardAdd" }
            Blend One One
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 col : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _DissolveTex;
            float _DissolveEdgeRange;
            float4 _MainTex_ST;
            uniform float4 _LightColor0;

            v2f vert (appdata v)
            {
                v2f o;
                
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;
                float3 normalDirection = UnityObjectToWorldNormal(v.normal);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuseReflection = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));
               
                o.col = float4(diffuseReflection, 1.0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half dissolveIntensity = _SinTime.z / 2 + 0.5;
                      
                float4 dissolveColor = tex2D(_DissolveTex, i.uv) ;      	      	
                half dissolveClip = dissolveColor.r - dissolveIntensity;
                half edgeRamp = max(0, _DissolveEdgeRange - dissolveClip) * 50;
                
                clip( dissolveClip );
                
                float4 texColor = tex2D(_MainTex, i.uv) * i.col;                
                float4 edgeColor = float4(_SinTime.x / 2 + 0.5, _SinTime.y / 2 + 0.5, _SinTime.z / 2 + 0.5, 1);
                fixed4 col = lerp( texColor, edgeColor, edgeRamp );    
                
                return col;
            }
            ENDCG
        }
    }
    
    
}
