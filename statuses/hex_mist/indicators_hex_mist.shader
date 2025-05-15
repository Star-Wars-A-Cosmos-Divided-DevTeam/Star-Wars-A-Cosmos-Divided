#define DISABLE_ROTATION
#define ENABLE_INTENSITY
#define ENABLE_ROOF_ALPHA
#include "../../base_shipquad.shader"

void scaleByIntensity(inout VERT_GEOM_INPUT output)
{
	float scale = lerp(0.25, 1, output.intensity);
	output.uvLocation = (output.uvLocation - float2(0.5, 0.5)) / scale + float2(0.5, 0.5);
	output.uvSize = output.uvSize / scale;
}

VERT_GEOM_INPUT vert(in VERT_GEOM_INPUT input)
{
	VERT_GEOM_INPUT output = input;
	scaleByIntensity(output);
	return output;
}

float4 getCustomPixelColor(in GEOM_OUTPUT input)
{
	float4 tex;
	float4 c;
	float outline;
	tex = _texture.Sample(_texture_SS, input.uv);
	c = lerp(float4(1, 0, 0, 1), float4(1, 0.75, 0, 1), tex.r);
	c.a *= tex.a;
	c *= 1 + wave(_time + input.uv.x, .5) * .5;
	outline = tex.b;
	float gradient = wave(pow(input.uv.y, 4) + _time, 1);
	outline *= 0.05 + (gradient * 0.95);
	c.rgb += float3(outline, outline, outline);
	c.a *= input.color.a;
	c.a *= lerp(0.4, 1, _roofOpacity);
	return c;
}

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
	float4 ret = getCustomPixelColor(input);
	if (ret.a <= 0)
		discard;
	return ret;
}