
void DirectSpecular_half(float3 Specular, float Smoothness, float3 Direction, float3 Color, float3 WorldNormal, float3 WorldView, out float3 Out)
{
	
#if SHADERGRAPH_PREVIEW
   Out = 0;
#else
	Smoothness = exp2(10 * Smoothness + 1);
	WorldNormal = normalize(WorldNormal);
	WorldView = SafeNormalize(WorldView);
	Out = LightingSpecular(Color, Direction, WorldNormal, WorldView, half4(Specular, 0), Smoothness);
#endif
}
