shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

float rand(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 uv = SCREEN_UV;

	if (intensity < 0.01) {
		COLOR = texture(SCREEN_TEXTURE, uv);
	} else {
		// Chromatic aberration (RGB split)
		float aberr = intensity * 0.007;
		float r = texture(SCREEN_TEXTURE, uv + vec2(aberr, 0.0)).r;
		float g = texture(SCREEN_TEXTURE, uv).g;
		float b = texture(SCREEN_TEXTURE, uv - vec2(aberr, 0.0)).b;

		// Horizontal glitch bands com tempo discreto (estilo retro)
		float time_step = floor(TIME * 8.0);
		float row_noise = rand(floor(uv.y * 80.0) + time_step);
		float band_threshold = 1.0 - intensity * 0.5;

		if (row_noise > band_threshold) {
			float shift = (row_noise - band_threshold) * intensity * 0.06;
			r = texture(SCREEN_TEXTURE, uv + vec2(shift + aberr, 0.0)).r;
			g = texture(SCREEN_TEXTURE, uv + vec2(shift, 0.0)).g;
			b = texture(SCREEN_TEXTURE, uv + vec2(shift - aberr, 0.0)).b;
		}

		// Scanlines
		float scanline = sin(uv.y * 400.0) * 0.5 + 0.5;
		float scan_strength = intensity * 0.10;

		// Vignette (bordas escurecem com dano)
		float vignette = length(uv - 0.5) * 1.8;
		float vig_strength = intensity * 0.6;

		vec3 col = vec3(r, g, b);
		col *= 1.0 - scan_strength + scanline * scan_strength;
		col *= 1.0 - vignette * vignette * vig_strength;

		// Tint vermelho em HP crítico
		col.r = mix(col.r, col.r * 1.2, intensity * 0.3);
		col.gb = mix(col.gb, col.gb * 0.85, intensity * 0.3);

		COLOR = vec4(col, 1.0);
	}
}
