shader_type spatial;

uniform float alpha;
uniform vec3 color: source_color = vec3(1.0);
uniform sampler2D tex;
uniform vec2 dir;
uniform float rotDir;
uniform vec2 rotMid; 

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 rotate(vec2 v, float angle)
{
	return vec2(v.x*cos(angle)-v.y*sin(angle),v.x*sin(angle)+v.y*cos(angle));
}

void fragment() {
	ALBEDO = texture(tex, rotate(UV-rotMid, TIME*rotDir)+rotMid + dir * TIME).rgb * color;
	ALPHA = alpha;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
