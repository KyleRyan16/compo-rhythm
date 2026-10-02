shader_type spatial;
//render_mode unshaded;

uniform float t = -.0;
uniform vec3 albedo : source_color = vec3(1.0);
uniform sampler2D noise_tex;
uniform float noise_scale = 1.0;
uniform float burn_size : hint_range(0, 1, 0.01);
uniform float burn_emissive : hint_range(1, 30, 0.01);
uniform vec3 burn_color : source_color = vec3(1.0);
uniform vec3 impact_position;
varying vec3 world_pos;

void vertex() {
	// Calculate the world position of the vertex
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Calculate distance from impact point in world space
	float dist = distance(world_pos, impact_position);
	
	// Scale distance by impact radius and add noise
	float noise = texture(noise_tex, UV).r;
	float final_dist = dist - (noise * noise_scale * t);
	
	// Create the main dissolve cutoff
	float dissolve_mask = step(t, final_dist);
	
	// Discard pixels past the dissolve threshold
	if (dissolve_mask < 0.1) {
		discard;
	}
	
	float burn_mask = step(clamp(final_dist - burn_size, 0.01, 1), t);
	
	// Apply base color (or texture) mixed with the burn glow
	ALBEDO = mix(albedo, burn_color.rgb, burn_mask);
	EMISSION = burn_color.rgb * burn_mask * burn_emissive;
	ALPHA = dissolve_mask;
}
