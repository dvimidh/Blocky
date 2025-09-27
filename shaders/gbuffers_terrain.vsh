#version 430

layout (r32ui) uniform uimage3D cimage1;

//attributes
uniform sampler2D gtexture;
in vec3 vaPosition; 
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;
in vec4 mc_Entity;
in vec4 at_midBlock;
//uniforms
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat3 normalMatrix;
uniform int worldTime;
uniform vec3 chunkOffset;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;
out vec4 tangent;
out float EntityID;
out float ao;
#include "/programs/wave.glsl"
void main() {

    
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
    
        
        
	    vec3 foot_pos = (gbufferModelViewInverse * vec4( viewSpacePosition, 1.0) ).xyz;
	    vec3 world_pos = foot_pos + cameraPosition;
	
        #define VOXEL_AREA 128 //[32 64 128]

        vec3 block_centered_relative_pos = foot_pos + at_midBlock.xyz/64.0 +fract(cameraPosition);
	    ivec3 voxel_pos = ivec3(block_centered_relative_pos + VOXEL_AREA/2);
		//write voxel data
		if(mod(gl_VertexID,4)==0  //only write for 1 vertex
		&& clamp(voxel_pos,0,VOXEL_AREA) == voxel_pos//and in voxel range
	) //for one vertex per face, write if in range
	
    {
		vec4 voxel_data = vec4(0);
		if (abs(mc_Entity.x - 11111) > 0.5) {
            //voxel_data = vec4(0.0, 0.0, 0.0, -1.0);
        }
        
		if (abs(mc_Entity.x - 10007) < 0.5) {
            voxel_data = vec4(0.0, 0.4, 1.0, 160);
        }
		voxel_data = vec4(at_midBlock.a);
		
		//pack data
		uint integerValue = packUnorm4x8( voxel_data );
		
		//write to 3d image	 
		//          //imageStore(  //imageAtomicMax(   are some options for writing, look up on khronos.org (opengl documentation)
		imageAtomicMax(cimage1, voxel_pos, integerValue);	
			
		
		
	}
			
			
    
    gl_Position = projectionMatrix*viewSpacePositionVec4;
    

}