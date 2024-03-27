#define USE_DEFAULT_PIX
#include "../base.shader"

struct BG_VERT_INPUT
{
	float4 location : POSITION0;
	float4 center : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float rotSpeed : TANGENT0;
	float twinkleInterval : NORMAL0;
	float twinkleOffset : NORMAL1;
	float4 twinkleAddColor : NORMAL2;
};

VERT_OUTPUT vert(in BG_VERT_INPUT input)
{
	float4 centerOffset = input.location - input.center;
	centerOffset.xy = rotate(centerOffset.xy, input.rotSpeed.x * _gameTime);

	VERT_OUTPUT output;
	output.location = mul(input.center + centerOffset, _transform);
	float4 twinkleAddColor = input.twinkleAddColor * wave(_gameTime + input.twinkleOffset, input.twinkleInterval);
	output.color = input.color + twinkleAddColor;
	output.uv = input.uv;
	return output;
}
