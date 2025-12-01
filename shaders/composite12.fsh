#version 430 compatibility

#include "/programs/settings.glsl"

// ...existing code...

in vec2 texCoord; // full-res input
uniform sampler2D colortex2;
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
    vec3 col = vec3(0.0);
    col += texture(colortex2, texCoord + vec2(-o.x * 2.0, 0.0)).rgb; // bottom-left
    col += texture(colortex2, texCoord + vec2( o.x * 2.0, 0.0)).rgb; // bottom-right
    col += texture(colortex2, texCoord + vec2(0.0, -o.y * 2.0)).rgb; // top-left
    col += texture(colortex2, texCoord + vec2(0.0,  o.y * 2.0)).rgb; // top-right

    	/* Sample 4 diagonal corners with 2x weight each */
	col += (texture(colortex2, texCoord + vec2(-o.x,  o.y)) * 2.0).rgb; /* top-left */
	col += (texture(colortex2, texCoord + vec2( o.x,  o.y)) * 2.0).rgb; /* top-right */
	col += (texture(colortex2, texCoord + vec2(-o.x, -o.y)) * 2.0).rgb; /* bottom-left */
	col += (texture(colortex2, texCoord + vec2( o.x, -o.y)) * 2.0).rgb; /* bottom-right */
    // normalize and apply strength
    vec3 outCol = (col / 12.0);

    /*DRAWBUFFERS:1 */
    
	gl_FragData[0] = vec4(outCol, 1.0);

}

