shader_type canvas_item;

uniform float uv_left_shave : hint_range(0.0, 1.0, 0.001) = 0.25;
uniform float uv_right_shave : hint_range(0.0, 1.0, 0.001) = 0.25;
uniform float uv_up_shave : hint_range(0.0, 1.0, 0.001) = 0.25;
uniform float uv_down_shave : hint_range(0.0, 1.0, 0.001) = 0.25;
uniform bool reverse = false;
uniform bool on = true;
uniform vec4 color_add : source_color;
uniform float color_mult : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float color_darkerner : hint_range(0.0, 1.0, 0.01) = 0.0;
void fragment() {
	vec2 uv = UV;
	if (on) {
		if (reverse) {
			COLOR.a = 0.0;
			if (uv.x < uv_left_shave) {
				COLOR.a = 1.0;
			} else if (uv.x > 1.0 - uv_right_shave) {
				COLOR.a = 1.0;
			} else if (uv.y < uv_up_shave) {
				COLOR.a = 1.0;
			} else if (uv.y > 1.0 - uv_down_shave) {
				COLOR.a = 1.0;
			}
		} else {
			if (uv.x < uv_left_shave) {
				COLOR.a = 0.0;
			} else if (uv.x > 1.0 - uv_right_shave) {
				COLOR.a = 0.0;
			} else if (uv.y < uv_up_shave) {
				COLOR.a = 0.0;
			} else if (uv.y > 1.0 - uv_down_shave) {
				COLOR.a = 0.0;
			}
		}
		if (color_mult > 0.0) {
			COLOR.rgb = vec3(vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0);
			COLOR.rgb *= color_add.rgb;
			//COLOR.rgb = mix(COLOR.rgb, color_add.rgb, color_mult);
			COLOR.rgb /= color_darkerner;
		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
