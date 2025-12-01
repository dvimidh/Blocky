#version 430 compatibility

#include "/programs/settings.glsl"
in vec2 texCoord;
uniform sampler2D colortex0;
vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
// Timothy Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
// https://gpuopen.com/wp-content/uploads/2016/03/GdcVdrLottes.pdf
vec3 tonemap_lottes(vec3 rgb) {
	const vec3 a      = vec3(1.7); // Constrast
	const vec3 d      = vec3(1.02); // Shoulder contrast	
	const vec3 hdr_max = vec3(6);  // White point
	const vec3 mid_in  = vec3(0.12); // Fixed midpoint x		
	const vec3 mid_out = vec3(0.085); // Fixed midput y

	const vec3 b =
		(-pow(mid_in, a) + pow(hdr_max, a) * mid_out) /	
		((pow(hdr_max, a * d) - pow(mid_in, a * d)) * mid_out);
	const vec3 c =
		(pow(hdr_max, a * d) * pow(mid_in, a) - pow(hdr_max, a) * pow(mid_in, a * d) * mid_out) /
		((pow(hdr_max, a * d) - pow(mid_in, a * d)) * mid_out);

	return pow(rgb, a) / (pow(rgb, a * d) * b + c);
}

vec3 tonemapMe(vec3 color) {
	float exposure = 4.0;
	// Apply tonemapping operator here
	color = pow((1-1/(1+pow(color, vec3(exposure)))), vec3(exposure));
	return color;
}

void main() {
    color = mix(tonemapMe(color), color, 0.0); 
    /*DRAWBUFFERS:0 */
    //color = color / (color+vec3(1.0));
    //color = vec3(1.0) - exp(-color * exposure);
    gl_FragData[0] = vec4(color, 1.0);
	//gl_FragData[0] = vec4(color, 1.0);
}