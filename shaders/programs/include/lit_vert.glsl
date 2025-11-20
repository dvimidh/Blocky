#version 430 compatibility



//attributes
in vec4 at_tangent;
in vec4 mc_Entity;
in vec4 at_midBlock;
//uniforms
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
out float ao;
out float lightLevel;
out vec3 foot_pos;


#include "/programs/include/wave.glsl"
void main() {

    lightLevel = at_midBlock.a;
    EntityID = mc_Entity.x;
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    foliageColor = gl_Color.rgb;
    ao = gl_Color.a;
    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vec4 viewSpacePositionVec4 = gl_ModelViewMatrix * gl_Vertex;
    viewSpacePosition = viewSpacePositionVec4.xyz;
    geoNormal = gl_NormalMatrix * gl_Normal;
    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);
    foot_pos = (gbufferModelViewInverse * vec4( viewSpacePosition, 1.) ).xyz;

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
    

    
    gl_Position = gl_ProjectionMatrix*viewSpacePositionVec4;
    

}