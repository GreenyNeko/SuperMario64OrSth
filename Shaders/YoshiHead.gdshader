shader_type spatial;

uniform vec3 color: source_color;
uniform vec3 spikeColor: source_color;
varying vec3 objNormal;
varying vec3 objPos;

void vertex() {
	objNormal = NORMAL;
	objPos = VERTEX;
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float t = max(step(-0.8, objPos.y), step(-0.7, objNormal.y));
	ALBEDO = mix(spikeColor, color, t);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
