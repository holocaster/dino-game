shader_type spatial;
render_mode diffuse_burley;

uniform vec4 soil_color : source_color = vec4(0.80, 0.65, 0.44, 1.0);
uniform float path_width = 2.8;

varying vec2 ground_position;

float noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 weight = fract(p);
	weight = weight * weight * (3.0 - 2.0 * weight);
	vec4 corners = fract(sin(vec4(dot(cell, vec2(127.1, 311.7)), dot(cell + vec2(1.0, 0.0), vec2(127.1, 311.7)), dot(cell + vec2(0.0, 1.0), vec2(127.1, 311.7)), dot(cell + vec2(1.0), vec2(127.1, 311.7)))) * 43758.5453);
	return mix(mix(corners.x, corners.y, weight.x), mix(corners.z, corners.w, weight.x), weight.y);
}

void vertex() {
	ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	float patches = noise(ground_position * 0.7);
	float grain = noise(ground_position * 5.0);
	float edge = path_width + (patches - 0.5) * 0.22;
	float grass = smoothstep(edge - 0.25, edge + 0.08, UV.x);
	vec3 soil = soil_color.rgb * (0.93 + patches * 0.12 + grain * 0.05);
	vec3 meadow = COLOR.rgb * (0.86 + patches * 0.24 + grain * 0.07);
	ALBEDO = mix(soil, meadow, grass);
	ROUGHNESS = 1.0;
}
