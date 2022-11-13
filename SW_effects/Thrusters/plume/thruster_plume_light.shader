#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
	float4 screenLoc : POSITION1;
	float4 lineStart : POSITION2;
	float4 lineEnd : POSITION3;
	float4 color : COLOR0;
    float intensity : COLOR1;
	float2 uv : TEXCOORD0;
	float2 screenUV : TEXCOORD1;
	float flickerMod : TEXCOORD2;
};

float _pivot;
float _lightLength;

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
    input.intensity *= input.fadeAlpha;
    input.length *= input.intensity;

    float2 beamEnd;
    float4 vertexLoc = calculateWorldVertexLoc(input, beamEnd);
    float2 pivot = (beamEnd - input.beamStart.xy) * _pivot;
    vertexLoc.xy -= pivot;

	VERT_OUTPUT_BEAM output;
	output.location = mul(vertexLoc, _transform);
	output.screenLoc = output.location;
	output.lineStart = mul(input.beamStart, _transform);
    float lightEndT = _lightLength * input.intensity / input.length;
	output.lineEnd = mul(float4(lerp(input.beamStart.xy, beamEnd, lightEndT), input.beamStart.zw), _transform);
	output.color = input.color * _color;
    output.intensity = input.intensity;
	output.uv = input.uv;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (output.location.y - 1) / -2;
	output.flickerMod = (sin(input.beamTime * 47) + sin(input.beamTime * 63) + sin(input.beamTime * 141) + sin(input.beamTime)) * 0.25;
	return output;
}

float _litReflectiveStrength;
float _z;
float _litAdditiveStrength;
float _unlitAdditiveStrength;
float _nrmlStrengthLimit;
float4 _hotColor = 255;
float4 _coldColor = 255;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
    float4 tex = _texture.Sample(_texture_SS, input.uv);
	if (tex.b <= 0)
		discard;

	float3 light = lerp(_hotColor.rgb, _coldColor.rgb, input.uv.x) * tex.r;
	light = (light * 0.8) + (light * input.flickerMod * 0.2);
	float3 emissive = (_coldColor.rgb) * tex.g;
	float3 reflectColor = light;

	float2 a = input.screenLoc.xy - input.lineStart.xy;
	float2 b = input.lineEnd.xy - input.lineStart.xy;
	float numer = dot(a, b);
	float denom = dot(b, b);
	float t2 = clamp(numer / denom, 0, 1);

	float3 lightPos = float3((input.lineStart.xy + t2 * b), _z);

	float3 nrml = multiplyAdditiveLightValue(reflectColor, input.screenUV, lightPos, input.screenLoc.xyz, _nrmlStrengthLimit);
    float t = length(nrml);

	float3 litColor = _litReflectiveStrength * reflectColor + (_litAdditiveStrength * light);
	float3 unlitColor = _unlitAdditiveStrength * emissive;
	float3 ret = t * litColor + (1 - t) * unlitColor;
    return float4(ret * tex.b * saturate(input.intensity), 1);
}