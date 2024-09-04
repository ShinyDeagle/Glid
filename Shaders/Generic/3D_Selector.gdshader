shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float border_size : hint_range(0.0, .5, 0.01) = 0.25;

void fragment() {
	vec2 uv = UV;
	ALBEDO = color.rgb;
	
	ALPHA = alpha;
	if (uv.x > border_size && uv.x < 1.0 - border_size) {
		if (uv.y > border_size && uv.y < 1.0 - border_size) {
			ALPHA = 0.0;
		}
	}
}
