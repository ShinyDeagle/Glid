shader_type spatial;

render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform bool circle = false;
uniform bool billboard = false;
void vertex() {
	if (billboard) {
		vec3 local_up = MODEL_MATRIX[1].xyz;
		//cross of:
		//	local_transform.basis.y     and    to_world(view_space.forward)
		//normalized
		//(represents right direction)
		vec4 ax = vec4(normalize(cross(local_up, INV_VIEW_MATRIX[2].xyz)), 0.0);
		//local_transform.basis.y
		//(represents up direction)
		vec4 ay = vec4(local_up.xyz, 0.0);
		//cross of:
		//	to_world(view_space.right)    and    local_transform.basis.y
		//(represents forward direction)
		vec4 az = vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, local_up)), 0.0);
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(ax, ay, az, MODEL_MATRIX[3]);
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

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
	if (billboard) {
		DEPTH = -100.0;
	}
}