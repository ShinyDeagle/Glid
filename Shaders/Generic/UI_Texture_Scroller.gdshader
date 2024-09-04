shader_type canvas_item;

group_uniforms Texture;
uniform bool use_texture = false;
uniform vec2 scroll_speed = vec2(1.0, 1.0);
uniform vec2 texture_sizer = vec2(1.0, 1.0);
uniform float uv_scale : hint_range(0.0, 300, 0.1) = 1.0;
uniform vec4 texture_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : hint_default_white, filter_linear, repeat_enable;
uniform float texture_rotation : hint_range(-360.0, 360.0, 1.0) = 0.0;
uniform bool force_color = false;
uniform bool texture_fade = false;
uniform float fader_end : hint_range(-1.0, 1.0, 0.05) = 0.0;
group_uniforms Shift;
uniform bool shift = false;
uniform float y_shift : hint_range(0.0, 1.0, 0.1) = 0.0;

vec2 rotateUV(vec2 uv, float rotation)
{
    float mid = 0.5;
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid) + sinAngle * (uv.y - mid) + mid,
        cosAngle * (uv.y - mid) - sinAngle * (uv.x - mid) + mid
    );
}

group_uniforms Result;
uniform vec4 main : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool force_bg_color = false;
uniform vec4 bg_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv.x *= uv_scale;
	uv.y *= uv_scale;
	
	vec2 texture_uv = UV;
	
	float time = TIME;
	float x_time = time * scroll_speed.x;
	float y_time = time * scroll_speed.y;
	uv.x += x_time;
	uv.y += y_time;
	
	vec4 color = texture(TEXTURE, uv);
	if (force_color) {
		COLOR = main;
	}
	if (use_texture) {
		texture_uv.x *= texture_sizer.x;
		texture_uv.y *= texture_sizer.y;
		
		texture_uv.x *= uv_scale;
		texture_uv.y *= uv_scale;
		
		if (shift) {
			float column_width = 1.0 / uv_scale;
			float check = 2.0;
			bool shift_column = mod(texture_uv.x, check) < 1.0;
			if (shift_column) {
				texture_uv.y += y_shift;
			}
		}
		
		texture_uv = rotateUV(texture_uv, radians(texture_rotation));
		
		float x_time = time * scroll_speed.x;
		float y_time = time * scroll_speed.y;
		texture_uv.x += x_time;
		texture_uv.y += y_time;
		
		vec4 t_color = texture(texture_albedo, texture_uv);
		if (t_color.a > 0.0) {
			vec4 final_color = texture_color;
			if (texture_fade && COLOR.a > 0.0) {
				final_color = mix(final_color, 
					COLOR, 
					clamp(texture_uv.y / uv_scale / texture_sizer.y + fader_end, 0.0, 1.0));
			}
			COLOR = final_color;
		} else if (t_color.a < 0.01 && force_bg_color) {
			COLOR = bg_color;
		}
	} else {
		COLOR = color;
		if (COLOR.a > 0.0) {
			COLOR = main;
		}
	}
}