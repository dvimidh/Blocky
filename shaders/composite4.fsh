#version 460 compatibility
in vec2 texCoord;
vec4 fragColor;

#include "/programs/settings.glsl"
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform float viewWidth;
uniform float viewHeight;

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    // texel relative to the smaller (colortex4) to sample neighbors properly
    vec2 smallTexel = 1.0 / vec2(textureSize(colortex4, 0));
    float offset = 2.0; // matches downsample deepness

    vec3 smallBlur = vec3(0.0);
    smallBlur += texture(colortex4, uv + smallTexel * vec2( offset,  offset)).rgb;
    smallBlur += texture(colortex4, uv + smallTexel * vec2(-offset,  offset)).rgb;
    smallBlur += texture(colortex4, uv + smallTexel * vec2( offset, -offset)).rgb;
    smallBlur += texture(colortex4, uv + smallTexel * vec2(-offset, -offset)).rgb;
    smallBlur *= 0.25;

    // read current (larger) level so we can blend in the upsampled blur
   

 
    fragColor = vec4(smallBlur, 1.0);
    /*DRAWBUFFERS:3 */
    gl_FragData[0] = fragColor;
}
