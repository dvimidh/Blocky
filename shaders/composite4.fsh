#version 460 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
uniform sampler2D colortex4;
uniform float viewWidth;
uniform float viewHeight;
vec2 srcResolution = vec2(viewWidth, viewHeight);

void main() {
vec2 srcTexelSize = 1.0 / srcResolution;
    float x = srcTexelSize.x;
    float y = srcTexelSize.y;

    // 13-tap kernel
    vec3 a = texture(colortex4, texCoord + vec2(-2*x,  2*y)).rgb;
    vec3 b = texture(colortex4, texCoord + vec2(   0,  2*y)).rgb;
    vec3 c = texture(colortex4, texCoord + vec2( 2*x,  2*y)).rgb;
    vec3 d = texture(colortex4, texCoord + vec2(-2*x,    0)).rgb;
    vec3 e = texture(colortex4, texCoord).rgb;
    vec3 f = texture(colortex4, texCoord + vec2( 2*x,    0)).rgb;
    vec3 g = texture(colortex4, texCoord + vec2(-2*x, -2*y)).rgb;
    vec3 h = texture(colortex4, texCoord + vec2(   0, -2*y)).rgb;
    vec3 i = texture(colortex4, texCoord + vec2( 2*x, -2*y)).rgb;
    vec3 j = texture(colortex4, texCoord + vec2(-x, y)).rgb;
    vec3 k = texture(colortex4, texCoord + vec2( x, y)).rgb;
    vec3 l = texture(colortex4, texCoord + vec2(-x, -y)).rgb;
    vec3 m = texture(colortex4, texCoord + vec2( x, -y)).rgb;

    vec3 downsample = e * 0.125;
    downsample += (a + c + g + i) * 0.03125;
    downsample += (b + d + f + h) * 0.0625;
    downsample += (j + k + l + m) * 0.125;


	/*DRAWBUFFERS:5 */
	gl_FragData[0] = vec4(downsample, 1.0);
}
