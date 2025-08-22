shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

uniform float scroll_speed = 0.02;
uniform sampler2D sky_texture : source_color, filter_nearest;


void vertex() {

}

void fragment() {
	ALBEDO = texture(sky_texture, vec2(UV.x + TIME * scroll_speed ,UV.y)).rgb;
	ALPHA = texture(sky_texture, vec2(UV.x + TIME * scroll_speed ,UV.y)).a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
