Shader "Custom/Shader 1 (Dissolve Surface Shader)"
{
    Properties
    {
      _MainTex ("Texture", 2D) = "white" {}      
      _DissolveTex ("Dissolve Map", 2D) = "white" {}        
      _DissolveEdgeRange("Dissolve Edge Range", float) = 0.1
    }
   
    SubShader
    {
      Tags { "RenderType" = "Opaque" }
      Cull Off
   
      CGPROGRAM
      #pragma surface surf Lambert
 
      struct Input
      {
          float2 uv_MainTex;
          float2 uv_DissolveTex;
      };
     
      sampler2D _MainTex;
      sampler2D _DissolveTex;
      float _DissolveEdgeRange;
         
      void surf (Input IN, inout SurfaceOutput o)
      {
        half dissolveIntensity = _SinTime.z / 2 + 0.5;
      
      	float4 dissolveColor = tex2D(_DissolveTex, IN.uv_DissolveTex);      	      	
        half dissolveClip = dissolveColor.r - dissolveIntensity;
        half edgeRamp = max(0, _DissolveEdgeRange - dissolveClip) * 50;
        
        clip( dissolveClip );
        
        float4 texColor = tex2D(_MainTex, IN.uv_MainTex);                
        float4 edgeColor = float4(_SinTime.x / 2 + 0.5, _SinTime.y / 2 + 0.5, _SinTime.z / 2 + 0.5, 1);
        o.Albedo = lerp( texColor, edgeColor, edgeRamp );                        
        return;
      }
      ENDCG
    }
    Fallback "Diffuse"
 }