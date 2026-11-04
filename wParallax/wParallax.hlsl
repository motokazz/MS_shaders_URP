// InteriorMapping.hlsl
void InteriorMapping2D_float(float2 UV, float3 TangentViewDir, float RoomDepth, float MidgroundDepth, out float2 RoomUV, out float2 MidgroundUV)
{
    // --- 1. 共通の準備 ---
    RoomDepth = max(RoomDepth, 0.001);
    // 中間オブジェクトは必ず部屋の奥（RoomDepth）より手前になるように制限
    MidgroundDepth = clamp(MidgroundDepth, 0.001, RoomDepth - 0.001);

    float2 roomUV = frac(UV) * 2.0 - 1.0;
    float3 viewDir = -normalize(TangentViewDir);
    
    viewDir.x = abs(viewDir.x) < 0.001 ? 0.001 * sign(viewDir.x) : viewDir.x;
    viewDir.y = abs(viewDir.y) < 0.001 ? 0.001 * sign(viewDir.y) : viewDir.y;
    viewDir.z = abs(viewDir.z) < 0.001 ? -0.001 : viewDir.z;

    float3 id = 1.0 / viewDir;


    // --- 2. 部屋（Room）の計算（前回と同じ） ---
    float kx = (sign(viewDir.x) - roomUV.x) * id.x;
    float ky = (sign(viewDir.y) - roomUV.y) * id.y;
    float kz = (-RoomDepth) * id.z;

    float kMin = min(min(kx, ky), kz);
    float3 pos = float3(roomUV, 0.0) + viewDir * kMin;
    
    float normalizedZ = pos.z / -RoomDepth;
    float2 finalUV = float2(0.0, 0.0);
    float2 tileOffset = float2(0.0, 0.0);
    
    if (kMin == kz)
    {
        finalUV = pos.xy * 0.5 + 0.5;
        tileOffset = float2(1.0, 1.0);
    }
    else if (kMin == kx)
    {
        finalUV.y = pos.y * 0.5 + 0.5;
        if (sign(viewDir.x) > 0.0)
        {
            tileOffset = float2(2.0, 1.0);
            finalUV.x = 1.0 - normalizedZ;
        }
        else
        {
            tileOffset = float2(0.0, 1.0);
            finalUV.x = normalizedZ;
        }
    }
    else
    {
        finalUV.x = pos.x * 0.5 + 0.5;
        if (sign(viewDir.y) > 0.0)
        {
            tileOffset = float2(1.0, 2.0);
            finalUV.y = 1.0 - normalizedZ;
        }
        else
        {
            tileOffset = float2(1.0, 0.0);
            finalUV.y = normalizedZ;
        }
    }
    RoomUV = (finalUV + tileOffset) / 3.0;


    // --- 3. これが追加された「MIDGROUND OBJECT PROCESSING」です ---
    // 部屋の奥壁ではなく、MidgroundDepthで指定した手前のダミー平面との衝突を計算します。
    float kz_mid = (-MidgroundDepth) * id.z;
    float3 midPos = float3(roomUV, 0.0) + viewDir * kz_mid;
    
    // 衝突した座標を 0.0〜1.0 のUV空間に変換
    float2 midUV_local = midPos.xy * 0.5 + 0.5;
    
    // 3x3アトラスのうち、右下のタイル（X=2, Y=0）にマッピングする
    // ※もし中間オブジェクトがアトラスの別の位置にある場合は、この float2(2.0, 0.0) の数字を変えます
    MidgroundUV = (midUV_local + float2(2.0, 0.0)) / 3.0;
}