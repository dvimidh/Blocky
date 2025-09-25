#version 460 compatibility

layout (rgba16f) uniform image3D cimage1;

uniform sampler2D gtexture;
attribute vec4 at_midBlock;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse;
attribute vec4 mc_Entity;
uniform float frameTimeCounter;
uniform mat4 shadowModelViewInverse;
uniform int entityId;
out vec2 lmcoord;
out vec2 texCoord;
out vec3 foliageColor;


void main() {



    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    foliageColor = gl_Color.rgb;

    #include "/programs/voxelizing.glsl"

    gl_Position = ftransform();

    float distanceFromPlayer = length(gl_Position.xy);

    gl_Position.xy = gl_Position.xy / (0.1+distanceFromPlayer);

}