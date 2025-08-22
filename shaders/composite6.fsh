#version 460 compatibility
in vec2 texCoord;
vec4 fragColor;

#include "/programs/settings.glsl"
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    vec2 smallTexel = 1.0 / vec2(textureSize(colortex2, 0));
    float offset = 1.0;

    vec3 smallBlur = vec3(0.0);
    smallBlur += texture(colortex2, uv + smallTexel * vec2( offset,  offset)).rgb;
    smallBlur += texture(colortex2, uv + smallTexel * vec2(-offset,  offset)).rgb;
    smallBlur += texture(colortex2, uv + smallTexel * vec2( offset, -offset)).rgb;
    smallBlur += texture(colortex2, uv + smallTexel * vec2(-offset, -offset)).rgb;
 

 
    fragColor = vec4(smallBlur, 1.0);

    /* DRAWBUFFERS:1 */
    gl_FragData[0] = fragColor;
}
