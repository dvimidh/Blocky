/*
	This code is from the VOXELIZING TUTORIAL by timetravelbeard
		learn more at the links below:
			https://www.patreon.com/timetravelbeard
			https://youtube.com/@timetravelbeard3588
			https://discord.gg/S6F4r6K5yU 
			
		if you use this code as is, please leave this header. feel free to use this code in any shaders.
*/
	
	//positions
	vec3 shadow_view_pos = vec4(gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 foot_pos = (shadowModelViewInverse * vec4( shadow_view_pos ,1.) ).xyz;
	vec3 world_pos = foot_pos + cameraPosition;


	//voxel map position
	


	vec3 block_centered_relative_pos = foot_pos + at_midBlock.xyz/64.0 +fract(cameraPosition);
	ivec3 voxel_pos = ivec3(block_centered_relative_pos + voxelDistance);

#include "/programs/settings.glsl"

	//write voxel data
	if(mod(gl_VertexID,4)==0  //only write for 1 vertex
		&& clamp(voxel_pos,0,voxelDistance) == voxel_pos && entityId == 0//and in voxel range
	) //for one vertex per face, write if in range
	
    {
		vec4 voxel_data = vec4(0, 0, 0, 1.0);
		voxel_data = vec4(at_midBlock.a);

		if (abs(mc_Entity.x - 10007) < 0.5) {
            voxel_data = vec4(0.0, 0.4, 1.0, 1);
        }
		
		
		//pack data
		uint integerValue = packUnorm4x8( voxel_data );
		
		//write to 3d image	 
		//          //imageStore(  //imageAtomicMax(   are some options for writing, look up on khronos.org (opengl documentation)
		//imageAtomicMax(cimage1, voxel_pos, integerValue);	
			
		
		
	}