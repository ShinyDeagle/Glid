shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float scale : hint_range(0.0, 10.0, 0.1) = 2.0;
void fragment() {
	vec2 uv = UV;
	vec4 color = texture(TEXTURE, UV);

	COLOR.a = mix(0.0, alpha, pow(uv.y, scale));
}
