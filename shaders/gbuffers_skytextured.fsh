#version 430 compatibility

#include "/programs/settings.glsl"

//uniforms
uniform sampler2D gtexture;

//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec3 viewpos;
uniform float rainStrength;
uniform mat4 gbufferModelView;
uniform float sunAngle;
uniform vec3 sunPosition;
float sunAmount = dot(normalize(viewpos), normalize(sunPosition));

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
 

void main() {

    float upDot = dot(normalize(viewpos), gbufferModelView[1].xyz); 

    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = pow(clamp(outputColorData.rgb, 0.0, 1.0),vec3(2.2)) * pow(clamp(foliageColor, 0.0, 1.0),vec3(2.2));
    float transparency = clamp(outputColorData.a, 0.0, 1.0);


    if(outputColorData.a < 0.01) {
        discard;
    }   
    transparency = transparency*clamp(mix(0.0, 1.0, clamp(upDot+0.15, 0.0, 1.0)), 0.0, 1.0);
    //output color
    if (sunAmount < 0.0) {
        albedo *= 2;
    }
    if (sunAmount > 0.0) {
        albedo *= (1.0 + 1-sunAmount)*vec3(1.7, 0.5, 0.1);
    }
    if(sunAmount > 0) {
        albedo *= (1.0 + 3-upDot*3);
    }
    outColor0 =vec4(pow(albedo*1.0, vec3(1/2.2)), transparency*(1-rainStrength*0.8));
}
    