#version 460 compatibility



out vec2 texCoord;
out vec3 foliageColor;


void main() {



    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    foliageColor = gl_Color.rgb;

    gl_Position = ftransform();

    float distanceFromPlayer = length(gl_Position.xy);

    gl_Position.xy = gl_Position.xy / (0.1+distanceFromPlayer);

}