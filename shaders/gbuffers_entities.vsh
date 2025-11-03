#version 430 compatibility



//attributes

in vec4 at_tangent;

//uniforms

uniform mat4 gbufferModelViewInverse;


uniform vec3 chunkOffset;
uniform vec3 cameraPosition;
in vec4 mc_Entity;
out float EntityID;
out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;
out float ao;
out vec3 foot_pos;
void main() {

    tangent = vec4(normalize(gl_NormalMatrix * at_tangent.rgb), at_tangent.a);

    geoNormal = gl_NormalMatrix * gl_Normal;

    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    EntityID = mc_Entity.x;
    foliageColor = gl_Color.rgb;
    ao = gl_Color.a;
    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;;
    vec4 viewSpacePositionVec4 = gl_ModelViewMatrix * gl_Vertex;
    viewSpacePosition = viewSpacePositionVec4.xyz;
    foot_pos = (gbufferModelViewInverse * vec4( viewSpacePosition ,1.) ).xyz;
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;

    

}