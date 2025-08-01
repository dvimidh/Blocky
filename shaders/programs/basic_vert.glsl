#version 460



//attributes
in vec3 vaPosition; 
in vec2 vaUV0;
in vec4 vaColor;


//uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;

uniform vec3 chunkOffset;
uniform vec3 cameraPosition;


out vec2 texCoord;
out vec3 foliageColor;


void main() {



    texCoord = vaUV0;
    foliageColor = vaColor.rgb;

    vec4 viewSpacePositionVec4 = modelViewMatrix * vec4(vaPosition+chunkOffset,1);

    gl_Position = projectionMatrix*modelViewMatrix*vec4(vaPosition + chunkOffset, 1);

    

}