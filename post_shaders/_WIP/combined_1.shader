#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define SATURATION_AMOUNT 1.11
#define CONTRAST_AMOUNT 1.11

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
    if (ret.a <= 0)
        discard;

    float luminance = dot(ret.rgb, float3(0.299, 0.587, 0.114));
    ret.rgb = lerp(luminance, ret.rgb, SATURATION_AMOUNT);

    ret.rgb = ((ret.rgb - 0.5) * CONTRAST_AMOUNT) + 0.5;

    return ret;
}