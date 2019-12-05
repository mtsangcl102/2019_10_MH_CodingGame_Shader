Shader "Unlit/Q3Shader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise Tex (RGB)" , 2D) = "white" {}
        _Edge ("EdgeThickness", Range(0,1)) = 0.2

    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200
        
        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }
            Lighting On
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            uniform float4 _LightColor0;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 lightDirection : TEXCOORD2 ;
            };

            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _NoiseTex;
        
            float4 _MainTex_ST;
            float _Edge ;

            float3 hue2rgb(float hue) {
                hue = frac(hue); //only use fractional part
                float r = abs(hue * 6 - 3) - 1; //red
                float g = 2 - abs(hue * 6 - 2); //green
                float b = 2 - abs(hue * 6 - 4); //blue
                float3 rgb = float3(r,g,b); //combine components
                rgb = saturate(rgb); //clamp between 0 and 1
                return rgb;
            }

            float3 hsv2rgb(float3 hsv)
            {
                float3 rgb = hue2rgb(hsv.x); //apply hue
                rgb = lerp(1, rgb, hsv.y); //apply saturation
                rgb = rgb * hsv.z; //apply value
                return rgb;
            } 
        
            v2f vert (appdata v)
            {
                v2f o;
                o.lightDirection = ObjSpaceLightDir(v.vertex);                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
               
                float diff = saturate (dot ( normalize(i.normal), normalize(i.lightDirection)));   
                lightColor += _LightColor0 * diff ;
                
                fixed4 noiceValue = tex2D( _NoiseTex, i.uv);
                fixed threshold = _SinTime.w * 0.5 + 0.2;
                fixed alpha = lerp(0,1, saturate((noiceValue.x - threshold) / _Edge));            
            
                // edge color
                float3 hsv = float3( _Time.y * 0.2  , 1 , 1);
                float3 edgeColor = hsv2rgb( hsv ) ;
            
                float3 rgb = lerp( edgeColor , col.rgb , alpha ) * lightColor ; 
                return float4( rgb , alpha ) ;
            }
            ENDCG
        }
        
        Pass 
        {
            Tags { "LightMode" = "ForwardAdd" }
            Lighting On
            Cull Back
            Blend ONE ONE 

            CGPROGRAM
            #pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            uniform float4 _LightColor0;


            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 lightDirection : TEXCOORD2 ;
            };

            sampler2D _MainTex;
            sampler2D _BumpTex;
            sampler2D _NoiseTex;
        
            float4 _MainTex_ST;
            float _Edge ;

            float3 hue2rgb(float hue) {
                hue = frac(hue); //only use fractional part
                float r = abs(hue * 6 - 3) - 1; //red
                float g = 2 - abs(hue * 6 - 2); //green
                float b = 2 - abs(hue * 6 - 4); //blue
                float3 rgb = float3(r,g,b); //combine components
                rgb = saturate(rgb); //clamp between 0 and 1
                return rgb;
            }

            float3 hsv2rgb(float3 hsv)
            {
                float3 rgb = hue2rgb(hsv.x); //apply hue
                rgb = lerp(1, rgb, hsv.y); //apply saturation
                rgb = rgb * hsv.z; //apply value
                return rgb;
            } 
        
            v2f vert (appdata v)
            {
                v2f o;
                o.lightDirection = ObjSpaceLightDir(v.vertex);                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
 
                float diff = saturate (dot ( normalize(i.normal), normalize(i.lightDirection)));   
                float3 lightColor = _LightColor0 * diff ;
                
                fixed4 noiceValue = tex2D( _NoiseTex, i.uv);
                fixed threshold = _SinTime.w * 0.5 + 0.2;
                fixed alpha = lerp(0,1, saturate((noiceValue.x - threshold) / _Edge));            
            
                // edge color
                float3 hsv = float3( _Time.y * 0.2  , 1 , 1);
                float3 edgeColor = hsv2rgb( hsv ) ;
            
                float3 rgb = lerp( edgeColor , col.rgb , alpha ) * lightColor ; 
                return float4( rgb * alpha , 0 ) ;
            }
            ENDCG
        }
       
    }
}
