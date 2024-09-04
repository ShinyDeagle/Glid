shader_type canvas_item;

group_uniforms Waves;
uniform vec4 main : source_color = vec4(1, 0.9843, 0.7059, 1);
uniform float size : hint_range(0.0, 1.2, 0.01) = 0.8;
uniform float deviation_percentage : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float time_scale = 1.0;
uniform float x_scale = 1.0;
uniform bool invert = false;
uniform bool cull_top = false;
uniform bool cull_bot = false;
uniform bool fill_top = false;
uniform bool fill_bot = false;

group_uniforms Texture;
uniform vec2 scroll_speed = vec2(1.0, 1.0);
uniform vec2 texture_sizer = vec2(1.0, 1.0);
uniform float uv_scale : hint_range(0.0, 10, 0.1) = 1.0;
uniform vec4 texture_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : hint_default_white, repeat_enable;
uniform float texture_rotation : hint_range(-360.0, 360.0, 1.0) = 0.0;
uniform bool mix_color = false;
uniform float mix_color_strength : hint_range(0.0, 1.0, 0.01) = 0.0;

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

vec2 rotateUV_midpoint(vec2 uv, float rotation, vec2 mid)
{
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid.x) + sinAngle * (uv.y - mid.y) + mid.x,
        cosAngle * (uv.y - mid.y) - sinAngle * (uv.x - mid.x) + mid.y
    );
}

vec2 rotateUV_midpoint_number(vec2 uv, float rotation, float mid)
{
    float cosAngle = cos(rotation);
    float sinAngle = sin(rotation);
    return vec2(
        cosAngle * (uv.x - mid) + sinAngle * (uv.y - mid) + mid,
        cosAngle * (uv.y - mid) - sinAngle * (uv.x - mid) + mid
    );
}

void fragment() {
	COLOR.rgb = main.rgb;
	
	vec2 texture_uv = UV;
	float x = UV.x;
	float y = UV.y;
	
	x *= x_scale;
	
	float time = TIME;
	float offset = sin((TIME + x) * time_scale) * size / 16.0;
	offset *= deviation_percentage; 
	bool inside = 1.0 - y > size + offset || y > size - offset;
	
	if (invert) {
		inside = !inside;
	}
	
	if (cull_top && !inside && y < 0.5) {
		COLOR.a = 0.0;
	}
	
	if (cull_bot && !inside && y > 0.5) {
		COLOR.a = 0.0;
	}
	
	if (inside) {
		COLOR.a = 0.0;
	} else if (COLOR.a > 0.0) {
		texture_uv.x *= texture_sizer.x;
		texture_uv.y *= texture_sizer.y;
		
		texture_uv.x *= uv_scale;
		texture_uv.y *= uv_scale;
		
		texture_uv = rotateUV(texture_uv, radians(texture_rotation));
		
		float x_time = time * scroll_speed.x;
		float y_time = time * scroll_speed.y;
		texture_uv.x += x_time;
		texture_uv.y += y_time;
		
		vec4 color = texture(texture_albedo, texture_uv);
		if (!mix_color && color.a > 0.0) {
			COLOR = texture_color;
		} else if (color.a > 0.0) {
			COLOR = texture_color * color;
		}
	}
	
	vec4 t_color = texture(TEXTURE, UV);
	if (t_color.a > 0.0) {
		if (fill_top && inside && y < 0.5) {
			COLOR.a = 1.0;
		}
	
		if (fill_bot && inside && y > 0.5) {
			COLOR.a = 1.0;
		}
	}
}