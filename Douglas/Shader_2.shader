Shader "CodeinGame/Shader_2"{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpTex ("Bump Texture", 2D) = "bump" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Colour ("_Colour", Color) = (1.0, 1.0, 1.0, 1.0)
        _Speed ("Speed", Float) = 1

    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
        LOD 100

        

        Pass
        {
            Tags{ "LightMode"= "ForwardBase" } 
            //Blend SrcAlpha OneMinusSrcAlpha
            
            //Blend DstAlpha SrcColor
            //Blend OneMinusDstAlpha SrcAlpha
            Blend SrcAlpha OneMinusSrcAlpha //kinda works

          Cull Back         
            Lighting On

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            //#include "UnityLightingCommon.cginc" // for _LightColor0
            uniform float4 _LightColor0;
            
            
            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _NoiseTex;
            float4 _Colour;
            float _Speed;
            float4 _MainTex_ST;
            float4 _BumpTex_ST;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
                float4 tangent : TANGENT;

            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 lightDirection: VECTOR;
            };

            
            v2f vert (appdata v)
            {
                v2f o;
                TANGENT_SPACE_ROTATION; 
                
                o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX (v.uv, _BumpTex);
                o.vertex = UnityObjectToClipPos( v.vertex); 

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = (1,1,1,1);
                fixed4 main = tex2D(_MainTex, i.uv);
                float3 normal =  UnpackNormal(tex2D (_BumpTex, i.uv2)); 
                float cutout = tex2D(_NoiseTex, i.uv).r;
                col.rgb = main.rgb;
                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //float3 lightColor = (0, 0, 0);

                float lengthSq = dot(i.lightDirection, i.lightDirection);
                float atten = 1.0 / (1.0 + lengthSq);
                //Angle to the light
                float diff = saturate (dot (normal, normalize(i.lightDirection)));   
                lightColor += _LightColor0.rgb * (diff * atten); 
                col.rgb = lightColor * col.rgb * 2;
                //col.a = 0;
                col.a = cutout - _SinTime.y * _Speed;

                    
                //col.a = cutout - _Level;
                if(col.a > 0.2 && col.a < 0.5){
                    col.rgb *= _Colour;
                    //col.rgb =lerp(_Colour, col, _Speed);
                }else if (col.a < 0.2){
                    col.a = 0;
                }else{
                    col.a = 1;
                }
                //if (cutout < col.a)
                //discard;
                return col;
            }
            ENDCG
        }
        Pass {
             Cull Back 
             Lighting On
             Tags { "LightMode"="ForwardAdd" }
            //Blend OneMinusDstColor OneMinusSrcAlpha
            Blend SrcAlpha OneMinusSrcAlpha //kinda works
            //Blend SrcAlpha OneMinusDstAlpha  

             CGPROGRAM
             #pragma vertex vert
             #pragma fragment frag

             #include "UnityCG.cginc"
             uniform float4 _LightColor0;

             sampler2D _MainTex;
             sampler2D _Bump;
             float4 _MainTex_ST;
             float4 _Bump_ST;
             sampler2D _NoiseTex;
             float _Speed;
             float4 _Colour;

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
                 float3 lightDirection: VECTOR;
             };
 
             v2f vert (a2v v) {
                 v2f o;
                 TANGENT_SPACE_ROTATION; 

                 o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
                 o.pos = UnityObjectToClipPos( v.vertex); 
                 o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);  
                 o.uv2 = TRANSFORM_TEX (v.texcoord, _Bump);
                 return o;
             }

             float4 frag(v2f i) : COLOR  { 
                 float4 col = tex2D (_MainTex, i.uv);  
                 float3 n =  UnpackNormal(tex2D (_Bump, i.uv2)); 
                 float cutout = tex2D(_NoiseTex, i.uv).r;
                //float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

                 float3 lightColor = (0, 0, 0);

                 float lengthSq = dot(i.lightDirection, i.lightDirection);
                 float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[0].z);
                 //Angle to the light
                 float diff = saturate (dot (n, normalize(i.lightDirection)));   
                 lightColor += _LightColor0.rgb * (diff * atten);
                 col.rgb = lightColor * col.rgb * 2; 
                 col.a = cutout - _SinTime.y * _Speed;

                    
                if(col.a > 0.2 && col.a < 0.5){
                    col.rgb *= _Colour;
                }else if (col.a < 0.2){
                    col.a = 0;
                }
                else{
                    col.a = 1;
                }
                return col;
              }

              ENDCG
        }
    }
}
