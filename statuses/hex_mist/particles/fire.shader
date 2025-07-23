#define USE_DEFAULT_VERT_PARTICLE
#include "../../../common_effects/particles/base_particle.shader"

Texture2D _noiseTex;
SamplerState _noiseTex_SS;

Texture2D _rampTex;
SamplerState _rampTex_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float2 noise2Scale = float2(0.2, 0.2);
	float2 noise2ScrollSpeed = float2(_gameTime * 0.02, _gameTime * -0.08);
	float2 noiseScale = float2(0.15, 0.15);
	float2 noiseScrollSpeed = float2(_gameTime * -0.02, _gameTime * 0.08);
	
	float2 noiseUVs = noiseScale * input.uv + noiseScrollSpeed + float2(input.color.b, input.color.g);
	float2 noise2UVs = noise2Scale * input.uv + noise2ScrollSpeed + float2(input.color.g, input.color.b);
	float noise = _noiseTex.Sample(_noiseTex_SS, noiseUVs).r;
	float noiseUnpacked = noise * 2 - 1;
	
	noise2UVs = lerp(noise2UVs, float2(noiseUnpacked + noise2UVs.x, noiseUnpacked + noise2UVs.y), 0.05);
	float noise2 = _texture.Sample(_texture_SS, noise2UVs).r;
	float fireSize = input.color.r;
	float fireSizeExponent = (fireSize + 0.15) * 8;

	float baseFireMask = 1 - saturate(noise * noise2);
	baseFireMask = 1 - saturate(pow(baseFireMask, fireSizeExponent));
	float squareMask = saturate((1 - abs((input.uv.x * 2) - 1)) * (1 - abs((input.uv.y * 2) - 1)));
	baseFireMask = baseFireMask * input.color.a * saturate(fireSizeExponent * noise) * squareMask;
	if (baseFireMask <= 0)
		discard;
	
#ifdef GTE_PS_4_0_level_9_3
	float baseFire = min(saturate(fireSize * noise2 * 1.2), 0.98);
	baseFire = pow(baseFire, 1 + fireSize * 3);
	float2 rampUVs = float2(baseFire, 0.5);
	float4 col = _rampTex.Sample(_rampTex_SS, rampUVs);
	col *= float4(baseFireMask, baseFireMask, baseFireMask, baseFireMask);
#else
	float baseFire = pow(saturate(fireSize * noise2 * 1.2), 1 + fireSize * 3);
	float red = 0.15 + 0.85 * baseFire;
	float green = 0.05 + pow(baseFire, 1.5) * 0.95;
	float blue = pow(baseFire, 4) * 0.85;
	float4 col = saturate(float4(red * baseFireMask, green * baseFireMask, blue * baseFireMask, baseFireMask));
#endif

	return col;
}
