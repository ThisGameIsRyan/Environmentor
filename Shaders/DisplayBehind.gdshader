shader_type spatial;
render_mode cull_back, unshaded, depth_test_inverted;

uniform vec4 albedo : source_color;

void fragment() {
	ALBEDO = albedo.rgb * 0.9;
	ALPHA = 0.6;
}
