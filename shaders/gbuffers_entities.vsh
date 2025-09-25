#version 460 compatibility



//attributes
in vec3 vaPosition; 
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;

//uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat3 normalMatrix;

uniform vec3 chunkOffset;
uniform vec3 cameraPosition;

attribute vec4 at_midBlock;
out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;
out float ao;
out vec3 block_centered_relative_pos;
void main() {

    vec3 view_pos = vec4(gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 foot_pos = (gbufferModelViewInverse * vec4( view_pos ,1.) ).xyz;
	vec3 world_pos = foot_pos + cameraPosition;
    
	vec3 normals_face_world = normalize(gl_NormalMatrix * gl_Normal);
	normals_face_world = (gbufferModelViewInverse * vec4( normals_face_world ,1.) ).xyz;
	block_centered_relative_pos = foot_pos + at_midBlock.xyz/64.0 +fract(cameraPosition);


    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);

    geoNormal = normalMatrix * vaNormal;

    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    ao = vaColor.a;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    vec4 viewSpacePositionVec4 = modelViewMatrix * vec4(vaPosition+chunkOffset,1);
    viewSpacePosition = viewSpacePositionVec4.xyz;
    gl_Position = projectionMatrix*modelViewMatrix*vec4(vaPosition + chunkOffset, 1);

    

}