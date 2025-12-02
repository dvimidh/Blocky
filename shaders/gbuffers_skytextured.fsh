#version 430 compatibility

#include "/programs/settings.glsl"

//uniforms
uniform sampler2D gtexture;

//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec3 viewpos;

uniform mat4 gbufferModelView;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
 

void main() {

    float upDot = dot(normalize(viewpos), gbufferModelView[1].xyz); 

    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2));
    float transparency = outputColorData.a;


    if(outputColorData.a < 0.1) {
        discard;
    }
    transparency = transparency*clamp(mix(0.0, 1.0, clamp(upDot+0.15, 0.0, 1.0)), 0.0, 1.0);
    //output color

    outColor0 =vec4(pow(albedo*1.0, vec3(1/2.2)), transparency);
}
    