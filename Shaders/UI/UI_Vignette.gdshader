shader_type canvas_item;

uniform vec4 color : source_color;
uniform float blur_distance : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float power = 1.0;

void fragment() {
	COLOR = color;
	vec2 uv = UV;
	float dist = distance(uv, vec2(0.5));
	//float x_dist = distance(uv.x, 0.5);
	//float y_dist = distance(uv.y, 0.5);
	//float dist = max(x_dist, y_dist);
	
	COLOR.a = pow(dist, power);
}