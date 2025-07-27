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

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	float4 src = _texture.Sample(_texture_SS, input.uv);
	src.a *= input.color.a;
	if (src.a <= 0 || src.r <= 0)
		discard;

	float2 normal = input.normalizedLocation - input.normalizedCenter;
	float2 uv = input.normalizedLocation - normal * _shockwaveStrength * src.a * input.color.a;

	float4 ret = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, uv);
	ret.rgb = lerp(ret.rgb, input.color.rgb, src.a);
	ret.a = src.r; // Use red color channel as actual alpha. Weird, but whatever.
	return ret;
}