#include "./Data/base.shader"

struct VERT_INPUT_DRAIN
{
	float4 location : POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
};
struct VERT_OUTPUT_DRAIN
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float2 screenUV : TEXCOORD1;
	float2 texScroll : TEXCOORD2;
	float2 noiseScroll : TEXCOORD3;
	float intensity : COLOR1;
	float inverseIntensity : COLOR2;
	float doubleIntensity : COLOR3;
};

float2 _noiseScrollSpeed;
float2 _texScrollSpeed;

VERT_OUTPUT_DRAIN vert(in VERT_INPUT_DRAIN input)
{
	VERT_OUTPUT_DRAIN output;
	output.location = mul(input.location, _transform);
	output.color = input.color;
	output.uv = input.uv;
	output.screenUV.x = (output.location.x + 1) / 2;
	output.screenUV.y = (-output.location.y + 1) / 2;
	output.texScroll = _texScrollSpeed * _gameTime;
	output.noiseScroll = _noiseScrollSpeed * _gameTime;
	output.intensity = input.color.a;
	output.inverseIntensity = 1 - input.color.a;
	output.doubleIntensity = saturate(input.color.a * 2);
	return output;
}

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

float2 _noiseScale;
float _distortionStrength;
float2 _texScale;

float4 _hotColor = 255;
float4 _coldColor = 255;
float _normalIntensity;

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

PIX_OUTPUT pix(in VERT_OUTPUT_DRAIN input) : SV_TARGET
{
	float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).r * input.doubleIntensity;
	if (mask <= 0)
		discard;

	float2 polarCoords = toPolarCoordinates(input.uv);
	
	float2 noiseUVs = (polarCoords * _noiseScale) + input.noiseScroll;
	float distortion = ((_noiseTexture.Sample(_noiseTexture_SS, noiseUVs).r * 2) - 1) * _distortionStrength;
	
	float2 texUVs = ((polarCoords + distortion) * _texScale) + input.texScroll;
	float tex = _texture.Sample(_texture_SS, texUVs).r;

	float baseNoise = saturate(pow(tex, input.inverseIntensity * input.inverseIntensity * 20));
	baseNoise = saturate(baseNoise * (2 - input.intensity));

	float3 baseNormal = colorToNormals(_normalsTarget.Sample(_normalsTarget_SS, input.screenUV).rgb);
	float3 normal = baseNormal;
	normal.z = _normalIntensity; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float edges = normal.z;

	float4 col = lerp(_coldColor, _hotColor, baseNoise);
	baseNoise = pow(baseNoise, edges);
	baseNoise = baseNoise * mask;
	col.rgb = col.rgb * baseNoise;
	col.rgb *= length(baseNormal);

	return col;
}