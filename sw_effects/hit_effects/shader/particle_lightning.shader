#define USE_DEFAULT_VERT_PARTICLE
#include "./Data/common_effects/particles/base_particle.shader"

float4 _centerColor = 255;
float4 _outerColor = 255;
float4 _bloomColor = 255;

/*
Particle vertex color channels are used to control/animate the lightning.
Red is the dominant control and it animates the arcing of the lightning.
At low R values only the start of the lightning is visible, at 50% the entire arc is visible, and at high values only the ends of the arc is visible.
Green controls the brightness in the center of the lightning.
Blue controls "bloom"/outer glow.
Alpha is used as a global brightness control.
*/

PIX_OUTPUT pix(in VERT_OUTPUT_PARTICLE input) : SV_TARGET
{
	float4 tex = _texture.Sample(_texture_SS, input.uv);
	tex = pow(tex, float4(0.45, 0.45, 0.45, 0.45));
	float baseMask = saturate(tex.a * 6);

	float arc;
	float forwards = saturate(tex.r - saturate(1 - (input.color.r * 2)));
	float backwards = saturate((1 - tex.r) - saturate((input.color.r - 0.5) * 2));

	arc = min(forwards, backwards);
	float4 baseColor = lerp(_centerColor, _outerColor, arc);
	
	float baseShape = (tex.b + tex.g) * tex.a;
	float saw = abs((input.color.r * 2) - 1);
	float arcMask = pow(tex.b, (saw * 6) + 1);
	arcMask = saturate(arcMask * arc * 2);
	float innerShape = lerp(baseShape, arcMask, saturate(saw * 6)) * baseMask;

	float highlightSaw = saturate(saw * 2);
	float highlight = pow(tex.g, (highlightSaw * 5) + 1);
	highlight = (1 - highlightSaw) * highlight * input.color.g * baseMask;

	float bloomSaw = saturate(saw * 5) + 1;
	float bloom = pow(tex.a, bloomSaw) * input.color.b * (1 - saw);
	float4 bloomAdd = lerp(_centerColor, _bloomColor, tex.a) * float4(bloom, bloom, bloom, 1);
	float4 ret = (innerShape * baseColor) + float4(highlight, highlight, highlight, 1) + bloomAdd;
	
	return ret * input.color.a;
}