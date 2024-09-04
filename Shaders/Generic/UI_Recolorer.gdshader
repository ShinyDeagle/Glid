shader_type canvas_item;

group_uniforms Color;
uniform bool recolor = true;
uniform vec4 color : source_color  = vec4(1);

uniform bool grayifier = false;
uniform float gray : hint_range(0.0, 1.0) = 0.0;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec2 resizer = vec2(1.0, 1.0);
uniform vec2 shifter = vec2(0.0, 0.0);

group_uniforms Flash;
uniform bool flash = false;
uniform float flash_speed = 2.5;
uniform float min_flash_alpha = 0.25;

group_uniforms Border;
uniform bool border = false;
uniform bool border_circle = false;
uniform bool border_ignore_alpha = false;
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_size : hint_range(0.0, 1.0, 0.01) = 0.1;

group_uniforms Segments;
uniform bool segments = false;
uniform float segment_count = 20.0;
uniform float segment_size = .1;

group_uniforms Texture;
uniform bool use_texture = false;
uniform vec2 scroll_speed = vec2(1.0, 1.0);
uniform vec2 texture_sizer = vec2(1.0, 1.0);
uniform float uv_scale : hint_range(0.0, 10, 0.1) = 1.0;
uniform vec4 texture_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool force_texture_color = false;
uniform sampler2D texture_albedo : hint_default_white, repeat_enable;
uniform float texture_rotation : hint_range(-360.0, 360.0, 1.0) = 0.0;
uniform vec4 background_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
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
	vec2 uv = UV;
	uv /= resizer;
	uv -= shifter;
	vec4 c = texture(TEXTURE, uv);
	float time = TIME;
	
	if (recolor) {
		COLOR = color;
	}
	COLOR.a = c.a;
	
	if (COLOR.a > 0.0 && alpha < 1.0) {
		COLOR.a = alpha;
	}
	
	if (flash && COLOR.a > 0.0) {
		COLOR.a = max(min_flash_alpha, abs(sin(time * flash_speed)));
	}
	
	if (gray > 0.0) {
		float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
		COLOR.rgb = mix(COLOR.rgb, vec3(avg), gray);
	}
	
	if (border && !border_circle) {
		if ((UV.x < border_size || UV.x > 1.0 - border_size) 
			|| (UV.y < border_size || UV.y > 1.0 - border_size)) {
				COLOR = border_color;
			}
	} else if (border && border_circle && c.a > 0.0) {
		float dist = distance(vec2(0.5), UV);
		if (dist > border_size) {
			COLOR = border_color;
			COLOR.a = 1.0;
		}
	}
	
	if (use_texture && COLOR.a == 0.0) {
		vec2 texture_uv = UV;
		texture_uv.x *= texture_sizer.x;
		texture_uv.y *= texture_sizer.y;
		
		texture_uv.x *= uv_scale;
		texture_uv.y *= uv_scale;
		
		texture_uv = rotateUV(texture_uv, radians(texture_rotation));
		
		float x_time = time * scroll_speed.x;
		float y_time = time * scroll_speed.y;
		texture_uv.x += x_time;
		texture_uv.y += y_time;
		
		vec4 c = texture(texture_albedo, texture_uv);
		if (c.a > 0.0) {
			COLOR = texture_color;
		}
		
		if (COLOR.a == 0.0) {
			COLOR = background_color;
		}
		
		if (force_texture_color) {
			COLOR = c;
		}
	}
	
	//if (segments) {
		//vec2 center = vec2(0.5);
		//float angle = 0.0;
	//}
}