// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Shader_2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}
		//_level ("Level", Range(-1,1) ) = 0.5
		_CutOutDirection ("CutOut Direction", Vector) = (1,1,-1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        Pass {
			Tags { "LightMode" = "ForwardBase" }

            Cull Back 
            Lighting On
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

			uniform float4 _LightColor0;

			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _Bump;
			float4 _Bump_ST;
			float4 _CutOutDirection;
			//float _level ;

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
				float4 pos : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 lightDirection : VECTOR;
				//float3 color : COLOR0; 
            };
            
            v2f vert (a2v v)
            {
                v2f o;
				TANGENT_SPACE_ROTATION;

				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.texcoord, _Bump);
				//o.color = ShadeVertexLights(v.vertex, v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                fixed4 c = tex2D(_MainTex, i.uv);
				float3 n =  UnpackNormal(tex2D (_Bump, i.uv2)); 
				float level = abs( ( _Time.y * 2 % 6 ) - 3 ) - 2 ;
				float3 edgeColor = float3( 1, 0, 0 ) ;
				switch( ( ( _Time.y * 2 - 3 ) / 6 ) % 7 ){
					case 0 :
					{ 
						edgeColor = float3( 1, 0, 0 ) ;
						break ;
					}
					case 1:
					{ 
						edgeColor = float3( 1, 0.65, 0 ) ;
						break ;
					}
					case 2:
					{ 
						edgeColor = float3( 1, 1, 0 ) ;
						break ;
					}
					case 3:
					{ 
						edgeColor = float3( 0, 1, 0 ) ;
						break ;
					}
					case 4:
					{ 
						edgeColor = float3( 0, 0, 1 ) ;
						break ;
					}
					case 5:
					{ 
						edgeColor = float3( 0.2, 0, 0.5 ) ;
						break ;
					}
					case 6:
					{ 
						edgeColor = float3( 0.5, 0, 0.5 ) ;
						break ;
					}
				}

				float3 lightColor =  float3(0, 0, 0);

				float lengthSq = dot(i.lightDirection, i.lightDirection);
				float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
				float diff = saturate (dot (n, normalize(i.lightDirection)));   
				lightColor += _LightColor0.rgb * (diff * atten);
				c.rgb = c.rgb  * lightColor * 2;
				if( dot( n, _CutOutDirection.xyz ) >= level )
					c.a = 0;
				else
					c.a = 1;
				if( dot( n, _CutOutDirection.xyz ) >= level - 0.1 )
					c.rgb = edgeColor;
                return c;
            }
            ENDCG
        }

		Pass {
			Tags { "LightMode" = "ForwardAdd" }

            Cull Back 
            Lighting On
			Blend SrcAlpha One

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

			uniform float4 _LightColor0;

			sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _Bump;
			float4 _Bump_ST;
			float4 _CutOutDirection;
			//float _level ;

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
				float4 pos : POSITION;
                float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 lightDirection : VECTOR;
				//float3 color : COLOR0; 
            };
            
            v2f vert (a2v v)
            {
                v2f o;
				TANGENT_SPACE_ROTATION;

				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.texcoord, _Bump);
				//o.color = ShadeVertexLights(v.vertex, v.normal);
                return o;
            }
            
            fixed4 frag (v2f i) : COLOR
            {
                fixed4 c = tex2D(_MainTex, i.uv);
				float3 n =  UnpackNormal(tex2D (_Bump, i.uv2)); 
				float level = abs( ( _Time.y * 2 % 6 ) - 3 ) - 2 ;
				float3 edgeColor = float3( 1, 0, 0 ) ;
				switch( ( ( _Time.y * 2 - 3 ) / 6 ) % 7 ){
					case 0 :
					{ 
						edgeColor = float3( 1, 0, 0 ) ;
						break ;
					}
					case 1:
					{ 
						edgeColor = float3( 1, 0.65, 0 ) ;
						break ;
					}
					case 2:
					{ 
						edgeColor = float3( 1, 1, 0 ) ;
						break ;
					}
					case 3:
					{ 
						edgeColor = float3( 0, 1, 0 ) ;
						break ;
					}
					case 4:
					{ 
						edgeColor = float3( 0, 0, 1 ) ;
						break ;
					}
					case 5:
					{ 
						edgeColor = float3( 0.2, 0, 0.5 ) ;
						break ;
					}
					case 6:
					{ 
						edgeColor = float3( 0.5, 0, 0.5 ) ;
						break ;
					}
				}

				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float lengthSq = dot(i.lightDirection, i.lightDirection);
				float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
				float diff = saturate (dot (n, normalize(i.lightDirection)));   
				lightColor += _LightColor0.rgb * (diff * atten);
				c.rgb = c.rgb  * lightColor * 2;
				if( dot( n, _CutOutDirection.xyz ) >= level )
					c.a = 0;
				else
					c.a = 1;
				if( dot( n, _CutOutDirection.xyz ) >= level - 0.1 )
					c.rgb = edgeColor;
                return c;
            }
            ENDCG
        }
	}
    FallBack "Diffuse"
}
