#include "./Data/base.shader"

float4 _brightColor = 255;
float4 _darkColor = 255;

Texture2D _noiseTexture1;
SamplerState _noiseTexture1_SS;

Texture2D _noiseTexture2;
SamplerState _noiseTexture2_SS;

Texture2D _noiseTexture3;
SamplerState _noiseTexture3_SS;

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

struct VERT_INPUT_BEACON
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};
struct VERT_OUTPUT_BEACON
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 noise1ScrollSpeed : TEXCOORD1;
	float2 noise2ScrollSpeed : TEXCOORD2;
	float2 noise3ScrollSpeed : TEXCOORD3;
	float animationTime : COLOR1;
	float cosTime : COLOR2;
	float sinTime : COLOR3;
};

VERT_OUTPUT_BEACON vert(in VERT_INPUT_BEACON input)
{
	VERT_OUTPUT_BEACON output;
	output.location = mul(input.location, _transform);
	output.color = input.color;
	output.uv = input.uv;
	float animationTime = 0.15 * TWO_PI * _gameTime;
	output.animationTime = animationTime;
	float cosTime = abs(cos(animationTime));
	output.cosTime = ((cosTime + 1) * 0.4) + 0.6;
	float sinTime = saturate(sin(animationTime * 2));
	output.sinTime = sinTime;
	output.noise1ScrollSpeed = float2(0.03, -0.33) * _gameTime;
	output.noise2ScrollSpeed = float2(0.33, -0.08) * _gameTime;
	output.noise3ScrollSpeed = float2(-0.25, -0.1) * _gameTime;
	return output;
}

float2 toPolarCoordinates(float2 uv)
{
	float2 centeredUVs = (uv - float2(0.5, 0.5)) * 2;
	float distance = length(centeredUVs);
	float angle = atan2(centeredUVs.y, centeredUVs.x);
	float2 polarUVs = float2(angle / TWO_PI, distance);
	/*
	float newX = frac(polarUVs.x);
	if (fwidth(polarUVs.x) - 0.0001 > fwidth(newX))
	{
		polarUVs.x = newX;
	}
	*/
	return polarUVs;
}

PIX_OUTPUT pix(in VERT_OUTPUT_BEACON input) : SV_TARGET
{
	float mask = min(input.uv.x, 1 - input.uv.x) * min(input.uv.y, 1 - input.uv.y) * 2;
	float2 polarUVs = toPolarCoordinates(input.uv);
	float rings = cos((polarUVs.y * 6) + (input.animationTime * -4));

#ifdef GTE_PS_4_0_level_9_3

	float2 noise2UVs = input.noise2ScrollSpeed + (float2(2, 0.35) * polarUVs);
	float noise2 = _noiseTexture2.Sample(_noiseTexture2_SS, noise2UVs).b;
	float2 uvDistortion = float2(noise2, noise2) * 0.1;

	float2 noise1UVs = input.noise1ScrollSpeed + (float2(1, 1) * float2(polarUVs.y, polarUVs.x)) + uvDistortion;
	float2 noise3UVs = input.noise3ScrollSpeed + (float2(2, 0.5) * polarUVs) + uvDistortion;

	float noise1 = 1 - _noiseTexture1.Sample(_noiseTexture1_SS, noise1UVs).r;
	float noise3 = _noiseTexture3.Sample(_noiseTexture3_SS, noise3UVs).r;

	float baseNoise = ((1 - noise2) * 0.4) * noise1;
	baseNoise = baseNoise * baseNoise;
	baseNoise = lerp(baseNoise, noise3 * 0.1, 1 - saturate(mask * 2));
	
	float inverseMask = 1 - mask;
	float tightMask = mask * mask;
	float triMask = saturate((cos((polarUVs.x * PI * 6) + (_gameTime * PI * -3) + (PI * 0.5)) * 2) + (inverseMask * 3));

	rings = pow(rings, (noise3 * 8) + 2);
	rings = saturate(rings * input.sinTime * tightMask * inverseMask * 2);
	float animationBase = lerp(rings, pow(mask * input.cosTime, 4), 1 - input.sinTime);

	float colFactor = 1 - saturate(pow(baseNoise * 0.01, animationBase * triMask));
	float4 col = lerp(_darkColor, _brightColor, colFactor);

	float additiveMask = (saturate(colFactor * 100 * baseNoise * mask) + (animationBase * 0.3)) * input.color.a;

	col = saturate(col * additiveMask);
	col.a = 1;

	return col;

#else

	float base = mask * pow(rings, 8) * input.color.a;
	float4 col = lerp(_darkColor, _brightColor, base) * base;
	col.a = 1;
	return col;

#endif

}