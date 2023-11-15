#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define CONTRAST_AMOUNT 2.0

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
    if (ret.a <= 0)
        discard;

    ret.rgb = ((ret.rgb - 0.5) * CONTRAST_AMOUNT) + 0.5;

    return ret;
}