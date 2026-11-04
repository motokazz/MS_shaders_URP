Shader "Hidden/URP_AbsoluteBlur"
{
    Properties
    {
        _BlurStrength ("Blur Strength", Range(1, 30)) = 10.0
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "AbsoluteBlur"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D_X(_BlitTexture);
            // 修正箇所1: 名前が衝突しないように sampler_BlitTexture に変更
            SAMPLER(sampler_BlitTexture);
            float4 _BlitTexture_TexelSize;
            
            float _BlurStrength;

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
                
                half4 color = half4(0, 0, 0, 0);
                float totalWeight = 0;

                for (int x = -3; x <= 3; x++)
                {
                    for (int y = -3; y <= 3; y++)
                    {
                        float2 offset = float2(x, y) * _BlitTexture_TexelSize.xy * _BlurStrength;
                        float weight = exp(-(x*x + y*y) / 4.0);
                        
                        // 修正箇所2: 変更したサンプラー名を使用してサンプリング
                        color += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv + offset) * weight;
                        totalWeight += weight;
                    }
                }

                return color / totalWeight;
            }
            ENDHLSL
        }
    }
}