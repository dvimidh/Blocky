#version 430 compatibility


 
#include "/programs/settings.glsl"


#ifdef SHADOW
    
//uniforms
uniform sampler2D gtexture;

//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec4 mc_EntityOut;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
 
#endif
void main() {

    #ifdef SHADOW
    
    vec4 outputColorData = texture(gtexture,texCoord);  
    vec3 albedo = pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2));
    float transparency = outputColorData.a;
    if (outputColorData.a < 0.1) {
        discard;
    }
    
    //output color

    outColor0 =vec4(pow(albedo, vec3(1/2.2)), transparency);
    #endif
}