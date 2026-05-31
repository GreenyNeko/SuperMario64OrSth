shader_type canvas_item;

uniform float animTime;
uniform int enabledAnims;
uniform vec3 color: source_color = vec3(1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(enabledAnims == 0)
	{
		discard;
	}
	COLOR = vec4(color, animTime);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
