shader_type spatial;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(1.0);

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb;
	ALBEDO = tint * (0.3 + dot(base, vec3(0.299, 0.587, 0.114)) * 0.9);
	ROUGHNESS = 0.9;
}
