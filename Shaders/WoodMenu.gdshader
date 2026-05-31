shader_type canvas_item;

uniform sampler2D woodTex : filter_linear;
uniform sampler2D overlay : filter_linear;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(woodTex, UV*vec2(1.,1.));
	vec4 overlayCol = texture(overlay, UV);
	COLOR = COLOR * (1. - overlayCol.a) + vec4(overlayCol.rgb, 1.) * overlayCol.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
