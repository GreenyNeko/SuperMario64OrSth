shader_type spatial;

uniform vec3 underColor: source_color;
uniform vec3 color: source_color;
uniform vec3 saddleCol: source_color;
varying vec3 objNormal;

void vertex() {
	objNormal = NORMAL;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = step(-0.4, objNormal.y);
	ALBEDO = mix(saddleCol, color, t);
	t = step(0.2, objNormal.y);
	ALBEDO = mix(ALBEDO, underColor, t);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
