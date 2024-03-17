#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION1;
	float length : POSITION3;
	float4 color : COLOR0;
	float intensity : COLOR1;
	float3 uvq : TEXCOORD0;
	float beamTime : TEXCOORD1;
};

float _extraBeginLength;
float _extraEndLength;
float _extraEndArc;
float _minAlpha;

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
	input.intensity = clamp(input.intensity, -1, 1);

	VERT_OUTPUT_BEAM output;
	float4 vertexLoc = calculateWorldVertexLocProjZ(input, _extraBeginLength, _extraEndLength, 0, _extraEndArc);
	output.location = mul(float4(vertexLoc.xy, 0, 1), _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	output.length = input.length;
	output.color = input.color * _color;
	output.color.a *= input.fadeAlpha * lerp(_minAlpha, 1, abs(input.intensity));
	output.intensity = input.intensity;
	output.uvq = float3(input.uv.x, input.uv.y, 1) * vertexLoc.w;
	output.beamTime = input.beamTime;
	return output;
}

float _displacementStrength;
float _displacementSpeed;
float _displacementLength;

float4 _color1 = 255;
float4 _color2 = 255;

float _additiveStrength;
float _noiseScaleX;
float _noiseScaleY;

float _noiseScrollSpeed;
float _noisePanSpeed;

float _endFadeLength;

Texture2D _noiseTex;
SamplerState _noiseTex_SS;

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;


PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float2 uv = input.uvq.xy / input.uvq.z;
	float baseGradient = 1 - abs((uv.y - 0.5) * 2);  //generating a vertical cylinder gradient
	baseGradient = pow(baseGradient, 1.5);
	baseGradient *= min(uv.x * input.length, min((1 - uv.x) * input.length / _endFadeLength, 1));

	float2 displacementUV = uv * float2(0.02 * input.length, 4);
	displacementUV.x += input.beamTime * _displacementSpeed;
	float displacement = _texture.Sample(_texture_SS, displacementUV).r;

	float2 noiseUV = uv * float2(_noiseScaleX * input.length, _noiseScaleY);
	noiseUV.x += input.beamTime * _noiseScrollSpeed;
	noiseUV.y += _gameTime * _noisePanSpeed;
	float noise = _noiseTex.Sample(_noiseTex_SS, noiseUV).r;
	float noiseExponent = (noise * 12) + 5;

	float displacementLines = saturate(pow(displacement * baseGradient, noiseExponent) * noise);

#ifdef GTE_PS_4_0_level_9_3

	float2 dd = float2(ddx(uv.x), ddy(uv.x));
	dd = normalize(dd) / length(dd) * float2(ddx(input.normalizedLocation.x), ddy(input.normalizedLocation.y));
	float2 captureUV = input.normalizedLocation + _displacementStrength * dd * noise * baseGradient * input.intensity / input.length;
	float4 capturedColor = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, captureUV);

	float4 ret;
	ret.a = baseGradient;
	float blendFactor = 1 - saturate(((1 - noise) + 0.2) * 3 * baseGradient);
	float4 col = lerp(_color1, _color2, displacementLines + blendFactor) * _additiveStrength;
	ret.rgb = capturedColor.rgb + col.rgb;
	ret.rgb *= input.color.rgb;
	return ret;

#else

	float4 baseColor;
	baseColor.a = noise * baseGradient * 0.25;
	baseColor.rgb = lerp(_color1, _color2, displacementLines * noise) * _additiveStrength;
	baseColor.rgb *= input.color.rgb;
	baseColor.rgb *= saturate(baseGradient * 2);
	return baseColor;

#endif
}