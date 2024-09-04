shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : source_color = vec4(1.0);
uniform vec2 scroll_speed = vec2(0.0, 0.1);
uniform float uv_scale : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float alpha_diff : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
	vec2 uv = UV;
	float time = TIME;
	
	uv += scroll_speed * time;
	uv *= uv_scale;
	
	float y = uv.y;
	float a = clamp(sin(y * time) + 1.0, 0.0, 1.0);
	
	a -= alpha_diff;
	a = clamp(a, 0.0, 1.0);
	
	vec4 final_color = color;
	final_color.a = a;
	COLOR = final_color;
}
