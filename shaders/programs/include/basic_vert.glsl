#version 430 compatibility



//attributes



//uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

uniform vec3 chunkOffset;
uniform vec3 cameraPosition;


out vec2 texCoord;
out vec3 foliageColor;
out vec3 viewpos;

void main() {

    viewpos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    foliageColor = gl_Color.rgb;

    gl_Position = ftransform();

    

}