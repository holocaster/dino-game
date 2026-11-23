shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float animation_time = 0.0;
uniform vec2 water_center;
uniform vec2 water_radius = vec2(1.55, 1.25);
uniform bool ocean = false;
uniform vec4 deep_color : source_color = vec4(0.12, 0.43, 0.5, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.4, 0.75, 0.68, 1.0);
varying vec2 water_position;

void vertex() {
	water_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 p = water_position - water_center;
	float radius = length(p / water_radius);
	float shore = ocean ? radius - 1.0 : 1.0 - radius;
	float waves = sin(p.x * 3.1 + animation_time * 0.8 + sin(p.y * 2.0)) * sin(p.y * 4.0 - animation_time * 0.65);
	vec3 water = mix(shallow_color.rgb, deep_color.rgb, smoothstep(0.0, 0.45, shore));
	water += waves * 0.035;
	float ripples = sin(p.x * 7.0 + p.y * 3.0 + animation_time * 0.7 + waves) + sin(p.y * 8.0 - animation_time * 0.5);
	float line_width = max(fwidth(ripples), 0.025);
	float caustics = 1.0 - smoothstep(0.04, 0.04 + line_width, abs(ripples));
	water += caustics * (1.0 - smoothstep(0.02, 0.20, shore)) * (ocean ? 0.018 : 0.055);
	float foam = (1.0 - smoothstep(0.01, 0.055, abs(shore - 0.035 - sin(animation_time * 0.6 + p.x) * 0.015)));
	float glint = smoothstep(0.82, 0.98, waves) * 0.12;
	ALBEDO = mix(water + glint, vec3(0.85, 0.94, 0.84), foam * 0.5);
}
