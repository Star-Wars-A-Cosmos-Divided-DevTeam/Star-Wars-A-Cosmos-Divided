#define USE_DEFAULT_VERT
#include "./Data/base.shader"

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 output = _texture.Sample(_texture_SS, input.uv) * input.color;
	output *= 1 + wave(_time, .5) * .5;
	if(output.a <= 0)
		discard;
	return output;
}
