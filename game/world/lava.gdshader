shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float animation_time = 0.0;
varying vec2 lava_position;

void vertex() {
	lava_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 p = lava_position * 1.3;
	float t = animation_time * 0.22;
	float waves = sin(p.x * 2.0 + sin(p.y * 1.8 + t)) * sin(p.y * 2.4 - t);
	float heat = smoothstep(-0.65, 0.8, waves);
	vec3 lava = mix(vec3(0.78, 0.12, 0.025), vec3(1.0, 0.65, 0.12), heat);
	float crust = smoothstep(0.48, 0.72, sin(p.x + sin(p.y * 1.7 - t)) * cos(p.y * 1.6 + t));
	ALBEDO = mix(lava, vec3(0.22, 0.09, 0.07), crust * 0.85);
	EMISSION = lava * (1.0 - crust) * 0.18;
}
