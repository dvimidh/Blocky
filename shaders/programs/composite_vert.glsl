#version 330 compatibility

#include "/settings.glsl"

varying vec2 texCoord;

void main() {
	texCoord = gl_MultiTexCoord0.xy;
	gl_Position = ftransform();
}