Shader "URP/PermanentBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 0.005
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        ZWrite Off
        Cull Off

        Pass
        {
            Name "BlurPass"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };

            // ポストプロセス時にUnityが背景画像をここに強制注入します
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float _BlurSize;

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                
                // 周囲9マスを混ぜてピントを完全に破壊する
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_BlurSize, -_BlurSize));
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2( 0.0,       -_BlurSize));
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2( _BlurSize, -_BlurSize));
                
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_BlurSize,  0.0));
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2( _BlurSize,  0.0));
                
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_BlurSize,  _BlurSize));
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2( 0.0,        _BlurSize));
                col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2( _BlurSize,  _BlurSize));

                return col / 9.0;
            }
            ENDHLSL
        }
    }
}
