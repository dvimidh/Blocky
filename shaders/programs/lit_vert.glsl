#version 460 compatibility



//attributes
in vec3 vaPosition; 
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;
in vec4 mc_Entity;
//uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat3 normalMatrix;
uniform int worldTime;
uniform vec3 chunkOffset;
uniform vec3 cameraPosition;
attribute vec4 at_midBlock;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;
out float EntityID;
out float ao;
out vec3 block_centered_relative_pos;
#include "/programs/wave.glsl"
void main() {
    
    vec3 view_pos = vec4(gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 foot_pos = (gbufferModelViewInverse * vec4( view_pos ,1.) ).xyz;
	vec3 world_pos = foot_pos + cameraPosition;
    
	vec3 normals_face_world = normalize(gl_NormalMatrix * gl_Normal);
	normals_face_world = (gbufferModelViewInverse * vec4( normals_face_world ,1.) ).xyz;
	block_centered_relative_pos = foot_pos + at_midBlock.xyz/64.0 +fract(cameraPosition);
    
    EntityID = mc_Entity.x;
    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    ao = vaColor.a;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    vec4 viewSpacePositionVec4 = modelViewMatrix * vec4(vaPosition+chunkOffset,1);
    viewSpacePosition = viewSpacePositionVec4.xyz;
    geoNormal = normalMatrix * vaNormal;
    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);
    if(abs(mc_Entity.x-10001) < 0.5) {
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
        worldPos = vec3(worldPos.x + 0.03*sin(0.1*worldTime + worldPos.z + worldPos.x + 0.3*worldPos.y), worldPos.y + 0.005*sin(0.1*worldTime + worldPos.z + worldPos.x + 10), worldPos.z + 0.03*sin(0.1*worldTime + worldPos.z + worldPos.x + 15));
        viewSpacePositionVec4 = gbufferModelView*vec4(worldPos-cameraPosition, 1.0);
    }
    if(abs(EntityID-10006) < 0.5) {
        
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
        
        worldPos = wave(worldPos, worldTime);
        
        viewSpacePositionVec4 = gbufferModelView*vec4(worldPos-cameraPosition, 1.0);
       
    }
    

    
    //gl_Position = projectionMatrix*viewSpacePositionVec4;
    

}