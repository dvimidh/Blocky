#version 460 compatibility

#include "/programs/settings.glsl"

out vec4 glcolor;

void main() {
	gl_Position = ftransform();
	glcolor = gl_Color;
}