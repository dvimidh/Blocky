#version 430 compatibility

#include "/programs/settings.glsl"
in vec2 texCoord;
uniform sampler2D colortex0;
vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
float exposure = 1.0;


void main() {
    
    /*DRAWBUFFERS:0 */
    //color = color / (color+vec3(1.0));
    //color = vec3(1.0) - exp(-color * exposure);
    gl_FragData[0] = vec4(color, 1.0);
	//gl_FragData[0] = vec4(color, 1.0);
}