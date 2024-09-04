shader_type canvas_item;

group_uniforms Drawing;
uniform vec4 tone_primary : source_color = vec4(0.9843, 0.4902, 0.2039, 1);
uniform vec4 tone_secondary : source_color = vec4(0.0235, 0.0314, 0.3373, 1);
uniform bool draw_right = false;
uniform bool draw_center = false;
uniform bool draw_up_down = false;
uniform bool invert = false;
uniform int rows = 30;
uniform int columns = 30;
uniform float min_center_distance : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float uv_scaler : hint_range(0.0, 100, 0.05) = 2.0;
group_uniforms Visual;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 scroll_speed = vec2(-0.025, 0.0);
uniform sampler2D texture_albedo : hint_default_transparent;
uniform float rotation_angle : hint_range(-180.0, 180.0, 0.1) = 0.0;
uniform vec2 uv_shift = vec2(0.0, 0.0);

bool in_circle(in vec2 uv, in vec2 pos, in float size) {
    return distance(uv, pos) <= size;
}

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

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	
    vec2 uv = UV;
	uv += uv_shift;
	uv = rotateUV(uv, radians(rotation_angle));
    uv.x *= uv_scale.x;
    uv.y *= uv_scale.y;
	
    
    float time = TIME;
    float x_time = time * scroll_speed.x;
    float y_time = time * scroll_speed.y;
    uv.x += x_time;
    uv.y += y_time;
    
    if (uv.x > 0.5) {
        COLOR = tone_primary;
    } else {
        COLOR = tone_secondary;
    }
    
    float row_step = 1.0 / float(rows);
    float column_step = 1.0 / float(columns);
    float max_circle_size = min(column_step, row_step);
    
    float nearest_row = mod(uv.x, row_step);
    float nearest_column = mod(uv.y, column_step);
    vec2 nearest_pos = vec2(nearest_row, nearest_column);
    
    float circle_size = 0.0;
    if (draw_center) {
        circle_size = mix(max_circle_size * 1.5, 0.0, distance(vec2(0.5), UV) * uv_scaler);
	} else if (draw_up_down) {
		circle_size = mix(max_circle_size * 1.5, 0.0, distance(0.5, UV.y) * uv_scaler);
    } else {
        circle_size = mix(max_circle_size * 1.5, 0.0, distance(0.5, UV.x) * uv_scaler);
    }
    bool in_circle = in_circle(vec2(row_step, column_step), nearest_pos * 2.0, circle_size);
    
    if (!draw_center) {
        COLOR = !invert ? tone_secondary : tone_primary;
        if (in_circle) {
            COLOR = !invert ? tone_primary : tone_secondary;
        }
    }
    if (draw_center) {
        COLOR = !invert ? tone_secondary : tone_primary;
        if (in_circle) {
            COLOR = !invert ? tone_primary : tone_secondary;
        }
    }
    
    if (draw_up_down && UV.y <= 0.5 + uv_shift.y && !draw_right && !draw_center) {
        COLOR = vec4(0.0);
    } else if (UV.x >= 0.5 + uv_shift.x && !draw_right && !draw_center) {
        COLOR = vec4(0.0);
    }
    
    if (uv_scaler >= 100.0) {
        COLOR.a = 0.0;
    }
    
    if (COLOR.a == 0.0) {
        COLOR = texture(texture_albedo, UV);
    }
	
	if (texture_color.a <= .3) {
		COLOR.a = 0.0;
	}
}