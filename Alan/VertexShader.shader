// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/VertexShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Noise("Noise (A)", 2D) = "white" {}
        _EdgeColor("Edge Color", Color) = (1,1,1,0)
        _Snow ("Snow Level", Range(0,1)) = 0
        _SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)
        _SnowDirection ("Snow Direction", Vector) = (0,-1,0)
        _SnowDepth ("Snow Depth", Range(0,0.3)) = 0.1
        _Wetness ("Wetness", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "Queue"="transparent" "RenderType" = "TransparentCutout" }
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Bump;
            float4 _Bump_ST;
            sampler2D _Noise;
            float4 _Noise_ST;
            float4 _SnowDirection;
            float4 _EdgeColor;
            float _Wetness;
            float4 _SnowColor;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);
                half4 noise = tex2D (_Noise, i.uv);                  
                i.normal = tex2D (_Bump, i.uv);
                half difference = dot(i.normal, _SnowDirection.xyz) ;//- lerp(1,-1,_Snow);;
                difference = saturate(difference / _Wetness);
                col.rgb = difference*_SnowColor.rgb + (1-difference) * col.rgb;
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);                
                col.a = clamp( 1 - (noise.r*noise.b) - (1-abs(_SinTime.w))  , 0, 1);
                
                if ( col.a > 0.3)
                    col.a = 1; 
                else if ( col.a > 0.15 ) {
                    col.r = _EdgeColor.r * abs( _SinTime.w) ; 
                    col.g = _EdgeColor.g * abs( _SinTime.y) ;
                    col.b = _EdgeColor.b * abs( _SinTime.z) ;
                }
                
                return col;
            }
            ENDCG
        }
        
        Pass {
			Tags { "LightMode" = "ForwardBase" }

			Cull Back
			Lighting On
			//Blend SrcAlpha OneMinusSrcAlpha 

			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler _MainTex;
			sampler _BumpTex;
			
			float4 _MainTex_ST;
			float4 _BumpTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 lightDirection : TEXCOORD2;
				LIGHTING_COORDS(3,4)
			};
 
			v2f vert(a2v v) {
				v2f o;
				
				TANGENT_SPACE_ROTATION;
				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.texcoord, _BumpTex);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				float4 c = tex2D(_MainTex, i.uv);
				float3 n = UnpackNormal(tex2D(_BumpTex, i.uv2));
				
				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				float atten = LIGHT_ATTENUATION(i);
				
				// Angle to the light
				float diff = saturate(dot(n, normalize(i.lightDirection)));
				lightColor += _LightColor0.rgb * (diff * atten);
				
				c.rgb = lightColor * c.rgb * 2;
				c.a = 0;
				return c;
			}
			
			ENDCG
		}
        
        Pass {

			Tags { "LightMode" = "ForwardAdd" }
			
			Cull Back
			Lighting On
			Blend SrcAlpha OneMinusSrcAlpha 

						
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdadd
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler _MainTex;
			sampler _BumpTex;
			sampler2D _Noise;
			
            float4 _Noise_ST;
			float4 _MainTex_ST;
			float4 _BumpTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 lightDirection : TEXCOORD2;
				LIGHTING_COORDS(3,4)
			};
 
			v2f vert(a2v v) {
				v2f o;
				
				TANGENT_SPACE_ROTATION;
				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.texcoord, _BumpTex);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				float4 c = tex2D(_MainTex, i.uv);
				float3 n = UnpackNormal(tex2D(_BumpTex, i.uv2));
				half4 noise = tex2D (_Noise, i.uv2);
				                  
				float lengthSq = dot(i.lightDirection, i.lightDirection);
				float atten = LIGHT_ATTENUATION(i);
				
				// Angle to the light
				float diff = saturate(dot(n, normalize(i.lightDirection)));
				float3 lightColor = _LightColor0.rgb * (diff * atten);
				
				c.rgb = lightColor * c.rgb * 3;
                c.a = clamp( 1 - (noise.r*noise.b) - (1-abs(_SinTime.w)) - 0.25  , 0, 1);
                //c.a = 0.5;                
                
				return c;
			}
			
			ENDCG
		}              
		
    }
}
