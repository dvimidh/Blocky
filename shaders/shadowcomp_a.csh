#version 430
#include "/programs/settings.glsl"
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(VOXEL_AREA, VOXEL_AREA, VOXEL_AREA);    
uniform usampler3D cSampler1;
layout (r32ui) uniform uimage3D cimage1;    
uniform usampler3D cSampler2;
layout (r32ui) uniform uimage3D cimage2; 
void main()
{
    ivec3 uv_id = ivec3(gl_GlobalInvocationID);
    uint currentVoxel = imageLoad(cimage1, uv_id).r;
    //uint currentVoxel = texture3D(cSampler1, uv_id).r;
    uint test = packUnorm4x8(vec4(1.0, 1.0, 1.0, 1.0));
    imageAtomicExchange(cimage2, uv_id, currentVoxel);      
   
}