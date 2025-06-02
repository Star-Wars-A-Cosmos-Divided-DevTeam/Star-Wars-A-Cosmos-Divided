#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _alphaExponent = 1;

PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
    float4 ret = input.color;
    ret.a = pow(ret.a, _alphaExponent);
    ret *= _color;
    return ret;
}