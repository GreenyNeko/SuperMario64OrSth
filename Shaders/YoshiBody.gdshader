shader_type spatial;

uniform vec3 color : source_color;
uniform vec3 spikeColor: source_color;
varying vec3 objNormal;
varying vec3 objPos;

void vertex() {
	objNormal = NORMAL;
	objPos = VERTEX;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = step(0.4, objNormal.y);
	ALBEDO = mix(color, vec3(1.), t);
	t = (1.-(1.-step(-0.3, objPos.y)) * step(1.25, objPos.x));
	ALBEDO = mix(spikeColor, ALBEDO, t);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
