// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/DissolveVertexEffectShader"
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
 
        Pass {
 
            Tags { "LightMode"="ForwardBase" }
            Cull Back
            Lighting On
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
            uniform float4 _LightColor0;
 
            sampler2D _MainTex;
            sampler2D _Bump;
            sampler2D _NoiseTex;
            
            float4 _MainTex_ST;
            float4 _Bump_ST;
            float4 _NoiseTex_ST;
        
            fixed4 _EmissionColorFrom;
            fixed4 _EmissionColorTo;
            half _EmissionSize;
            half _Speed;
        
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
 
            };
 
            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 lightDirection : TEXCOORD2;
 
            };
             
            v2f vert (a2v v)
            {
                v2f o;
                TANGENT_SPACE_ROTATION;
 
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex); 
                o.uv2 = TRANSFORM_TEX (v.texcoord, _Bump);
                return o;
            }
                           
            float Pingpong()
            {
                int remainder = fmod(floor(_Time.y * _Speed), 2);
                return remainder == 1 ? 1 - frac(_Time.y * _Speed) : frac(_Time.y * _Speed);
            }
            
            float4 frag(v2f i) : COLOR 
            {
                float4 c = tex2D (_MainTex, i.uv); 
                float3 n =  UnpackNormal(tex2D (_Bump, i.uv2));
 
                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
 
                float lengthSq = dot(i.lightDirection, i.lightDirection);
                float atten = 1.0 / (1.0 + lengthSq);
                //光源的入射角 
                float diff = saturate (dot (n, normalize(i.lightDirection)));  
                lightColor += _LightColor0.rgb * (diff * atten);
                c.rgb = lightColor * c.rgb * 2;
                
                float _DissolvePercentage = Pingpong();
                half gradient = tex2D(_NoiseTex, i.uv);
                
                float4 emissionColor = lerp(_EmissionColorFrom, _EmissionColorTo, _DissolvePercentage);
                float useDissolve = gradient - _DissolvePercentage < _EmissionSize;
                
                c = ( 1 - useDissolve ) * c + useDissolve * emissionColor;               
                clip(gradient - _DissolvePercentage);
                    
                return c;
            }
 

            ENDCG
        }
        
        Pass {
 
            Cull Back
            Lighting On
            Tags { "LightMode"="ForwardAdd" }
            Blend One One
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
            uniform float4 _LightColor0;
 
            sampler2D _MainTex;
            sampler2D _Bump;
            sampler2D _NoiseTex;
            
            float4 _MainTex_ST;
            float4 _Bump_ST;
            float4 _NoiseTex_ST;
        
            fixed4 _EmissionColorFrom;
            fixed4 _EmissionColorTo;
            half _EmissionSize;
            half _Speed;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
 
            };
 
            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 lightDirection : TEXCOORD2;
            };
 
            v2f vert (a2v v)
            {
                v2f o;
                TANGENT_SPACE_ROTATION;
 
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = TRANSFORM_TEX (v.texcoord, _MainTex); 
                o.uv2 = TRANSFORM_TEX (v.texcoord, _Bump);
                return o;
            }
 
 
            float Pingpong()
            {
                int remainder = fmod(floor(_Time.y * _Speed), 2);
                return remainder == 1 ? 1 - frac(_Time.y * _Speed) : frac(_Time.y * _Speed);
            }
            
            float4 frag(v2f i) : COLOR 
            {
                float4 c = tex2D (_MainTex, i.uv); 
                float3 n =  UnpackNormal(tex2D (_Bump, i.uv2));
 
                float3 lightColor = float3(0.0, 0.0, 0.0);
 
                float lengthSq = dot(i.lightDirection, i.lightDirection);
                float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
                //光源的入射角
                   float diff = saturate (dot (n, normalize(i.lightDirection)));  
                lightColor += _LightColor0.rgb * (diff * atten);
                c.rgb = lightColor * c.rgb * 2;
                
                float _DissolvePercentage = Pingpong();
                half gradient = tex2D(_NoiseTex, i.uv);
                
                float4 emissionColor = lerp(_EmissionColorFrom, _EmissionColorTo, _DissolvePercentage);
                float useDissolve = gradient - _DissolvePercentage < _EmissionSize;
                
                c = ( 1 - useDissolve ) * c + useDissolve * emissionColor;               
                clip(gradient - _DissolvePercentage);
                    
                return c;
            }
 
            ENDCG
        }
    
    }
}