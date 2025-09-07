#version 460 compatibility


uniform mat3 normalMatrix;
uniform mat4 dhProjection;
in vec4 at_tangent;

out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec2 texCoord;
out vec4 tangent;

void main() {

    geoNormal = gl_NormalMatrix* gl_Normal;

    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);

    blockColor = gl_Color;

    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    texCoord = gl_MultiTexCoord0.xy;

    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;

    gl_Position = ftransform();
}