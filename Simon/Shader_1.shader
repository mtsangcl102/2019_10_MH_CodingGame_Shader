Shader "Custom/Shader_1" {
    Properties {
        _Bump ("Bump", 2D) = "bump" {}
        _NoiseTex ("Noise", 2D) = "white" {}
        _TextureScaleFactor ("Scale Factor", float) = 1
        _borderThickness ("Border Thickness", float) = 0.1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
 
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
 
        sampler2D _Bump;
        sampler2D _NoiseTex;
        float _TextureScaleFactor;
        float _borderThickness;
 
        struct Input {
            float2 uv_Bump;
            float3 worldNormal;
        };
 
        void vert (inout appdata_full v) {
        }
 
        void surf (Input IN, inout SurfaceOutput o) {
            
            // decay
            half percent = sin(_Time.z)+0.5;
            half4 col = half4(1,1,1,1);
            half color = sin(_Time.z*1.3)+0.5;
            half4 borderColor = half4( color, 0, 1-color, 1 );
            
            half cutoff = percent + (1 - tex2D(_NoiseTex, (IN.uv_Bump * _TextureScaleFactor) % 1 ));
            clip(col.a - cutoff);
            if (col.a < cutoff + _borderThickness) col.rgb = col.rgb * 0.7 + borderColor.rgb*0.3;
            //else col.r += 0.05;
            if(col.a > 0) col.a = 1; else col.a = 0; 
            
            o.Albedo = col.rgb;
            o.Normal = UnpackNormal (tex2D (_Bump, IN.uv_Bump));
            o.Alpha = col.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}