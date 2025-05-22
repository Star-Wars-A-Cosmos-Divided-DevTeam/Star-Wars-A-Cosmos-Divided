#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_BEAM
{
	float4 location : SV_POSITION;
    float length : POSITION3;
    float intensity : COLOR1;
	float fadeAlpha : COLOR2;
	float2 uv : TEXCOORD0;
	float2 largeNoise1UVs : TEXCOORD2;
	float2 largeNoise2UVs : TEXCOORD3;
	float2 blendUVs : TEXCOORD4;
	float2 topUVs : TEXCOORD5;
	float2 bottomUVs : TEXCOORD6;
};

float _extraBeginLength;
float _extraEndLength;

VERT_OUTPUT_BEAM vert(in VERT_INPUT_BEAM input)
{
    input.intensity = clamp(pow(input.intensity, 0.75), 0, 100);
    input.vertexOffset.y *= input.intensity;
	VERT_OUTPUT_BEAM output;
    float4 vertexLoc = calculateWorldVertexLoc(input, _extraBeginLength, _extraEndLength);
	output.location = mul(vertexLoc, _transform);
    output.intensity = input.intensity;
	output.fadeAlpha = pow(input.fadeAlpha, 2);
	output.uv = input.uv;
	float2 scaledUVs = input.uv * float2(1/input.intensity, 1);
	float gameTime = input.beamTime;
	output.length = input.length;
	float scrollSpeed = -2 * input.beamTime;

	//Preparing scaled and scrolling UVs for texture sampling
	output.largeNoise1UVs = float2(((input.length * scaledUVs.x) + scrollSpeed) * 0.02, 0.3);
	output.largeNoise2UVs = float2(((scaledUVs.x * input.length * 0.5) - (20 * gameTime)) * 0.005, scaledUVs.y * 0.01);
	output.blendUVs = (scaledUVs * float2(input.length * 2 * 0.5, 4)) + float2(scrollSpeed * 10, 0);
	output.topUVs = float2((((scaledUVs.x * input.length * 0.5) + (-2 * gameTime)) * -0.2) + (gameTime * 2.22), (scaledUVs.y - (gameTime * 0.511 * 2)) * 0.426);
	output.bottomUVs = float2((((scaledUVs.x * input.length * 0.5) + (-2 * gameTime)) * 0.2) - (gameTime * 2.22), (scaledUVs.y + (gameTime * 0.511 * 2)) * 0.426);
	return output;
}

Texture2D _noiseTexture;
SamplerState _noiseTexture_SS;
float _endCapSize;

PIX_OUTPUT pix(in VERT_OUTPUT_BEAM input) : SV_TARGET
{
	float largeNoise1 = lerp(0.75, 1, _texture.Sample(_texture_SS, input.largeNoise1UVs).r);

	float baseGrad = abs((input.uv.y - 0.5) * 2);  //generating a vertical cylinder gradient
	float beamBase = pow(baseGrad, 4);
	beamBase = 1 - pow(beamBase, largeNoise1);  //largeNoise1 is used to subtly break up the cylinder gradient

	float2 innerUVs;
	if (input.uv.y >= 0.5)
	{
		innerUVs = input.topUVs; //scrolling up and forward
	}
	else
	{
		innerUVs = input.bottomUVs;  //scrolling down and forward
	}
	float largeNoise2 = _noiseTexture.Sample(_noiseTexture_SS, input.largeNoise2UVs).b;
	float2 uvDistortion = lerp(input.blendUVs, float2(largeNoise2, largeNoise2), 0.7);  //largeNoise2 is used to distort blendUVs
	float uvDistortion2 = _texture.Sample(_texture_SS, uvDistortion).r;  //first noise texture is sampled again with the distorted UVs
	innerUVs = lerp(innerUVs, float2(uvDistortion2, uvDistortion2), 0.05);  //scrolling top and bottom UVs are distorted by the results of the previous two samples
	float4 smallNoise1 = _noiseTexture.Sample(_noiseTexture_SS, innerUVs);

	float noiseBase = (smallNoise1.r + smallNoise1.b) * 0.8;

	float endT = clamp(min(input.uv.x, 1 - input.uv.x) * input.length / (_endCapSize * input.intensity), 0.001, input.fadeAlpha); //calculating pinched ends

	//processing the sampled noise and preparing a number of pieces to use in the color blending stage
	float innerBeam = pow(beamBase, 7.2);
	float innerBase = saturate(innerBeam + noiseBase);
	float innerSharp = pow(innerBase, 4.5);
	float innerGrad = pow(1 - baseGrad, 2.22);
	float innerCombined = (1 - innerGrad) * (pow(innerBase, 110) + innerGrad);
	innerCombined = (1 - innerCombined) + noiseBase + innerGrad;
	innerCombined = innerCombined * innerCombined;

	float4 colorA = float4(0.5, 0.219, 0.213, 1); //desired color * 0.5
	float4 red = float4(1, 0, 0, 1);
	float4 layer1 = colorA * innerCombined * innerSharp; //tinting the processed noise and masking it with innerSharp
	float4 col = lerp(red, layer1, innerGrad); //blending in red using a cylinder gradient
	col = lerp(red * noiseBase, col, innerBeam); //breaking up the outline
	float beamShape = pow(beamBase, 7.2/endT);  //creating the final mask including the pinched ends
	col = col * beamShape * input.fadeAlpha;  //combining in the final mask and fadeAlpha

	return col;
}