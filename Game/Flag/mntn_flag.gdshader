shader_type spatial;
render_mode blend_mix, cull_disabled;

uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude_y = 50.0;
uniform float amplitude_x = 25.0;
uniform float inclination = 50.0;
uniform vec3 color : source_color = vec3(1.0);
uniform sampler2D tex : source_color;

void vertex() {
	VERTEX.y += sin((UV.x - TIME * speed) * frequency_y) * amplitude_y * UV.x;
	VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude_x * UV.x;
	VERTEX.x -= UV.y * inclination;
}

void fragment() {
	vec4 albedo_tex = texture(tex, UV);
	ALBEDO = color * albedo_tex.xyz;
}