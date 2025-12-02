#version 430 compatibility

#include "/programs/settings.glsl"

const bool colortex1MipmapEnabled = true;
in vec2 texCoord;
uniform sampler2D colortex0; // original scene color
#ifdef BLOOM
uniform sampler2D colortex1; // blurred bloom
#endif
uniform float viewHeight;
uniform float viewWidth;
float GetLuminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}
#include "/programs/include/fxaa.glsl"

void main() {
    vec3 color = texture(colortex0, texCoord).rgb;
    vec3 finalColor = color;
    #ifdef FXAA
	color = FXAA311(finalColor);
    
	#endif
    #ifdef BLOOM

    vec3 blurred = texture(colortex1, texCoord).rgb;
    //vec3 blurred = textureLod(colortex1, texCoord, 2.0).rgb;
    vec3 bloom = clamp(blurred, 0.0, 0.5*BLOOM_STRENGTH);
    finalColor = color+bloom;
    #endif
    //finalColor = blurred;
    /*DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(finalColor, 1.0);
}