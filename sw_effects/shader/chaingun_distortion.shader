#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_CHAINGUN
{
	float4 location : SV_POSITION;
	float2 normalizedLocation : POSITION1;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float beamTime : TEXCOORD1;
	float progress : TEXCOORD2;
	float invProgress : TEXCOORD3;
	float horizontalWipe : TEXCOORD4;
	float horizontalWipe2 : TEXCOORD5;
	float bulletGradient : TEXCOORD6;
	float length : POSITION2;
	float2 screenDirection : POSITION3;
	float bulletProgress : TEXCOORD7;
};

float _extraBeginLength;
float _extraEndLength;

float _endFadeLength;

VERT_OUTPUT_CHAINGUN vert(in VERT_INPUT_BEAM input)
{
	VERT_OUTPUT_CHAINGUN output;
	float bulletSpeed = 2;
	input.vertexOffset.y *= input.intensity;
	float4 vertexLoc = calculateWorldVertexLoc(input, _extraBeginLength, _extraEndLength);
	output.location = mul(vertexLoc, _transform);
	output.normalizedLocation.x = (output.location.x + 1) / 2;
	output.normalizedLocation.y = (-output.location.y + 1) / 2;
	output.color = input.color;
	output.color.a *= input.fadeAlpha;
	output.progress = 1 - input.fadeAlpha;
	output.invProgress = input.fadeAlpha;
	output.beamTime = input.beamTime;
	output.uv = input.uv;
	output.length = input.length;
	output.bulletProgress = saturate(output.progress * bulletSpeed);
	output.horizontalWipe = saturate((1 + input.uv.x) - (output.progress * 2)); //full 1 to gradient 1 -> 0 to full 0 at total progress speed
	output.bulletGradient = 1 - smoothstep(0, 1, abs(input.uv.x - output.bulletProgress)); //gradient 0 -> 1 to 1 -> 0 at bullet speed
	float2 direction = float2(1, 0);
	output.screenDirection = rotate(direction, input.direction);
	return output;
}

float4 _color1 = 255;
float4 _color2 = 255;

Texture2D _noiseTex;
SamplerState _noiseTex_SS;

Texture2D _capturedBackBuffer;
SamplerState _capturedBackBuffer_SS;

PIX_OUTPUT pix(in VERT_OUTPUT_CHAINGUN input) : SV_TARGET
{
#ifdef GTE_PS_4_0_level_9_3

	float2 trailUVs = float2(input.uv.x * input.length * 0.1 + input.beamTime * -3, input.uv.y);
	float4 trail = _texture.Sample(_texture_SS, trailUVs);
	if (trail.a <= 0)
		discard;

	float2 noiseUVs = float2(input.uv.x * input.length * 0.05 + input.beamTime * -8, input.uv.y * input.invProgress * input.invProgress);
	float noise = _noiseTex.Sample(_noiseTex_SS, noiseUVs).r;

	float horizontalWipe2 = saturate(1 - abs((input.uv.x * 2) - ((input.bulletProgress * 4) - 1))); // cylinder gradient wiped across at bullet speed
	float verticalGradientBase = 1 - abs((input.uv.y * 2) - 1);
	float invBulletProgress = 1 - input.bulletProgress;
	float verticalGradient = smoothstep(0, 1, saturate(pow(verticalGradientBase, 10 * invBulletProgress * invBulletProgress)));

	float afterBullet = saturate((input.progress - 0.5) * 2);
	float verticalGradient4 = saturate(lerp(verticalGradient, (1 - smoothstep(0, 1, saturate(pow(verticalGradientBase, 8 * input.progress * input.bulletProgress))) * 2) * verticalGradientBase, afterBullet));

	float2 dd = float2(ddx(input.uv.x), ddy(input.uv.x));
	dd = normalize(dd) / length(dd) * float2(ddx(input.normalizedLocation.x), ddy(input.normalizedLocation.y));

	float verticalGradient5 = saturate(smoothstep(0, 1, verticalGradientBase) * verticalGradient * 4);

	float endMask = min(input.uv.x * input.length, min((1 - input.uv.x) * input.length / _endFadeLength, 1));
	float distortionFactor = lerp(5, noise * 2 * input.invProgress, input.bulletProgress) * verticalGradient4 * input.bulletGradient * input.uv.x;

	float2 captureUV = input.normalizedLocation - dd * input.screenDirection * distortionFactor / input.length; //(was verticalGradient)
	float4 capturedColor = _capturedBackBuffer.Sample(_capturedBackBuffer_SS, captureUV);

	return float4(capturedColor.rgb, endMask * verticalGradientBase * input.bulletGradient);

#else
	
	discard;
	return float4(1,1,1,1);

#endif
}