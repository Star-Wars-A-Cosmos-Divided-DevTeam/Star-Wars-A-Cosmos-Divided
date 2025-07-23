#define ENABLE_SHIP_COORDS
#define ENABLE_SCREEN_UV
#define USE_DEFAULT_VERT
#include "./Data/base_shipquad.shader"

Texture2D _maskTexture;
SamplerState _maskTexture_SS;

Texture2D _noiseTexture2;
SamplerState _noiseTexture2_SS;

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

float4 _hotColor = 255;
float4 _coldColor = 255;
float _normalIntensity;

float _camScale;

PIX_OUTPUT pix(in GEOM_OUTPUT input) : SV_TARGET
{
	float intensity = input.color.a;
	float clampedDoubleIntensity = saturate(intensity * 2);
	float mask = _maskTexture.Sample(_maskTexture_SS, input.uv).r * clampedDoubleIntensity;
	if (mask <= 0)
		discard;

	float TEX_SCALE1 = 0.3;
	float TEX_SCALE2 = 0.4;
	float scrollMul = 0.2;
	float2 noise1UVs = float2(input.shipLocation.x * TEX_SCALE1, (input.shipLocation.y * TEX_SCALE1) + (scrollMul * _gameTime));
	

	float noiseTex = 1 - _texture.Sample(_texture_SS, noise1UVs).r;
	float distortionStrength = 0.3;
	float2 noise2UVs = float2(input.shipLocation.x * TEX_SCALE2, (input.shipLocation.y * TEX_SCALE2) - (scrollMul * _gameTime) + (noiseTex * distortionStrength));
	float noiseTex2 = 1 - _noiseTexture2.Sample(_noiseTexture2_SS, noise2UVs).r;
	//float baseNoise = saturate(pow(noiseTex, (1 - intensity) * (1 - intensity) * 20));
	//baseNoise = saturate(baseNoise * (2 - intensity));
	
	float baseNoise = noiseTex * noiseTex2;
	
	//baseNoise = saturate(pow(baseNoise, (1 - intensity) * (1 - intensity) * 20));
	//baseNoise = saturate(baseNoise * (2 - intensity));

	float screenDistortionStrength = ((2 * noiseTex2) - 1) * 0.002 * clampedDoubleIntensity;
	
	float2 distortionUVs = float2(input.screenUV.x, input.screenUV.y + screenDistortionStrength);
	float4 rawNormals = _normalsTarget.Sample(_normalsTarget_SS, distortionUVs);
	float3 baseNormal = colorToNormals(rawNormals.rgb);
	float3 normal = baseNormal;
	normal.z = baseNoise * 0.2; //0.02 for ships, 0.2 for asteroids
	normal = normalize(normal);
	float edges = saturate(dot(normal, float3(0, 0, 1)));

	float3 backBuffer = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, distortionUVs).rgb;

	//baseNoise = pow(baseNoise, edges);

	float squareIntensity = saturate(intensity * intensity);
	//float baseColor = ((1 - edges) * doubleIntensity) + saturate(baseNoise * intensity * intensity) * 0.75;
	
	float4 col = lerp(_coldColor, _hotColor, baseNoise * (1 - edges) * squareIntensity);
	//baseNoise = pow(baseNoise, edges);
	//baseNoise = lerp(0, baseNoise, mask);
	
	//float4 col = (_coldColor * squareIntensity) + (_hotColor * (1 - edges) * doubleIntensity);
	
	col *= 1 - edges;

	col.rgb = col.rgb * mask;
	//col.r = saturate(col.r + (mask * 0.25));
	//col.rgb *= length(baseNormal);
	float3 addColor = float3(lerp(_coldColor.rgb, _hotColor.rgb, squareIntensity * baseNoise * mask) * 0.9 * intensity * rawNormals.a);
	float a = (mask * 0.7) + (mask * baseNoise * 0.5);

	return float4(backBuffer.rgb + col.rgb + addColor, a);
}