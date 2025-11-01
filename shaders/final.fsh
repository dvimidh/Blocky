#version 430 compatibility

#include "/programs/settings.glsl"
in vec2 texCoord;
uniform sampler2D colortex0;
vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
// Timothy Lottes 2016, "Advanced Techniques and Optimization of HDR Color Pipelines"
// https://gpuopen.com/wp-content/uploads/2016/03/GdcVdrLottes.pdf
vec3 tonemap_lottes(vec3 rgb) {
	const vec3 a      = vec3(1.5); // Contrast
	const vec3 d      = vec3(0.91); // Shoulder contrast
	const vec3 hdr_max = vec3(1.2);  // White point
	const vec3 mid_in  = vec3(0.2); // Fixed midpoint x
	const vec3 mid_out = vec3(0.22); // Fixed midput y

	const vec3 b =
		(-pow(mid_in, a) + pow(hdr_max, a) * mid_out) /
		((pow(hdr_max, a * d) - pow(mid_in, a * d)) * mid_out);
	const vec3 c =
		(pow(hdr_max, a * d) * pow(mid_in, a) - pow(hdr_max, a) * pow(mid_in, a * d) * mid_out) /
		((pow(hdr_max, a * d) - pow(mid_in, a * d)) * mid_out);

	return pow(rgb, a) / (pow(rgb, a * d) * b + c);
}

void main() {
    color = mix(tonemap_lottes(color), color, 1.0);
    /*DRAWBUFFERS:0 */
    //color = color / (color+vec3(1.0));
    //color = vec3(1.0) - exp(-color * exposure);
    gl_FragData[0] = vec4(color, 1.0);
	//gl_FragData[0] = vec4(color, 1.0);
}