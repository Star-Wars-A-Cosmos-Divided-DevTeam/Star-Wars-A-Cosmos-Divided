#define ENABLE_SCREEN_UV
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

float2 _noiseScrollSpeed;
float2 _texScrollSpeed;

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;

float2 _noiseScale;
float _distortionStrength;
float2 _texScale;
float _invertTex;
float _twistStrength;
float _coldColorAdd;

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

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
	float doubleIntensity = saturate(input.color.a * 2);
	float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).r * doubleIntensity;
	if (mask <= 0)
		discard;

	// Moved from vert. Can be included in custom geom implementation if necessary
	float2 texScroll = _texScrollSpeed * _gameTime;
	float2 noiseScroll = _noiseScrollSpeed * _gameTime;
	float intensity = input.color.a;
	float inverseIntensity = 1 - input.color.a;
	// End moved from vert
	
	float2 polarCoords = toPolarCoordinates(input.uv);
	
	//HARDCODED VALUES (Heat Exchanger)
	//float2 noiseScale = float2(1, 0.7);
	//float2 noiseScroll = float2(0.3, 1) * _gameTime;
	//float2 noiseUVs = (polarCoords * noiseScale) + noiseScroll;
	
	//TWIST VERSION
	//float twist = 1;
	//float2 noiseUVs = (polarCoords * noiseScale);
	//noiseUVs.x += (noiseUVs.y * twist);
	//noiseUVs += noiseScroll;
	
	float2 noiseUVs = (polarCoords * _noiseScale) + noiseScroll;

	//SCALING DISTORTION FROM CENTER VERSION
	//float distortionIntensityAtCenter = 0;
	//float centerOffset = 0.05;
	//distortionStrength = lerp(distortionStrength, distortionStrength * distortionIntensityAtCenter, 1 - saturate(2 * (polarCoords.y - centerOffset)));

	float distortion = ((_noiseTexture.Sample(_noiseTexture_SS, noiseUVs).r * 2) - 1) * _distortionStrength;
	
	//HARDCODED VALUES (Heat Exchanger)
	//float2 texScale = float2(1, 0.08);
	//float2 texScroll = float2(0.125 * 2, 0.4) * _gameTime;
	//float2 texUVs = ((polarCoords + distortion) * texScale) + texScroll;
	
	//TWIST VERSION
	float twist = _twistStrength * intensity;
	float2 texUVs = ((polarCoords + distortion) * _texScale);
	texUVs.x += (texUVs.y * twist);
	texUVs += + texScroll;
	
	//NO TWIST UVS
	//float2 texUVs = ((polarCoords + distortion) * _texScale) + input.texScroll;
	
	float tex = _texture.Sample(_texture_SS, texUVs).r;
	tex = lerp(tex, 1 - tex, _invertTex);

	float baseNoise = saturate(pow(tex, inverseIntensity * inverseIntensity * 20));
	baseNoise = saturate(baseNoise * (2 - intensity));

	float3 baseNormal = colorToNormals(_normalsTarget.Sample(_normalsTarget_SS, input.screenUV).rgb);
	float3 normal = baseNormal;
	normal.z = _normalIntensity; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float edges = normal.z;

	float4 coldColor = float4(0.25, 0.4, 0.5, 1);
	float4 col = lerp(_coldColor, _hotColor, baseNoise);
	col += coldColor * mask * _coldColorAdd;
	baseNoise = pow(baseNoise, edges);
	baseNoise = baseNoise * mask;
	col.rgb = col.rgb * baseNoise;
	col.rgb *= length(baseNormal);

	return col;
}