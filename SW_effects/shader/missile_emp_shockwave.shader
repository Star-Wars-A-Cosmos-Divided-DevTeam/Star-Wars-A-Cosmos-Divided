#include "./Data/common_effects/particles/base_particle.shader"

struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION0;
	float2 normalizedCenter : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};

VERT_OUTPUT2 vert(in VERT_INPUT_PARTICLE input)
{
	float4 loc;
	loc.xy = input.center + rotate(input.offset * _baseSize * input.scale, input.rotation);
	loc.z = 0;
	loc.w = 1;

	VERT_OUTPUT2 output;
	output.location = mul(loc, _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	float4 center = mul(float4(input.center, 0, 1), _transform);
	output.normalizedCenter.x = (center.x + 1) / 2;
	output.normalizedCenter.y = (-center.y + 1) / 2;
	output.color = input.color * _color;
	output.uv = input.uv;
	return output;
}

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

float _shockwaveStrength;
float _waveCount;
float _waveSpeed;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	float4 src = _texture.Sample(_texture_SS, input.uv);
	if(src.a <= 0)
		discard;

	float2 normal = input.normalizedLocation - input.normalizedCenter;
	float dist = length(normal);
	float localDist = length(input.uv - float2(0.5, 0.5));
	float strength = _shockwaveStrength * input.color.a * sin((localDist * TWO_PI * _waveCount) - (_gameTime * _waveSpeed)) * src.a;
	float4 ret = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, input.normalizedLocation + perp(normal) * strength);
	ret.a *= src.a * 4;
	
	float bbAvg = (ret.r + ret.g + ret.b) / 3;
	float4 col;
	col.rgb = bbAvg * input.color.rgb * 1.5;
	ret.rgb = lerp(ret.rgb, col.rgb + ret.rgb, saturate(src.a * strength * 20));
	return ret;
}