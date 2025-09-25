#version 460 compatibility

layout (local_size_x = 8, local_size_y = 8, local_size_z = 4) in;
#include "/programs/settings.glsl"
const ivec3 workGroups = ivec3(voxelDistance/8, voxelDistance/8, voxelDistance/4);
layout (r32ui) uniform uimage3D cimage1;

void main()
{

	//get index of thread
    ivec3 uv_i = ivec3(gl_GlobalInvocationID.xyz);
		
	//do stuff
	
	//save data
    uint integerValue = packUnorm4x8(vec4(1.0, 0.0, 0.0, 1.0));
	imageAtomicMax(cimage1, uv_i, integerValue);	


	
}