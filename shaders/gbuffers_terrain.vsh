#version 430 compatibility

layout (r32ui) uniform uimage3D cimage1;
#include "/programs/settings.glsl"
//attributes
uniform sampler2D gtexture;
in vec4 at_tangent;
attribute vec4 mc_Entity;
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
out vec3 foot_pos;
out float lightLevel;
#include "/programs/wave.glsl"
void main() {
    lightLevel = at_midBlock.a;
    
    EntityID = mc_Entity.x;
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    foliageColor = gl_Color.rgb;
    ao = gl_Color.a;
    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vec4 viewSpacePositionVec4  = vec4(gl_ModelViewMatrix * gl_Vertex);
    viewSpacePosition = viewSpacePositionVec4.xyz;
    geoNormal = gl_NormalMatrix * gl_Normal;
    tangent = vec4(normalize(gl_NormalMatrix * at_tangent.rgb), at_tangent.a);
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
    
        
        
	    vec3 view_pos = vec4(gl_ModelViewMatrix * gl_Vertex).xyz;
        foot_pos = (gbufferModelViewInverse * vec4( view_pos ,1.) ).xyz;
      
        

	
        

        vec3 block_centered_relative_pos = foot_pos + at_midBlock.xyz/64.0 +fract(cameraPosition);
	    ivec3 voxel_pos = ivec3(block_centered_relative_pos + VOXEL_AREA/2);
		//write voxel data
		if(mod(gl_VertexID,4)==0  //only write for 1 vertex
		&& clamp(voxel_pos,0,voxelDistance) == voxel_pos//and in voxel range
	) //for one vertex per face, write if in range
	
    {
		vec4 voxel_data = vec4(1.0, 1.0, 1.0, 1.0);
        
        //voxel_data = vec4(at_midBlock.a);

		if (abs(EntityID - 10010) < 0.5) {
            voxel_data = vec4(0.0, 0.4, 1.0, 1.0);
        }
		
		
		//pack data
		uint integerValue = packUnorm4x8( voxel_data ); 
		
		//write to 3d image	 
		//          //imageStore(  //imageAtomicMax(   are some options for writing, look up on khronos.org (opengl documentation)
		imageAtomicMax(cimage1, voxel_pos, integerValue);	
		
		
		
	}
			
			
    
    gl_Position = gl_ProjectionMatrix*viewSpacePositionVec4;
    

}