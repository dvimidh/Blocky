#version 460 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;

uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform sampler2D colortex0;

float GetLuminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

#include "/programs/fxaa.glsl"

void main() {
	vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
	#ifdef FXAA
	color = FXAA311(color);	
	#endif
    /*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(color, 1.0);
}
