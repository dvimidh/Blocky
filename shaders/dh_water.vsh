#version 460 compatibility



uniform mat4 dhProjection;


out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main() {

    geoNormal = gl_NormalMatrix* gl_Normal;

    blockColor = gl_Color;

    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;

    gl_Position = ftransform();
}