#version 430 compatibility

#include "/programs/settings.glsl"

out vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
out vec3 viewpos;
void main() {
	viewpos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	gl_Position = ftransform();
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
}