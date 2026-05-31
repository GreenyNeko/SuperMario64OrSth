shader_type spatial;

uniform sampler2D paintingTextureTop;
uniform sampler2D paintingTextureBot;
uniform vec3 marioPos;
uniform bool showWaves;
uniform float fastWaveTimer;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 worldPos = (INV_VIEW_MATRIX * vec4(VERTEX,1.)).xyz;
	vec3 textureTop = texture(paintingTextureTop, vec2(UV.x, UV.y*2.)).rgb;
	vec3 textureBottom = texture(paintingTextureBot, vec2(UV.x, UV.y*2.)).rgb;
	ALBEDO = textureTop * float(UV.y < 0.5) + textureBottom * float(UV.y > 0.5);
	if(!showWaves && fastWaveTimer > 0.)
	{
		float pixelDist = distance(marioPos.zy, worldPos.zy);
		float waves = abs(pow(sin(16.*TIME-pixelDist),1.))*0.3+0.7;
		ALBEDO *= min(1.,waves + pixelDist / 16. + 1. / pixelDist * max(0,(fastWaveTimer - 1.)));
	}
	if(showWaves)
	{
		float pixelDist = distance(marioPos.zy, worldPos.zy);
		float waves = max(0.,pow(sin(8.*TIME-pixelDist),2.))*0.6+0.4;
		ALBEDO *= min(1.,waves + pixelDist / 16.);
		ALBEDO *= max(1., 0.5+pow(cos(7.*TIME-pixelDist),2.) - pixelDist / 16.);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
