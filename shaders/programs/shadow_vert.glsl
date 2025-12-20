#version 430 compatibility
#include "/programs/include/distort.glsl"

layout (r32ui) uniform uimage3D cimage1;
layout (r32ui) uniform uimage3D cimage2;

uniform sampler2D gtexture;
attribute vec4 at_midBlock;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
attribute vec4 mc_Entity;
uniform float frameTimeCounter;
uniform mat4 shadowModelViewInverse;
uniform int entityId;
uniform int renderStage;
out vec2 lmcoord;
out vec2 texCoord;
out vec3 foliageColor;
out vec4 mc_EntityOut;

void main() {

    mc_EntityOut = mc_Entity;
    
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    foliageColor = gl_Color.rgb;

    gl_Position = ftransform();

    float distanceFromPlayer = length(gl_Position.xy);

    #include "/programs/include/voxelizing.glsl"

    gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);

}