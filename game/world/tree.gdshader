shader_type spatial;
render_mode cull_disabled, diffuse_lambert_wrap;

uniform float canopy_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float trunk_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float opacity = mix(trunk_alpha, canopy_alpha, COLOR.a);
	float threshold = fract(52.9829189 * fract(dot(FRAGCOORD.xy, vec2(0.06711056, 0.00583715))));
	if (opacity <= threshold) discard;
	ALBEDO = COLOR.rgb;
	BACKLIGHT = COLOR.rgb * COLOR.a * 0.18;
	ROUGHNESS = 0.95;
}
