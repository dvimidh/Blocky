//#include "/programs/lit_frag.glsl"

#version 430 compatibility

#include "/programs/settings.glsl"


uniform sampler2D lightmap;
uniform float sunAngle;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec4 glcolor;
in vec2 texCoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
	
    

void main() {

vec3 blockLight = pow(texture(lightmap, vec2(lmcoord.x, 1/32.0)).rgb, vec3(2.2));
	vec3 skyLight = pow(texture(lightmap, vec2(1/32.0,lmcoord.y)).rgb, vec3(2.2));

    vec3 riseColor = vec3(1.6, 0.35, 0.3);
	vec3 dayColor = vec3(1.0);
	vec3 nightColor = vec3(0.2, 0.3, 0.3);
	if (sunAngle > 0.00 && sunAngle < 0.025) {
		skyLight = skyLight*riseColor;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		skyLight = skyLight*mix(riseColor, dayColor, 1/0.05 * (sunAngle - 0.025));
	}
	if (sunAngle > 0.075 && sunAngle < 0.45) {
		skyLight = skyLight*dayColor;
	}
	if (sunAngle > 0.45 && sunAngle < 0.5) {
		skyLight = skyLight*mix(dayColor, riseColor, 1/0.05 * (sunAngle-0.45));
	}
	if (sunAngle > 0.50 && sunAngle < 0.55) {
		skyLight = skyLight*mix(riseColor, nightColor, 1/0.05 * (sunAngle-0.5));
	}
	if ((sunAngle > 0.55 && sunAngle < 0.90) ) {
		skyLight = skyLight*nightColor;
	}
	if ((sunAngle > 0.90 && sunAngle < 1.0) ) {
		skyLight  = skyLight*mix(nightColor, riseColor, 1/0.1 * (sunAngle-0.90));;
	}
	vec3 ambientLight = (blockLight/2*(AMBIENT_INTENSITY) + 0.2*skyLight*SKYLIGHT_INTENSITY);
	color = glcolor * texture(lightmap, texCoord);
	color.rgb*=ambientLight;
	if (color.a < alphaTestRef) {
		discard;
	}
}