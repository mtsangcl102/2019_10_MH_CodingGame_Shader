Shader "Unlit/Cliff2"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Texture", 2D) = "white" {}
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_EdgeColour1 ("Edge colour 1", Color) = (1.0, 1.0, 1.0, 1.0)
		_EdgeColour2 ("Edge colour 2", Color) = (1.0, 1.0, 1.0, 1.0)
		_Level ("Dissolution level", Range (0.0, 1.0)) = 0.1
		_Edges ("Edge width", Range (0.0, 1.0)) = 0.1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
        	Lighting Off
        	ZWrite Off
        	Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile DUMMY PIXELSNAP_ON
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _EdgeColour1;
			float4 _EdgeColour2;
			float _Level;
			float _Edges;
			float4 _MainTex_ST;
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				#ifdef PIXELSNAP_ON
                o.vertex = UnityPixelSnap (o.vertex);
                #endif

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float cutout = tex2D(_NoiseTex, i.uv).r;
				fixed4 col = tex2D(_MainTex, i.uv);
                
                _Level = abs(_SinTime.w) ;
				if (cutout < _Level)
					discard;

				if(cutout < _Level + _Edges)
					col =lerp(_EdgeColour1, _EdgeColour2, (cutout-_Level)/_Edges );

                    col.a = 1;
				return col;
			}
			ENDCG
		}
		
        Pass {
            Tags {"LightMode" = "ForwardAdd"}                       
            Blend DstAlpha One                                        
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdadd                        
                
                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
                
                struct v2f
                {
                    float4  pos         : SV_POSITION;
                    float2  uv          : TEXCOORD0;
                    float3  lightDir    : TEXCOORD2;
                    float3 normal		: TEXCOORD1;
                    LIGHTING_COORDS(3,4)                            
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
                   	
					o.lightDir = ObjSpaceLightDir(v.vertex);
					
					o.normal =  v.normal;
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 
                    return o;
                }
 
                sampler2D _MainTex;
 
                fixed4 _LightColor0; 
 
                fixed4 frag(v2f i) : COLOR
                {
                    float sinT = abs(_SinTime.w);
                    float dotNormal = dot(i.normal, fixed4(1/sqrt(2),1/sqrt(2),0,0).xyz);
                    
                    if (dotNormal > lerp(1,-1,sinT*0.8) && dotNormal > lerp(1,-1,sinT)) 
                    {
                        discard;
                    }
                                    
                    i.lightDir = normalize(i.lightDir);
                    
                    fixed atten = LIGHT_ATTENUATION(i); 
 
                    fixed4 tex = tex2D(_MainTex, i.uv);
					fixed3 normal = i.normal;                    
                    fixed diff = saturate(dot(normal, i.lightDir));
                    
                    
                    fixed4 c;
                    c.rgb = (tex.rgb * _LightColor0.rgb * diff) * (atten * 2);
                    c.a = 0;
                    
                    return c;
                }
            ENDCG
        }
	}
}