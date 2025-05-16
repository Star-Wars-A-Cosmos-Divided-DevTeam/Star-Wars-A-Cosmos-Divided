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
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float powerLevel : COLOR2;
	float thermalIntensity : COLOR3;
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
	output.uv = input.uv;
	output.powerLevel = powerLevel;
	output.color = input.color;
	output.thermalIntensity = input.color.r;
	output.randomWaveTimeOffset = input.randomWaveUOffset;
	output.randomWaveUOffset = input.randomWaveUOffset;
	return output;
}

Texture2D _noiseTex1;
SamplerState _noiseTex1_SS;
Texture2D _noiseTex2;
SamplerState _noiseTex2_SS;
Texture2D _baseShieldTex;
SamplerState _baseShieldTex_SS;
float _waveSpeed;
float _waveAlpha;
float _waveCurveInterval;
float _waveCurveMagnitude;
float _waveCurveUOffsetPerSecond;
float _xScale = 1;
float _gradientXWidth = 1;
float _hexDamageIntensity;

float4 _color1 = 255;
float4 _color2 = 255;
float _maxGreen;

PIX_OUTPUT pix(in VERT_OUTPUT_SHIELD input) : SV_TARGET
{
	if (input.powerLevel <= 0)
		discard;
	
	float waveVOffset = (_gameTime + input.randomWaveTimeOffset + wave(input.uv.x + input.randomWaveUOffset + _gameTime * _waveCurveUOffsetPerSecond, _waveCurveInterval) * _waveCurveMagnitude) * _waveSpeed;

	float waveV = fmod(waveVOffset + input.uv.y, 1);
	float gradientWidthY = 1;
	float gradientPowY = 2;
	float cylinderGradientY = 1 - pow(abs((waveV - 0.5) * 2 * gradientWidthY), gradientPowY);

	float gradientPowX = 2;
	float cylinderGradientX = 1 - pow(abs((input.uv.x - 0.5) * 2 * _gradientXWidth), gradientPowX);

	//float uvY = abs(input.uv.y) + (1 - waveColor.a) * pow(1 - input.uv.y, 6) * 0.05;
	float uvY = abs(input.uv.y) + (1 - cylinderGradientY) * pow(1 - input.uv.y, 6) * 0.05;
	float2 basicUVs = float2(input.uv.x * _xScale, uvY);
	
	
	float4 baseTex = _texture.Sample(_texture_SS, basicUVs);
	
	float baseHexDistortionIntensity = -0.07; //-0.07
	float hexDistortion = ((baseTex.r * 2) - 1) * baseHexDistortionIntensity * baseTex.a;
	
	float2 noise1Scale = float2(2, 0.5);
	float2 noise1ScrollSpeed = float2(0.02, 0.025);
	float noise1HexDistortionIntensity = 0.1;
	float2 noise1UVs = (basicUVs * noise1Scale) + ((_gameTime + input.randomWaveTimeOffset) * noise1ScrollSpeed) + float2(hexDistortion * noise1HexDistortionIntensity, hexDistortion * noise1HexDistortionIntensity);
	
	float noise1 = _noiseTex1.Sample(_noiseTex1_SS, noise1UVs).r;
	float noise1Magnitude = 0.2;

	float2 noise2Scale = float2(1.49, 0.6);
	float2 noise2ScrollSpeed = float2(-0.03, -0.2);
	float2 noise2UVs = (basicUVs * noise2Scale) + ((_gameTime + input.randomWaveTimeOffset) * noise2ScrollSpeed) + float2(hexDistortion, hexDistortion) + float2(noise1 * noise1Magnitude, noise1 * noise1Magnitude);
	float noise2 = _noiseTex2.Sample(_noiseTex2_SS, noise2UVs).r;

	float4 baseShieldTex = _baseShieldTex.Sample(_baseShieldTex_SS, basicUVs);
	
	float opacityMul = 3 * input.thermalIntensity;
	float baseNoise = ((noise2 * 0.92) + 0.08) * baseShieldTex.a * opacityMul; //was * baseShieldTex.r before packed mask

	float currentHexes = saturate(saturate(baseShieldTex.r - input.powerLevel) * 40) * (((1 - input.powerLevel) * 0.6) + 0.4);
	float hexPow = pow(baseTex.a, (currentHexes * 7) + 3);
	float hexDamageIntensity = 0.95;
	float newBase = saturate(1 - (currentHexes * hexDamageIntensity)) * hexPow;

	float4 color1 = float4(1, 0, 0.31, 0);
	float4 color2 = float4(1, 0.41, 0, 0);
	
	float4 col = unclampedLerp(_color1, _color2, pow(baseNoise, 1.85));
	col.g = min(col.g, _maxGreen);
	baseNoise = saturate(baseNoise) * newBase;
	float powerLevelFactor = 0.3 + (input.powerLevel * 0.7);
	col *= baseNoise * powerLevelFactor * cylinderGradientX * input.color.a;
	col.a = baseNoise;
	
	return col;
}
