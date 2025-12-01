#version 430 compatibility

#include "/programs/settings.glsl"

// ...existing code...

in vec2 texCoord;// full-res input
uniform sampler2D colortex1;
float offset = BLOOM_SPREAD;        // offset multiplier (like your 'offset' uniform)
uniform float viewWidth;
uniform float viewHeight;


void main() {
	
	

    // reciprocal pixel size
    vec2 frameSizeRCP = vec2(1.0 / viewWidth, 1.0 / viewHeight);

    // half-pixel and scaled offset
    vec2 halfpixel = frameSizeRCP * 0.5;
    vec2 o = halfpixel * offset;

    // Dual-Kawase style: center weighted x4 + 4 diagonal samples
    vec3 col = texture(colortex1, texCoord).rgb * 4.0;
    col += texture(colortex1, texCoord + vec2(-o.x, -o.y)).rgb; // bottom-left
    col += texture(colortex1, texCoord + vec2( o.x, -o.y)).rgb; // bottom-right
    col += texture(colortex1, texCoord + vec2(-o.x,  o.y)).rgb; // top-left
    col += texture(colortex1, texCoord + vec2( o.x,  o.y)).rgb; // top-right

    // normalize and apply strength
    vec3 outCol = (col / 8.0);

    /*DRAWBUFFERS:2 */
    
	gl_FragData[0] = vec4(outCol, 1.0);

}

