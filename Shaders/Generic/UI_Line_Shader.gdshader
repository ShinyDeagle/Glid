shader_type canvas_item;

uniform vec4 color_front : source_color = vec4(1);
uniform vec4 color_back : source_color = vec4(.25, .25, .25, 1.0);
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.75;
uniform float uv_scale = 5.0;
uniform bool scroll_vertical = false;
uniform float x_shift : hint_range(0.0, 1.0, 0.01) = 0.0;

uniform float scroll_speed = 0.1;
uniform int dash_steps = 2;
void scroll_box(vec2 uv, inout vec3 albedo, inout float alpha) {
	float time = TIME;
	
	// EG: A position .1 away becomes 10
	// Done to help with accurary
	float offset = mod(TIME * scroll_speed, 1);
	float y_distance = 1.0 - uv.x - offset;
	float y_floored = floor(y_distance * 10.0);
	// EG 10 % 20
	float rem = mod(y_floored, floor(float(dash_steps)));
	
	// I fthe remainder is 0. We have a square region to rend
	if (rem == 0.0 && alpha > 0.0) {
		alpha = color_front.a;
		albedo = color_front.rgb;
	} else {
		alpha = color_back.a;
		albedo = color_back.rgb;
	}
}

void fragment() {
	float x = 1.0 - UV.x;
	float y = UV.y;
	if (scroll_vertical) {
		y *= uv_scale;
	} else{
		x *= uv_scale;
	}
	
	COLOR.a = 1.0;
	vec2 uv = scroll_vertical ? vec2(y + x_shift, x) : vec2(x + x_shift ,y);
	scroll_box(uv, COLOR.rgb, COLOR.a);
}