#version 430 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
uniform sampler2D colortex0; // original scene color
uniform sampler2D colortex1; // blurred bloom


void main() {
    vec3 color = texture(colortex0, texCoord).rgb;
    vec3 blurred = texture(colortex1, texCoord).rgb;
    vec3 bloom = max(blurred - color, 0.0);
    vec3 finalColor = color + clamp(bloom * BLOOM_STRENGTH, 0.0, 1.0);
    //vec3 finalColor = blurred;
    /*DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(finalColor, 1.0);
}