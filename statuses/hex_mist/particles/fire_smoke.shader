#define USE_DEFAULT_VERT_PARTICLE
#define ENABLE_SCREEN_UV
#include "../../../common_effects/particles/base_particle.shader"

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 ret = _texture.Sample(_texture_SS, input.uv);
	ret = ret * input.color;
	float mask = pow(_diffuseTarget.Sample(_diffuseTarget_SS, input.screenUV).a, 10);
	ret.a = saturate(ret.a - mask);
	if (ret.a <= 0)
		discard;
	
	return ret;
}
