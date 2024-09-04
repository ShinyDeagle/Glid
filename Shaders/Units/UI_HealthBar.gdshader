shader_type canvas_item;
render_mode unshaded;

//uniform vec4 inner_gradient_start : source_color = vec4(0, 0.702, 1, 1);
//uniform vec4 inner_gradient_mid : source_color =  vec4(1, 0.5, 0, 1);
///uniform vec4 inner_gradient_end : source_color = vec4(1, 0.5, 0, 1);
//uniform float gradient_multiplier = 1.25;
//uniform float progress_offset = -1;
uniform vec4 base_color : source_color = vec4(0, 0.702, 1, 1);
uniform vec4 base_color_lower : source_color = vec4(0, 0.702, 1, 1);
uniform vec4 inner_color : source_color = vec4(1, 0.5, 0, 1);
uniform vec4 inner_color_lower : source_color = vec4(1, 0.5, 0, 1);
uniform vec4 shield_color : source_color = vec4(0.1804, 0.9059, 0.651, 1);
uniform vec4 shield_color_lower : source_color = vec4(0.1804, 0.9059, 0.651, 1);
uniform vec4 back_color : source_color = vec4(0.5);
uniform vec4 back_color_lower : source_color = vec4(0.5);

uniform float fill = 0.5;
uniform float inner_fill = 0.9;
uniform float shield_fill = 0.2;
uniform float to_divide = 12.0;
uniform float divisions = 5.0;
uniform float split_size = 0.01;
uniform float split_height = 0.35;
uniform float split_step = 1.0;

const vec4 BLACK = vec4(0, 0, 0, 1);
const vec4 GREY = vec4(.5, .5, .5, 1);
uniform vec4 outline_color : source_color = vec4(0, 0, 0, 1);
uniform bool two_tone = false;
uniform float lower_tone_threshold = 0.5;

void fragment() {
	COLOR = texture(TEXTURE, UV); //read from texture
	
	vec2 uv = UV;
	float x = uv.x;
	float y = uv.y;
	
	if (COLOR == BLACK || COLOR == GREY) {
		COLOR = outline_color;
	} else if (COLOR.a == 0.0) {
		discard;
	} else {
	  	COLOR.rgb = base_color.rgb;
		if (two_tone && y >= lower_tone_threshold) {
			COLOR = base_color_lower;
		}
		
		if (UV.x > fill && UV.x <= inner_fill) {
			COLOR.rgb = inner_color.rgb;
			if (two_tone && y >= lower_tone_threshold) {
				COLOR = inner_color_lower;
			}
		}
		
		if (shield_fill > 0.0 && UV.x > fill && UV.x <= fill + shield_fill) {
			COLOR.rgb = shield_color.rgb;
			if (two_tone && y >= lower_tone_threshold) {
				COLOR = shield_color_lower;
			}
		}
		
		if (UV.x > inner_fill) {
			COLOR = back_color;
			if (two_tone && y >= lower_tone_threshold) {
				COLOR = back_color_lower;
			}
		}
		
		if (divisions <= 0.0 || to_divide <= 0.0) {
			discard;
		}
		
		float segments = ceil(to_divide / divisions);
		
		for (float i = 0.0; i < segments - 1.0; i++) {
			float segment_progress = (i + 1.0) * divisions / to_divide;
			if (segment_progress > 1.0) {
				break;
			}
			
			if (UV.x > segment_progress - split_size 
				&& UV.x < segment_progress + split_size) {
				COLOR = outline_color;
				//COLOR.r = COLOR.g = COLOR.b = 0.0;
			}
		}
		
		for (float j = 0.0; j < to_divide; j += split_step) {
			if (j == 0.0) continue;
			
			if (UV.x > (j / to_divide) - split_size 
				&& UV.x < (j / to_divide) + split_size
				&& UV.y < split_height) {
					COLOR = outline_color;
					//COLOR.r = COLOR.g = COLOR.b = 0.0;
				}
		}
	}
}
