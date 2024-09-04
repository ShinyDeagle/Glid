shader_type canvas_item;
render_mode unshaded;

uniform vec4 health_color_main : source_color = vec4(1);
uniform vec4 health_color_main_lower : source_color = vec4(1);
uniform vec4 health_color_fill : source_color = vec4(1);
uniform vec4 health_color_fill_lower : source_color = vec4(1);
uniform vec4 health_color_back : source_color = vec4(1);

uniform float percent = 0.5;
uniform float fill = 0;
uniform bool reverse = true;
uniform bool two_tone = false;
uniform float lower_tone_threshold = 0.5;

void fragment() {
	float x = reverse ? 1.0 - UV.x : UV.x;
	float y = UV.y;

	COLOR = health_color_back;

	if (x < fill) {
		COLOR = health_color_fill;
		if (two_tone && y >= lower_tone_threshold) {
			COLOR = health_color_fill_lower;
		}
	}

	if (x < percent) {
		COLOR = health_color_main;
		if (two_tone && y >= lower_tone_threshold) {
			COLOR = health_color_main_lower;
		}
	}

}
