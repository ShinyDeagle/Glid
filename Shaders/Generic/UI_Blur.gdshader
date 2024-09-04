shader_type canvas_item;

uniform float lod : hint_range(0.0, 5) = 0.0;
uniform bool mix_lod = false;
uniform bool mix_dark = false;
uniform vec4 darkener : source_color = vec4(0.0);
uniform float darkener_skew : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float y_threshold : hint_range(0.0, 1.0, 0.1) = 0.8;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec4 color;
	float dist = distance(UV.y, y_threshold);
	if (mix_lod) {
		if (UV.y >= y_threshold) {
			color = texture(SCREEN_TEXTURE, SCREEN_UV, mix(0.0, lod, dist));
		} else {
			color.a = 0.0;
		}
	} else {
		color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	}
	if (mix_dark && UV.y >= y_threshold) {
		color = mix(color, darkener, pow(dist, darkener_skew));
	}
	COLOR = color;
}