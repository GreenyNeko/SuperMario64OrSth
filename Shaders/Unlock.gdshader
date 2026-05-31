shader_type canvas_item;

uniform bool unlocked;
uniform float darken;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float grey = COLOR.r * 0.2126 + 0.7152 * COLOR.g + 0.0722 * COLOR.b;
	grey *= darken;
	if(!unlocked)
	{
		COLOR = vec4(grey, grey, grey, COLOR.a);
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
