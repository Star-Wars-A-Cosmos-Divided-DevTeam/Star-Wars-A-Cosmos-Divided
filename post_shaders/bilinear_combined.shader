#define USE_DEFAULT_VERT
#include "./Data/base.shader"

#define SCALE_AMOUNT 1.0
#define SATURATION_AMOUNT 1.08
#define CONTRAST_AMOUNT 1.08
#define BRIGHTNESS 0.92

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float2 uv = input.uv * SCALE_AMOUNT;

    if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
    {
        return float4(0, 0, 0, 0);
    }

    float4 ret = _texture.Sample(_texture_SS, input.uv) * input.color;
    if (ret.a <= 0)
        discard;

    float luminance = dot(ret.rgb, float3(0.299, 0.587, 0.114));
    ret.rgb = lerp(luminance, ret.rgb, SATURATION_AMOUNT);

    ret.rgb = ((ret.rgb - 0.5) * CONTRAST_AMOUNT) + 0.5;

    ret.rgb = ret.rgb * BRIGHTNESS;

    return ret;
}
