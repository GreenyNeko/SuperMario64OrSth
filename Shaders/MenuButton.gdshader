shader_type canvas_item;

uniform sampler2D buttonTexture;
uniform sampler2D buttonShading;
uniform sampler2D buttonBackground;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(buttonBackground, UV);
	// Called for every pixel the material is visible on.
	vec4 shadingColor = texture(buttonShading, UV);
	COLOR = COLOR * (1. -shadingColor.a) + vec4(shadingColor.rgb, 1.) * shadingColor.a;
	float t = min(step(0.1, UV.x), step(0.15, UV.y));
	t = min(t, 1.-step(0.85, UV.x));
	t = min(t, 1.-step(0.8, UV.y));
	COLOR = mix(COLOR, texture(buttonTexture, UV*1.5-vec2(0.2,0.25)), t);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
