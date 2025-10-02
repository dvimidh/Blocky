#version 430 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;
vec2 srcResolution = vec2(viewWidth, viewHeight);
float filterRadius = BLOOM_SPREAD/srcResolution.x;

void main() {
    float x = filterRadius;
    float y = filterRadius;

    // 3x3 tent filter
    vec3 a = texture(colortex2, texCoord + vec2(-x,  y)).rgb;
    vec3 b = texture(colortex2, texCoord + vec2( 0,  y)).rgb;
    vec3 c = texture(colortex2, texCoord + vec2( x,  y)).rgb;
    vec3 d = texture(colortex2, texCoord + vec2(-x,  0)).rgb;
    vec3 e = texture(colortex2, texCoord).rgb;
    vec3 f = texture(colortex2, texCoord + vec2( x,  0)).rgb;
    vec3 g = texture(colortex2, texCoord + vec2(-x, -y)).rgb;
    vec3 h = texture(colortex2, texCoord + vec2( 0, -y)).rgb;
    vec3 i = texture(colortex2, texCoord + vec2( x, -y)).rgb;

    vec3 upsample = e * 4.0;
    upsample += (b + d + f + h) * 2.0;
    upsample += (a + c + g + i);
    upsample *= 1.0 / 16.0;
    /*DRAWBUFFERS:1 */
    gl_FragData[0] = vec4(upsample, 1.0);
}