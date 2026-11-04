#ifndef MS_HEAT_BLEND_INCLUDED
#define MS_HEAT_BLEND_INCLUDED

// ============================================================
// 6 Heat Blend (ShaderGraph → HLSL変換)
// ScreenPosition ベース
// ============================================================
float4 Heat6Blend_float(
    float2 screenUV,
    float HeatPower,
    float Size, // ← 現在未使用ですが、元のコードに合わせて残しています
    float2 Pos0, float2 Pos1, float2 Pos2, float2 Pos3, float2 Pos4, float2 Pos5,
    float HeatWeight0, float HeatWeight1, float HeatWeight2, float HeatWeight3, float HeatWeight4, float HeatWeight5,
    float4 HeatColor0, float4 HeatColor1, float4 HeatColor2, float4 HeatColor3, float4 HeatColor4, float4 HeatColor5
)
{
    // =========================================
    // Distance
    // =========================================
    float d0 = distance(screenUV, Pos0.xy);
    float d1 = distance(screenUV, Pos1.xy);
    float d2 = distance(screenUV, Pos2.xy);
    float d3 = distance(screenUV, Pos3.xy);
    float d4 = distance(screenUV, Pos4.xy);
    float d5 = distance(screenUV, Pos5.xy);

    // =========================================
    // Power (ShaderGraph の Power → Reciprocal 構成)
    // =========================================
    d0 = rcp(pow(d0, HeatPower));
    d1 = rcp(pow(d1, HeatPower));
    d2 = rcp(pow(d2, HeatPower));
    d3 = rcp(pow(d3, HeatPower));
    d4 = rcp(pow(d4, HeatPower));
    d5 = rcp(pow(d5, HeatPower));

    // =========================================
    // HeatWeight
    // =========================================
    d0 *= HeatWeight0;
    d1 *= HeatWeight1;
    d2 *= HeatWeight2;
    d3 *= HeatWeight3;
    d4 *= HeatWeight4;
    d5 *= HeatWeight5;

    // =========================================
    // Total Weight
    // =========================================
    float total = d0 + d1 + d2 + d3 + d4 + d5;
    total = max(total, 0.0001);

    // =========================================
    // Normalize & Divide
    // =========================================
    float n0 = d0 / total;
    float n1 = d1 / total;
    float n2 = d2 / total;
    float n3 = d3 / total;
    float n4 = d4 / total;
    float n5 = d5 / total;

    // =========================================
    // Color Blend
    // =========================================
    float4 col =
        HeatColor0 * n0 +
        HeatColor1 * n1 +
        HeatColor2 * n2 +
        HeatColor3 * n3 +
        HeatColor4 * n4 +
        HeatColor5 * n5;
    
    col = min(col, 3);
    return col;
}

// 1つのポイントに対する計算関数（引数に heatPower を追加して汎用化）
float3 CalculatePoint(float2 uv, float2 pos, float3 baseColor, float weight, float heatPower)
{
    float d = distance(uv, pos);
    float strength = pow(d, heatPower);
    return baseColor * strength * weight;
}

#endif // MS_HEAT_BLEND_INCLUDED