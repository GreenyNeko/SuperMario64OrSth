shader_type canvas_item;

uniform bool isHalf;
uniform vec4 color: source_color;
uniform sampler2D mask;
uniform float animTime;
uniform int enabledAnims;

void vertex() {
	UV *= 1.;
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(enabledAnims == 0)
	{
		discard;
	}
	float zoom = 1.;
	float finalAnimTime = pow(animTime,3);
	if(isHalf)
	{
		vec4 texCol = texture(mask, vec2(abs((UV.x-0.5)*2.),UV.y)*(finalAnimTime)+vec2(0,0.5*(1.-(finalAnimTime))));
		COLOR = texCol * color;
	}
	else
	{
		COLOR = texture(mask, UV*(finalAnimTime)+0.5*(1.-(finalAnimTime))) * color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
