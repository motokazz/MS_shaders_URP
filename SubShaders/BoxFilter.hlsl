void BoxFilter_float
  (UnityTexture2D source, float2 uv, float width, UnitySamplerState state,
   out float4 output)
{
	
	const uint taps = 5.0f;

	float4 acc = 0;

	for (uint y = 0; y < taps; y++)
	{
		for (uint x = 0; x < taps; x++)
		{
			float2 displace = float2(x, y) - (taps - 1) * 0.5;
			acc += source.Sample(state, uv + displace * width / taps);
		}
	}
	
	output = acc / (taps * taps);
}

