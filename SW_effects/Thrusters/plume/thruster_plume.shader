#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
    float length : POSITION3;
	float4 color : COLOR0;
    float intensity : COLOR1;
	float2 uv : TEXCOORD0;
    float beamTime : TEXCOORD1;
	float buff : TEXCOORD2;
};

float2 _thicknessOverIntensity;
float _additionalBuffedThickness;
float _additionalBuffedIntensity;

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
    input.intensity *= input.fadeAlpha;
	input.length *= input.intensity;
	float additionalBuffedIntensity = max(_additionalBuffedIntensity, 0.00000001);
	float buff = max(input.intensity - 1, 0) * (1 / additionalBuffedIntensity);
	float buffThickness = lerp(0, _additionalBuffedThickness, max(input.intensity - 1, 0) * (1 / additionalBuffedIntensity));
    input.vertexOffset.y *= lerp(_thicknessOverIntensity.x, _thicknessOverIntensity.y, input.intensity) + buffThickness;

	VERT_OUTPUT_BEAM output;
    float4 vertexLoc = calculateWorldVertexLoc(input);
	output.location = mul(vertexLoc, _transform);
    output.length = input.length;
	output.color = input.color * _color;
    output.intensity = input.intensity;
	output.uv = input.uv;
    output.beamTime = input.beamTime;
	output.buff = buff * 0.5;
	return output;
}

float4 _hotColor = 255;
float4 _coldColor = 255;
float4 _centerColor = 255;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float xGradient = saturate(input.uv.x - 0.15);
	float2 xScrollSpeed = float2((input.beamTime + _gameTime) * -2, input.beamTime);

	float4 noiseTex1 = _noiseTexture.Sample(_noiseTexture_SS, input.uv + xScrollSpeed);
	float noise1 = noiseTex1.r;
	float2 distortionUVs = float2(lerp(input.uv, float2(noise1, noise1), 0.05));
	float4 noiseTex2 = _noiseTexture.Sample(_noiseTexture_SS, float2(distortionUVs.x, 0) + xScrollSpeed);
	float noise2 = noiseTex2.r;
	noise2 = saturate(noise2 * xGradient);
	float4 tex = _texture.Sample(_texture_SS, lerp(distortionUVs, input.uv, 1 - xGradient));
	float t = pow(saturate(1 - (noise2 * tex.a)), 1 + input.buff * 10);

	float4 col = lerp(_hotColor, _coldColor, t);
	col = lerp(col, _coldColor, pow(1 - tex.r, 60));
	float4 col2 = lerp(_coldColor, _centerColor, pow(tex.r, 1 - input.buff));
	col2 = saturate(pow(col2, 1.85));

	return float4(saturate(col.rgb + col2.rgb), tex.a * 0.8) * input.color;
}