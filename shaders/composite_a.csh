#version 430 compatibility

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
#include "/programs/settings.glsl"
const ivec3 workGroups = ivec3(VOXEL_AREA, VOXEL_AREA, VOXEL_AREA);
layout (r32ui) uniform uimage3D cimage1;
layout (r32ui) uniform uimage3D cimage2;
void main()
{

	//get index of thread
    ivec3 uv_i = ivec3(gl_GlobalInvocationID);
	uint current = imageLoad(cimage1, uv_i).r;
	
	//save data
	uint integerValue = packUnorm4x8( vec4(1.0, 1.0, 0.0, 1.0) );
    imageAtomicMax(cimage2, uv_i, current);


}