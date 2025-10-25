//#define USE_DEFAULT_VERT_PARTICLE
//#define ENABLE_WORLD_LOC
//#include "./Data/common_effects/particles/base_particle.shader"
//#define USE_DEFAULT_VERT
#include "./Data/base.shader"

Texture2D _noiseTex1;
SamplerState _noiseTex1_SS;

float4 _color1 = 255;
float4 _color2 = 255;
float2 _noise1ScrollSpeed;
float2 _noise2ScrollSpeed;

struct VERT_INPUT_ION_AOE
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float randomTimeOffset : TEXCOORD2;
};

struct VERT_OUTPUT_ION_AOE
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float offsetTime : TEXCOORD1;
	float2 noise1ScrollSpeed : TEXCOORD2;
	float2 noise2ScrollSpeed : TEXCOORD3;
};

VERT_OUTPUT_ION_AOE vert(in VERT_INPUT_ION_AOE input)
{
	VERT_OUTPUT_ION_AOE output;
	output.location = mul(input.location, _transform);
	output.color = input.color * _color;
	output.uv = input.uv;
	output.offsetTime = input.randomTimeOffset + _gameTime;
	output.noise1ScrollSpeed = _noise1ScrollSpeed * output.offsetTime;
	output.noise2ScrollSpeed = _noise2ScrollSpeed * output.offsetTime;
	return output;
}

float2 toPolarCoordinates(float2 uv)
{
	float2 centeredUVs = (uv - float2(0.5, 0.5)) * 2;
	float distance = length(centeredUVs);
	float angle = atan2(centeredUVs.y, centeredUVs.x);
	float2 polarUVs = float2(angle / TWO_PI, distance);
	/*
	float newX = frac(polarUVs.x);
	if (fwidth(polarUVs.x) - 0.0001 > fwidth(newX))
	{
		polarUVs.x = newX;
	}
	*/
	return polarUVs;
}

PIX_OUTPUT pix(in VERT_OUTPUT_ION_AOE input) : SV_TARGET
{
	float2 polarUVs = toPolarCoordinates(input.uv);
	float2 polarUV1 = polarUVs;
	float2 polarUV2 = polarUVs;

	polarUV1.x += sin(polarUVs.y + (input.offsetTime * 0.12)) * 0.05;
	polarUV1.y *= 0.2; //was 0.2
	polarUV1 += input.noise1ScrollSpeed;
	
	polarUV2.y *= 0.3;
	polarUV2 += input.noise2ScrollSpeed;

	float4 noise1 = _noiseTex1.Sample(_noiseTex1_SS, polarUV1);
	float4 baseNoise = _texture.Sample(_texture_SS, polarUV2);
	
	float2 centeredUVs = input.uv - 0.5;
	float centerDot = (1 - abs(centeredUVs.x)) * (1 - abs(centeredUVs.y));
	centerDot = pow(saturate(centerDot * 1.02), 16);

	float baseAlpha = noise1.r * baseNoise.g;
	float fadeAlpha = 1 - (polarUVs.y * polarUVs.y);
	baseAlpha = pow(baseAlpha, 1 + (1 - fadeAlpha));

	float3 col = lerp(_color1.rgb, _color2.rgb, pow((1 - baseNoise.a) * 1.3 * fadeAlpha, 4) + centerDot);
	
	return float4(col * (saturate(baseAlpha * input.color.a * fadeAlpha * 1.5) + centerDot), 1);
}