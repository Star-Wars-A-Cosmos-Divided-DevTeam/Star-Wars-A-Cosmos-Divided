#define ENABLE_TANGENT
#include "./Data/common_effects/particles/base_particle.shader"

struct VERT_OUTPUT2
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION0;
	float2 normalizedCenter : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float4 tangent : TEXCOORD1;
	float rotation : TEXCOORD2;
	float intensity : TEXCOORD3;
};

float _camRotation;
float4x4 _camRotMatrix;
float _percentScale;

VERT_OUTPUT2 vert(in VERT_INPUT_PARTICLE input)
{
	float4 loc;
	loc.xy = input.center + rotate(input.offset * _baseSize * input.scale, input.rotation);
	loc.z = 0;
	loc.w = 1;

	VERT_OUTPUT2 output;
	output.location = mul(loc, _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	float4 center = mul(float4(input.center, 0, 1), _transform);
	output.normalizedCenter.x = (center.x + 1) / 2;
	output.normalizedCenter.y = (-center.y + 1) / 2;
	output.color = input.color;
	output.intensity = input.color.r;
	output.uv = input.uv;

	output.rotation = input.rotation;
	
	return output;
}

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

Texture2D _rampTex;
SamplerState _rampTex_SS;

float _shockwaveStrength;

float4 _color1 = 255;
float4 _color2 = 255;

PIX_OUTPUT pix(in VERT_OUTPUT2 input) : SV_TARGET
{
	
	float4 src = _texture.Sample(_texture_SS, input.uv);
	if(src.a <= 0)
		discard;

	float3 normals = colorToNormals(src.rgb);
	normals.r = -normals.r;
	//normals.rg = rotateFlipNormals(normals.rg, input.tangent);
	normals.rg = rotate(normals.rg, input.rotation);
	normals.rg = rotate(normals.rg, -_camRotation);


	float2 screenDerivativesX = ddx(input.uv);
	float2 screenDerivativesY = ddy(input.uv);
	float screenSpaceScale = sqrt(dot(screenDerivativesX, screenDerivativesX) + dot(screenDerivativesY, screenDerivativesY));
	normals.g = normals.g * _viewportScale.x/_viewportScale.y;
	
	//float distortionIntensity = 0.000001; //previously 0.0000005
	//float distortionIntensity = 0.0000004 + (input.color.r * 0.0000002);
	float distortionIntensity = 0.0000008 - (input.color.r * 0.0000002);
	float2 distortionUVs = input.normalizedLocation + (normals.rg * src.a * distortionIntensity)/screenSpaceScale;
	
	float4 ret = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, distortionUVs);
	
	//RAMP TEX VERSION:
	
	//float localUVX = fmod(input.uv.x * 8, 1);
	//float colPow = pow(src.a, 4);
	//float2 rampUVs;
	//rampUVs.x = 1 - min(1.035 - pow(src.a, 1.5), 0.965);
	//rampUVs.y = 1 - min(saturate(localUVX * 1.1), 0.965);

	//swizzle I think?
	//float z = rampUVs.x;
	//rampUVs.x = rampUVs.y;
	//rampUVs.y = z;
	//float3 col = _rampTex.Sample(_rampTex_SS, rampUVs).rgb;
	//ret.rgb += col * pow(1 - localUVX, 2) * src.a * 0.5;
	
	//END RAMP TEX VERSION
	
	
	//ret.rgb += src.a * (1 - src.z) * input.color.rgb * baseColor.rgb;
	
	//float3 color1 = float3(0.25, 1, 1.5);

	//float3 color2 = float3(input.color.r, 0.3 + (input.color.r * 0.7), 0.7);
	float3 color2A = float3(0.1, 0.25, 0.2);
	float3 color2B = float3(0.7, 0.8, 0.7);
	float3 color2 = lerp(color2A, color2B, input.color.r * src.a);
	
	ret.rgb += _color1.rgb * src.a * (0.1 + (0.2 * input.color.r)); //base color add
	//ret.rgb += lerp(_color1.rgb, color2, 1 - pow(src.a, 8)) * 0.2; //detail color add
	ret.rgb += color2.rgb * pow(src.a, 8 + (input.color.r * 8)) * (0.2 + (0.6 * input.color.r));
	
	//float3 color1 = float3(1.5, 1, 0.25);
	//ret.rgb += color1 * src.a * 0.2; //base color add
	//ret.rgb += lerp(color1, input.color.rgb, 1 - pow(src.a, 8)) * 0.2; //detail color add
	
	//float alphaColorStrength = 0.75;
	//float3 color2 = float3(0.25, 0.1, 0.1);
	//ret.rgb = lerp(ret.rgb, color2, alphaColorStrength * 1 - pow(src.a, 8));
	//ret.rgb += src.a * input.color.rgb * baseColor.rgb * input.color.a;
	//ret.a = src.a * input.color.a * 0.5;
	ret.a = src.a * input.color.a * (0.2 + (input.color.r * 0.3));
	return ret;
}
