#version 430 compatibility

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	//#ifdef DISTANT_HORIZONS
	//vec4 color = vec4(0.0);
    //#endif
	//#ifndef DISTANT_HORIZONS
	vec4 color = texture2D(texture, texcoord) * glcolor;
   // #endif
/* DRAWBUFFERS:06 */
	//gl_FragData[0] = color; //gcolor
	gl_FragData[1] = color;
}