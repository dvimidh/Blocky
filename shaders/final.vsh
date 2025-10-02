#version 430 compatibility

#include "/programs/settings.glsl"

out vec2 texCoord;


void main() {
	texCoord = gl_MultiTexCoord0.xy;
	gl_Position = ftransform();
}