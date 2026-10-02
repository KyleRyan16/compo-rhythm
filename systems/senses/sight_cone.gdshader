shader_type spatial;
render_mode unshaded;

// Vertex displacement
uniform int vertex_count;
uniform vec3 vertices[128];
uniform float fov;

// for circles
uniform float amplitude: hint_range(0, 2, 0.01) = 2.0;
uniform float frequency: hint_range(0, 150, 0.01) = 12.69;
uniform float rippleRate : hint_range(0.5, 150.0, 0.1) = 9.2;

uniform vec3 wave_color : source_color;


// for wave
uniform float waveAmplitude = 0.1;
uniform float waveFrequency = 4.0;

// other
uniform sampler2D noise;
uniform float noise_size = 1;

vec2 wave(vec2 uv, float time) {
	return vec2(
		uv.x + sin(uv.y * waveFrequency * 5.0 + time) * waveAmplitude,
		uv.y + sin(uv.x * waveFrequency + time) * waveAmplitude
	);
}

void vertex() {
	if (VERTEX != vec3(0,0,0))
	{
		float angle = atan(VERTEX.x, -VERTEX.z);

		float start_angle = -radians(fov) * 0.5;
		float end_angle = radians(fov) * 0.5;

		float likeness = (angle - start_angle) / (end_angle - start_angle);

		int index = int(round(likeness * float(vertex_count -1)));

		vec3 vertex_displaced = vertices[index];

		UV *= length(vertex_displaced) / length(VERTEX.xyz);

		VERTEX.xyz = vertex_displaced;
		
	}
}

void fragment() {
	vec2 uv = vec2(UV.x - 0.5, UV.y);
	vec2 wave_uv = wave(uv, TIME);
	vec4 ns = texture(noise, uv);
	

	float dist = length(uv);
	float ripple = sin(dist * -frequency + rippleRate * TIME) * amplitude / dist;

	vec4 color;
	color.rgb = wave_color;
	color.a = min(ripple, 1);

   	ALBEDO = max(color.rgb, vec3(0.01, 0.01, 0.01));
	ALPHA = max(color.a, 0.05);
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
}
