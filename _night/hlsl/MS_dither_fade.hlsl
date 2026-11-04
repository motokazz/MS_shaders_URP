#ifndef MS_DITHER_FADE_INCLUDED
#define MS_DITHER_FADE_INCLUDED

// =======================================================
// ディザリング値の取得
// =======================================================
float GetDither(float2 screenUV)
{
    //float2 pixelPos = screenUV * _ScreenParams.xy;
    //uint x = uint(fmod(pixelPos.x, 4.0));
    //uint y = uint(fmod(pixelPos.y, 4.0));
    
    uint2 pixelPos = uint2(screenUV * _ScreenParams.xy + 0.5);
    uint x = pixelPos.x % 4;
    uint y = pixelPos.y % 4;
    
    float4x4 dither = float4x4(
                         1.0, 9.0, 3.0, 11.0,
                        13.0, 5.0, 15.0, 7.0,
                         4.0, 12.0, 2.0, 10.0,
                        16.0, 8.0, 14.0, 6.0
                    ) / 17.0;
    return dither[x][y];
}

// =======================================================
// カメラからの距離に応じたディザフェード処理
// =======================================================
void ApplyNearDitherFade(float startDist, float endDist, float cutoff, float2 screenUV)
{
        // オブジェクトのワールド座標中心位置とカメラの距離を計算
        float3 centerWS = TransformObjectToWorld(float3(0, 0, 0));
        float dist = distance(_WorldSpaceCameraPos, centerWS);
        
        float ditherValue = GetDither(screenUV);
        
        // ゼロ除算を防ぐための安全対策（startとendが全く同じ値だと計算がおかしくなるため）
        float distRange = max(startDist - endDist, 0.0001);
        float nearFadeT = saturate((dist - endDist) / distRange);
        
        float ditherResult = (nearFadeT > ditherValue) ? 1.0 : 0.0;
        clip(ditherResult - cutoff);
}

#endif // MS_DITHER_FADE_INCLUDED