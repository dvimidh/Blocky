#version 460 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
uniform sampler2D colortex3;
uniform float viewWidth;
uniform float viewHeight;
vec2 srcResolution = vec2(viewWidth, viewHeight);
float filterRadius = BLOOM_SPREAD/srcResolution.x;
void main() {
    float x = filterRadius;
    float y = filterRadius;

    // 3x3 tent filter
    vec3 a = texture(colortex3, texCoord + vec2(-x,  y)).rgb;
    vec3 b = texture(colortex3, texCoord + vec2( 0,  y)).rgb;
    vec3 c = texture(colortex3, texCoord + vec2( x,  y)).rgb;
    vec3 d = texture(colortex3, texCoord + vec2(-x,  0)).rgb;
    vec3 e = texture(colortex3, texCoord).rgb;
    vec3 f = texture(colortex3, texCoord + vec2( x,  0)).rgb;
    vec3 g = texture(colortex3, texCoord + vec2(-x, -y)).rgb;
    vec3 h = texture(colortex3, texCoord + vec2( 0, -y)).rgb;
    vec3 i = texture(colortex3, texCoord + vec2( x, -y)).rgb;

    vec3 upsample = e * 4.0;
    upsample += (b + d + f + h) * 2.0;
    upsample += (a + c + g + i);
    upsample *= 1.0 / 16.0;

    /*DRAWBUFFERS:2 */
    gl_FragData[0] = vec4(upsample, 1.0);
}