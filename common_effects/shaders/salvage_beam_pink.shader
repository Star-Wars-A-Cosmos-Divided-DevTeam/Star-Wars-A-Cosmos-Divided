#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
	float length : POSITION3;
	float4 color : COLOR0;
	float intensity : COLOR1;
	float2 uv : TEXCOORD0;
	float beamTime : TEXCOORD1;
};

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
	VERT_OUTPUT_BEAM output;
	float4 vertexLoc = calculateWorldVertexLoc(input);
	output.location = mul(vertexLoc, _transform);
	output.length = input.length;
	output.color = input.color * _color;
	output.color.a *= input.fadeAlpha;
	output.intensity = input.intensity;
	output.uv = input.uv;
	output.beamTime = input.beamTime;
	return output;
}

float _endCapSize;
float _startCapSize;
float _gradientPow;
float _sineFreq;
float _sineAmp;
float _noiseAmp;
float _gradientIntensity;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float endCap = min((1 - input.uv.x) * input.length / _endCapSize, 1);
	float startCap = min((input.uv.x) * input.length / _startCapSize, 1);

	float gradientWidth = 4 * (1/saturate(input.color.a));
	float gradient =  1 - pow(abs((input.uv.y - 0.5) * 2 * gradientWidth), _gradientPow);

	const float SINE_SPEED = -5.86;
	float sineWave = sin((input.uv.x * input.length * _sineFreq) + (SINE_SPEED * input.beamTime)) * _sineAmp;

	const float NOISE_SPEED = -14.12;
	const float2 NOISE_SCALE = float2(0.02, -0.58);
	float2 noiseUVs = float2(((NOISE_SPEED * input.beamTime) + (input.length * input.uv.x)) * NOISE_SCALE.x, (input.uv.y * NOISE_SCALE.y) + sineWave);
	float wavyNoise = _noiseTexture.Sample(_noiseTexture_SS, noiseUVs).r;
	wavyNoise = (wavyNoise - 0.5) * 2 * _noiseAmp;


	const float3 COLOR_A = float3(1, 0, 0.39); //float3(1, 0.34, 0);
	const float3 COLOR_B = float3(1, 0.32, 0.49); //float3(1, 0.45, 0.23);
	float3 gradientColor = float3(1, 0.64, 0.92) * gradient * _gradientIntensity;
	float2 texUVs;
	if (input.uv.y >= 0.5)
	{
		texUVs = float2(input.uv.x * input.length, input.uv.y - wavyNoise);
	}
	else
	{
		texUVs = float2(input.uv.x * input.length, input.uv.y + wavyNoise);
	}
	float4 tex = _texture.Sample(_texture_SS, texUVs);
	const float GRADIENT_ALPHA = 1.11;
	float alpha = saturate(tex.a + (gradient * GRADIENT_ALPHA));
	float3 col = lerp(COLOR_A, COLOR_B, alpha) * endCap * startCap * input.color.a;
	col = saturate(col + gradientColor);

	return float4(col, alpha * input.color.a);
}