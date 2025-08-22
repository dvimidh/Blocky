#version 460 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
uniform float viewHeight;
uniform float viewWidth;
uniform sampler2D colortex1;
uniform sampler2D colortex0;
vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;


void main() {
    //vec3 blurred = sample_blur(texCoord, 25.0, 0.0).rgb; // radius in px, gamma controls falloff
     vec3 blurred = texture2DLod(colortex1, texCoord, 0.0).rgb;
    /*DRAWBUFFERS:0 */
	blurred = max(blurred/12 - color, 0.0); 
    gl_FragData[0] = vec4(blurred/12*0.6*BLOOM_STRENGTH + color, 1.0);
	//gl_FragData[0] = vec4(blurred/12, 1.0);
}