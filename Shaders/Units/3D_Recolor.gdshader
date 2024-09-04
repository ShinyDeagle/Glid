shader_type spatial;

render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform bool circle = false;

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = alpha;
	
	if (circle) {
		float radius = 0.5;
		
		vec2 m = UV - vec2(0.5, 0.5);
		float dist = radius - sqrt(m.x * m.x + m.y * m.y);
		
		if (dist <= 0.0) {
			ALPHA = 0.0;
		}
	}
}