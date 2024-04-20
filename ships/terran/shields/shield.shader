#include "./Data/base.shader"

struct VERT_INPUT_SHIELD
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float powerLevel : COLOR1;
	float randomWaveTimeOffset : POSITION1;
	float randomWaveUOffset : POSITION2;
};

struct VERT_OUTPUT_SHIELD
{
	float4 location : SV_POSITION;
	float4 color1 : COLOR0;
	float4 color2 : COLOR1;
	float2 uv : TEXCOORD0;
	float powerLevel : COLOR2;
	float randomWaveTimeOffset : POSITION1;
	float randomWaveUOffset : POSITION2;
};

float4 _fullPowerColor1 = 255;
float4 _fullPowerColor2 = 255;
float4 _lowPowerColor1 = 255;
float4 _lowPowerColor2 = 255;
VERT_OUTPUT_SHIELD vert(in VERT_INPUT_SHIELD input)
{
	VERT_OUTPUT_SHIELD output;
	output.location = mul(input.location, _transform);
	float powerLevel = smoothstep(0, 1, input.powerLevel);
	float4 colorFactor1 = _fullPowerColor1 * powerLevel + _lowPowerColor1 * (1 - powerLevel);
	float4 colorFactor2 = _fullPowerColor2 * powerLevel + _lowPowerColor2 * (1 - powerLevel);
	output.color1 = input.color * colorFactor1 * _color;
	output.color2 = input.color * colorFactor2 * _color;
	output.uv = input.uv;
	output.powerLevel = powerLevel;
	output.randomWaveTimeOffset = input.randomWaveUOffset;
	output.randomWaveUOffset = input.randomWaveUOffset;
	return output;
}

Texture2D _waveTex;
SamplerState _waveTex_SS;
Texture2D _maskTex;
SamplerState _maskTex_SS;
float _waveSpeed;
float _waveAlpha;
float _waveCurveInterval;
float _waveCurveMagnitude;
float _waveCurveUOffsetPerSecond;
float _lowPowerThicknessExponent;
float _xScale = 1;
PIX_OUTPUT pix(in VERT_OUTPUT_SHIELD input) : SV_TARGET
{
	float waveVOffset = (_gameTime + input.randomWaveTimeOffset + wave(input.uv.x + input.randomWaveUOffset + _gameTime * _waveCurveUOffsetPerSecond, _waveCurveInterval) * _waveCurveMagnitude) * _waveSpeed;
	float4 waveColor = _waveTex.Sample(_waveTex_SS, float2(input.uv.x * 8, input.uv.y + waveVOffset));
	
	float uvY = abs(input.uv.y) + (1 - waveColor.a) * pow(1 - input.uv.y, 6) * 0.05;
	float4 baseColor = _texture.Sample(_texture_SS, float2(input.uv.x * _xScale, uvY));

	float hexMask = _maskTex.Sample(_maskTex_SS, float2(input.uv.x * _xScale, uvY)).r;
	float currentHexes = saturate(saturate(hexMask - input.powerLevel) * 40) * (((1 - input.powerLevel) * 0.6) + 0.4);
	float hexPow = pow(baseColor.r, (currentHexes * 7) + 3);
	float newBase = saturate(1 - (currentHexes * 0.5)) * hexPow;
	
	baseColor.a += baseColor.a * waveColor.a * _waveAlpha;
	float basePow = pow(baseColor.r, 3);

	float4 ret = baseColor * lerp(input.color1, input.color2, (waveColor.a * hexPow) + newBase);
	ret.rgb *= ret.a * newBase;
	if(ret.a <= 0)
		discard;
	return ret;
}
