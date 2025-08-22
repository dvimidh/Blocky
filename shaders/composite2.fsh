#version 460 compatibility

#include "/programs/settings.glsl"
in vec2 texCoord;
vec4 fragColor;

uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec2 srcTexel = 1.0 / vec2(textureSize(colortex2, 0));

float offset = 4.0 * BLOOM_SPREAD; // Larger radius
    vec3 sum = vec3(0.0);
    sum += texture(colortex2, uv + srcTexel * vec2( offset,  offset)).rgb;
    sum += texture(colortex2, uv + srcTexel * vec2(-offset,  offset)).rgb;
    sum += texture(colortex2, uv + srcTexel * vec2( offset, -offset)).rgb;
    sum += texture(colortex2, uv + srcTexel * vec2(-offset, -offset)).rgb;

    fragColor = vec4(sum * 0.25, 1.0);

    /*DRAWBUFFERS:3 */
    gl_FragData[0] = fragColor;
}