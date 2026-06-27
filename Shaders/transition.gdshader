/*
shader_type canvas_item;

uniform float progress : hint_range(0, 1);

uniform float diamondPixelSize = 10.0;

float when_lt(float x, float y) {
	return max(sign(y - x), 0.0);
}

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	COLOR.a = when_lt(xDistance + yDistance + UV.x + UV.y, progress * 4.0);
}
*/

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

uniform float shake_power = 0.03;
uniform float shake_block_size = 30.5;

uniform vec2 direction_r = vec2(1.0, 0.0);
uniform vec2 direction_g = vec2(0.4, 1.0);
uniform vec2 direction_b = vec2(-0.7, -0.3);

float random(float seed)
{
	return fract(543.2543 * sin(dot(vec2(seed), vec2(3525.46, -54.3415))));
}

void fragment()
{
	vec2 uv = SCREEN_UV;

	uv.x += (
		random(
			trunc(SCREEN_UV.y * shake_block_size) / shake_block_size + TIME
		) - 0.5
	) * shake_power * (progress * 12.0);

	vec3 color;

	color.r = textureLod(screen_texture,
		uv + normalize(direction_r) * progress, 0.0).r;

	color.g = textureLod(screen_texture,
		uv + normalize(direction_g) * progress, 0.0).g;

	color.b = textureLod(screen_texture,
		uv + normalize(direction_b) * progress, 0.0).b;

	COLOR = vec4(color * (1.0 - progress), 1.0);
}