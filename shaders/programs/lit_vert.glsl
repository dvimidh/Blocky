#version 460



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


out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;
out float EntityID;
#include "/programs/wave.glsl"
void main() {

    
    EntityID = mc_Entity.x;
    texCoord = vaUV0;
    foliageColor = vaColor.rgb;
    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);
    vec4 viewSpacePositionVec4 = modelViewMatrix * vec4(vaPosition+chunkOffset,1);
    viewSpacePosition = viewSpacePositionVec4.xyz;
    geoNormal = normalMatrix * vaNormal;
    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);
    if(abs(mc_Entity.x-10001) < 0.5) {
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
        worldPos = vec3(worldPos.x + 0.03*sin(0.1*worldTime + worldPos.z + worldPos.x), worldPos.y + 0.005*sin(0.1*worldTime + worldPos.z + worldPos.x + 10), worldPos.z + 0.03*sin(0.1*worldTime + worldPos.z + worldPos.x + 15));
        viewSpacePositionVec4 = gbufferModelView*vec4(worldPos-cameraPosition, 1.0);
    }
    if(abs(EntityID-10006) < 0.5) {
        
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
        
        worldPos = wave(worldPos, worldTime);
        
        viewSpacePositionVec4 = gbufferModelView*vec4(worldPos-cameraPosition, 1.0);
       
    }
    

    
    gl_Position = projectionMatrix*viewSpacePositionVec4;
    

}