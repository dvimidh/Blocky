#version 460 compatibility

#include "/programs/settings.glsl"

out vec2 texCoord;
out vec3 viewSpacePosition;

void main() {
	texCoord = gl_MultiTexCoord0.xy;
	viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;
	gl_Position = ftransform();
}