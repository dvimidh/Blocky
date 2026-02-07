#version 430 compatibility

#include "/programs/settings.glsl"


uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
#include "/programs/include/fogColorCalc.glsl"
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float sunAngle;
uniform float rainStrength;
uniform float far;
in vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
in vec3 viewpos;
const float sunPathRotation = 0.0;


vec3 myFogColor = fogColorCalc(sunAngle, rainStrength);

#include "/programs/include/SkyColorCalc.glsl"
float upDot = dot(normalize(viewpos), normalize(gbufferModelView[1].xyz));

void main() {
	
	vec3 color;
	if (starData.a > 0.5) {	
		color = mix(starData.rgb, calcSkyColor(normalize(viewpos.xyz), myFogColor, sunAngle, 1.0), clamp(mix(0.0, 1.0, clamp(upDot+0.15, 0.0, 1.0)), 0.0, 1.0));
		
	}

	else {
		color = calcSkyColor(normalize(viewpos.xyz), myFogColor, sunAngle, 1.0);
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
