// Name: FlipbookBlend (任意)
// Type: String（FileでもOK）
// Inputs:  UV (Vector2), Frame (Vector1), Rows (Vector1), Columns (Vector1)
// Outputs: UVA (Vector2), UVB (Vector2), Blend (Vector1)

void FlipbookBlend_float(float2 UV, float Frame, float Columns, float Rows,
                         out float2 UVA, out float2 UVB, out float Blend)
{
    float totalFrames = Rows * Columns;
    //float frame = clamp(Frame, 0.0, totalFrames + 1.0);
    float frame = Frame;
    
    Blend = frac(frame);
    float curFrame = floor(frame);

    float2 cellSize = float2(1.0 / Columns, 1.0 / Rows);

    // ここだけ変更！ Y座標を (Rows - 1 - y) にする
    float x = fmod(curFrame, Columns);
    float y = Rows - 1.0 - floor(curFrame / Columns); // ← これがミソ！

    float2 coord0 = float2(x, y);
    UVA = UV * cellSize + coord0 * cellSize;

    //float nextFrame = min(curFrame + 1.0, totalFrames - 1.0);
    float nextFrame = curFrame + 1.0;
    float x1 = fmod(nextFrame, Columns);
    float y1 = Rows - 1.0 - floor(nextFrame / Columns);
    float2 coord1 = float2(x1, y1);
    UVB = UV * cellSize + coord1 * cellSize;
    
}