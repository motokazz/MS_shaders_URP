void AdditionalLight_half(float3 SpecColor,float Smoothness,float3 WorldPosition,float3 WorldNormal,float3 WorldView , out float3 Diffuse ,out float3 Specular)
{
	half3 diffuseColor = 0;
	half3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
	Smoothness = exp2(10 * Smoothness + 1);
	WorldNormal = normalize(WorldNormal);
	WorldView = SafeNormalize(WorldView);
	int pixelLightCount = GetAdditionalLightsCount();
	for (int i = 0; i < pixelLightCount; ++i)
	{
		Light light = GetAdditionalLight(i, WorldPosition);
		half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
		diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
		specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), Smoothness);
	}
#endif

	Diffuse = diffuseColor;
	Specular = specularColor;
}

