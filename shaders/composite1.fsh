#version 460 compatibility

#include "/programs/settings.glsl"
in vec2 texCoord;
vec4 fragColor;

uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

void main() {
    // UV in current (smaller) target space
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    // texel from source (previous level) so offsets are correct
    vec2 srcTexel = 1.0 / vec2(textureSize(colortex1, 0));

 float offset = 2.0 * BLOOM_SPREAD; // Larger radius
    vec3 sum = vec3(0.0);
    sum += texture(colortex1, uv + srcTexel * vec2( offset,  offset)).rgb;
    sum += texture(colortex1, uv + srcTexel * vec2(-offset,  offset)).rgb;
    sum += texture(colortex1, uv + srcTexel * vec2( offset, -offset)).rgb;
    sum += texture(colortex1, uv + srcTexel * vec2(-offset, -offset)).rgb;

    // Normalize: average of the 4 samples
    fragColor = vec4(sum * 0.25, 1.0);
    /*DRAWBUFFERS:2 */
    gl_FragData[0] = fragColor;
}