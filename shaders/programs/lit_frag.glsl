#version 430 compatibility

#include "/programs/settings.glsl"
#include "/programs/fogColorCalc.glsl"
#include "/programs/SunColorCalc.glsl"

//uniforms  
uniform usampler3D cSampler1;
uniform usampler3D cSampler2;
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D depthtex0;
uniform sampler2DShadow shadowtex0HW;
uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrixInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform float dhNearPlane;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform vec3 skyColor;
uniform float sunAngle;
uniform float viewHeight;
uniform float viewWidth;
uniform float rainStrength;
uniform int worldTime;
//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;
in float EntityID;
in float ao;
in float lightLevel;
in vec3 foot_pos;
vec3 sunColor = vec3(1);
vec3 storeWater;
 vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}
/* DRAWBUFFERS:07 */
layout(location = 0) out vec4 outColor0;
layout(location = 1) out vec4 outColor1;
#include "/programs/wave.glsl"
#include "/programs/functions.glsl"

void main() {
    
    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2));
    #ifndef WATER_TEXTURE
    if (abs(EntityID-10006) < 0.5) {
        albedo = foliageColor/4.4 + vec3(0.1, 0.0, 0.1);
    }
    #endif
    float transparency = outputColorData.a;
    float depth = texture(depthtex0, texCoord).r;
    if(transparency < 0.1) {
        discard;
    }

    
    sunColor = SunColor(sunAngle, rainStrength);
    
    
    #if WATER_STYLE == 1
    if (abs(EntityID-10006) < 0.5) {
        transparency = clamp(transparency * (albedo.x + albedo.y + albedo.z) * WATER_TRANSLUCENCY_MULTIPLIER, 0.2, 1.0);
    }
    #endif

    
    vec3 emmissive = vec3(0.0);
    if (abs(EntityID-10010) < 0.5) {    
    
    //albedo.rgb *= 0.2*(7 - (mix(max(albedo.r, max(albedo.g, albedo.b))*1.5, (albedo.r + albedo.g + albedo.b)/2.0, 0.5)));
    emmissive = albedo * 2*(max(albedo.r, max(albedo.g, albedo.b)) - (albedo.r + albedo.g + albedo.b)/4);

    }


    vec4 outputColor = lightingCalculations(albedo, sunColor, EntityID, sunAngle, worldTime, transparency, ao);
    if (abs(EntityID-10005) < 0.5) {
    outputColor.rgb += vec3 (2.0, 2.0, 2.0)*albedo*1.8 + 5.5*albedo.b;
    }
    transparency = outputColor.a;
    #if WATER_STYLE == 1
    if (abs(EntityID-10006) < 0.5) {
        outputColor.rgb = clamp(outputColor.rgb, 0.0, 1.2);
    }
    #endif
    if (transparency<0.9) {
        
        storeWater = outputColor.rgb;
        
    } else {
        storeWater = vec3(0.0);
    }
    if (abs(EntityID-10010) < 0.5) {
//outputColor.rgb = 20.5*smoothstep(outputColor.rgb, vec3(0.0), vec3(20.5));
    }
    //outputColor.rgb = clamp(outputColor.rgb * (1.5-(15/10)), vec3(0.0), vec3(1.0));

    //outputColor = lightingCalculations(albedo, sunColor, EntityID, sunAngle, worldTime, transparency, ao);
    outColor0 = vec4(pow(outputColor.rgb + emmissive/2, vec3(1/2.2)), transparency);
    
    //outColor0 = vec4(1.0);
    outColor1 = vec4(storeWater, transparency);

}
