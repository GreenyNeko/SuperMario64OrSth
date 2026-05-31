shader_type sky;

uniform sampler2D skyTexture;

void sky() {
	COLOR = texture(skyTexture, SKY_COORDS).rgb;
	/*vec2 skyUV = vec2(SKY_COORDS.x, max(0.004,SKY_COORDS.y+0.05));
	if(skyUV.y < 0.06)
	{
		COLOR = texture(skyTexture, vec2(0.5,0.01)).rgb;
	}
	else
	{
		COLOR = texture(skyTexture, skyUV).rgb;
	}*/
}
