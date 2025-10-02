//#include "/programs/lit_vert.glsl"
#version 430 compatibility

out vec2 lmcoord;
out vec4 glcolor;
out vec2 texCoord;
void main() {
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	gl_Position = ftransform();
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}