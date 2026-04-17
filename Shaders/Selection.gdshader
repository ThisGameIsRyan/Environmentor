shader_type spatial;
render_mode wireframe,unshaded, depth_test_disabled;
uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	ALBEDO = vec3(1, 0.5, 0);
	if (depth > FRAGCOORD.z)
	{
		ALPHA = 0.2;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
