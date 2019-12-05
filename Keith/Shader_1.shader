Shader "Custom/Shader_1"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}
		//_level ("Level", Range(0,1) ) = 0.5
		_CutOutDirection ("CutOut Direction", Vector) = (1,1,-1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Lambert alpha

        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _Bump;
		float3 _EdgeColor;
		float _level;
		float4 _CutOutDirection;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_Bump;
			float3 worldNormal;
			INTERNAL_DATA
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
			_level = abs( ( _Time.y * 2 % 6 ) - 3 ) - 1 ;
			switch( ( ( _Time.y * 2 - 3 ) / 6 ) % 7 ){
				case 0 :
				{ 
					_EdgeColor = float3( 1, 0, 0 ) ;
					break ;
				}
				case 1:
				{ 
					_EdgeColor = float3( 1, 0.65, 0 ) ;
					break ;
				}
				case 2:
				{ 
					_EdgeColor = float3( 1, 1, 0 ) ;
					break ;
				}
				case 3:
				{ 
					_EdgeColor = float3( 0, 1, 0 ) ;
					break ;
				}
				case 4:
				{ 
					_EdgeColor = float3( 0, 0, 1 ) ;
					break ;
				}
				case 5:
				{ 
					_EdgeColor = float3( 0.2, 0, 0.5 ) ;
					break ;
				}
				case 6:
				{ 
					_EdgeColor = float3( 0.5, 0, 0.5 ) ;
					break ;
				}
			}

            fixed4 c = tex2D ( _MainTex, IN.uv_MainTex ) ;
			o.Normal = UnpackNormal( tex2D ( _Bump, IN.uv_Bump ) ) ;
			if( dot( WorldNormalVector( IN, o.Normal ), _CutOutDirection.xyz ) >= _level )
				o.Alpha = 0;
			else
				o.Alpha = 1;
			if( dot( WorldNormalVector( IN, o.Normal ), _CutOutDirection.xyz ) >= _level - 0.1 )
				o.Albedo = _EdgeColor;
			else
				o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
