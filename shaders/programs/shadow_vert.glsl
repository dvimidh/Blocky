#version 330 compatibility

#include "/programs/settings.glsl"
#include "/programs/include/distort.glsl"


uniform sampler2D gtexture;
attribute vec4 at_midBlock;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
attribute vec4 mc_Entity;
uniform float frameTimeCounter;
uniform mat4 shadowModelViewInverse;
uniform int entityId;
uniform int renderStage;
varying vec2 lmcoord;
varying vec2 texCoord;
varying vec3 foliageColor;
varying vec4 mc_EntityOut;

void main() {

    mc_EntityOut = mc_Entity;
    
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    foliageColor = gl_Color.rgb;

    gl_Position = ftransform();

    float distanceFromPlayer = length(gl_Position.xy);

    gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);

}