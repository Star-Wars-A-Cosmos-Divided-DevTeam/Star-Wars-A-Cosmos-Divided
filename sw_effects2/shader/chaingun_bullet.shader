#include "./Data/common_effects/base_beam.shader"

struct VERT_OUTPUT_CHAINGUN
{
	float4 location : SV_POSITION;
	float4 color : COLOR0;
	float2 uv : TEXCOORD0;
	float beamTime : TEXCOORD1;
	float progress : TEXCOORD2;
	float invProgress : TEXCOORD3;
	float horizontalWipe : TEXCOORD4;
	float horizontalWipe2 : TEXCOORD5;
	float bulletGradient : TEXCOORD6;
	float length : POSITION1;
	float bulletProgress : TEXCOORD7;
	float2 trailUVs : TEXCOORD8;
	float2 noiseUVs : TEXCOORD9;
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
	output.trailUVs = float2(input.uv.x * 8 + input.beamTime * -10, input.uv.y);
	output.noiseUVs = float2(input.uv.x * 12 + input.beamTime * -6, input.uv.y * 2);
	return output;
}

float4 _color1 = 255;
float4 _color2 = 255;

Texture2D _noiseTex;
SamplerState _noiseTex_SS;


PIX_OUTPUT pix(in VERT_OUTPUT_CHAINGUN input) : SV_TARGET
{

	float4 trail = _texture.Sample(_texture_SS, input.trailUVs);
	if (trail.a <= 0)
		discard;

	float noise = _noiseTex.Sample(_noiseTex_SS, input.noiseUVs).r;

	noise = noise * 0.3 + 0.7;

	float horizontalWipe2 = saturate(1 - abs((input.uv.x * 2) - ((input.bulletProgress * 4) - 1))); // cylinder gradient wiped across at bullet speed
	float verticalGradientBase = 1 - abs((input.uv.y * 2) - 1);
	float verticalGradient = smoothstep(0, 1, saturate(pow(verticalGradientBase, 10 * input.invProgress * input.invProgress)));
	float verticalGradient4 = smoothstep(0, 1, saturate(pow(verticalGradientBase, 5 * input.invProgress)));
	
	float mask = saturate(input.horizontalWipe * verticalGradient * verticalGradientBase * trail.r * 0.5); //was * 0.5
	float mask2 = saturate(input.horizontalWipe * verticalGradient4 * verticalGradientBase * verticalGradientBase * noise * 0.5); //was * 0.5
	float endMask = min(input.uv.x * input.length, min((1 - input.uv.x) * input.length / _endFadeLength, 1));
	mask = (mask + mask2) * endMask;

#ifdef GTE_PS_4_0_level_9_3
	
	float verticalGradient2 = smoothstep(input.bulletGradient * 0.5 + 0.5, 1, saturate(pow(verticalGradientBase, 30))); //pillow shaped
	float verticalGradient3 = smoothstep(1 - (horizontalWipe2 * 0.3 + 0.7), 1, saturate(pow(verticalGradientBase, 8)));
	float zoomBullet = pow(horizontalWipe2, 6) * verticalGradient2;
	float zoomBulletYellow = pow(horizontalWipe2, 8) * verticalGradient3 * endMask;
	float zoomBulletRed = pow(horizontalWipe2, 4) * verticalGradient2 * trail.r;

	float3 yellow = float3(1, 0.27, 0);

	float3 col = _color2.rgb * zoomBullet + float3(_color2.r * zoomBulletRed, 0.67 * zoomBulletRed, 0) + _color1.rgb * mask + yellow * zoomBulletYellow;
	return float4(col, 1);

#else
	
	float verticalGradient2 = smoothstep(input.bulletGradient * 0.5 + 0.5, 1, saturate(pow(verticalGradientBase, 10))); //pillow shaped
	float zoomBulletRed = horizontalWipe2 * horizontalWipe2 * verticalGradient2;
	float zoomBullet = zoomBulletRed * zoomBulletRed;
	
	float3 col = _color2.rgb * zoomBullet + _color1.rgb * mask + float3(zoomBulletRed, 0, 0);
	return float4(col, 1);

#endif
}