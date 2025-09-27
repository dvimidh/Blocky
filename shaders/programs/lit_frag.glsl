#version 460 compatibility

#include "/programs/fogColorCalc.glsl"

//uniforms  
uniform usampler3D cSampler1;
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
flat in int lightLevel;
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
    float transparency = outputColorData.a;
    float depth = texture(depthtex0, texCoord).r;
    if(transparency < 0.1) {
        discard;
    }

    
    if (sunAngle < 0.5) {// || sunAngle > 0.98) {
        if (sunAngle > 0.00 && sunAngle < 0.055) {// || sunAngle > 0.98) {
            sunColor = mix(vec3(1.0, 0.3, 0.1), vec3(1.0, 0.5, 0.3), 1/0.055 * (sunAngle));
        } else {
            sunColor = vec3(1.0, 0.5, 0.3);
        }
        sunColor = mix(sunColor, vec3(0.2, 0.1, 0.05), rainStrength);
    } else {
        sunColor = vec3(0.6, 0.6, 0.6);
        
    }   
    if (sunAngle > 0.0 && sunAngle < 0.01) {
    sunColor = sunColor*mix(0, 1, 100 * (sunAngle));
    }
    if (sunAngle-0.5 > 0.0 && sunAngle-0.5 < 0.01) {
    sunColor = sunColor*mix(0, 1, 100 * (sunAngle-0.5));
    }
    if (0.5-sunAngle > 0.0 && 0.5-sunAngle < 0.01) {
    sunColor = sunColor*mix(0, 1, 100 * (0.5-sunAngle));
    }
    if (1.0-sunAngle > 0.0 && 1.0-sunAngle < 0.01) {
    sunColor = sunColor*mix(0, 1, 100 * (1.0-sunAngle));
    }
    
    
    #if WATER_STYLE == 1
    if (abs(EntityID-10006) < 0.5) {
        transparency = transparency * (albedo.x + albedo.y + albedo.z) * WATER_TRANSLUCENCY_MULTIPLIER;
    }
    #endif


    if (abs(EntityID-10010) < 0.5) {
    

/*

    if (max(max(albedo.r, albedo.g), albedo.b) > 0.4 && max(max(albedo.r, albedo.g), albedo.b) < 0.5) {
       albedo.rgb = mix(albedo.rgb, albedo.rgb*2.0, (max(max(albedo.r, albedo.g), albedo.b)-0.4)*(1/0.1));
    } else {
    if (max(max(albedo.r, albedo.g), albedo.b) > 0.5) {
       albedo.rgb = albedo.rgb*2.0;
    }else {
    
    if (max(max(albedo.r, albedo.g), albedo.b) > 0.9) {
       albedo.rgb = albedo.rgb*2.5;
    }
    }
    }
    
    */
    albedo.rgb = albedo.rgb*3;
}


    vec4 outputColor = lightingCalculations(albedo, sunColor, EntityID, sunAngle, worldTime, transparency, ao);
    if (abs(EntityID-10005) < 0.5) {
    outputColor.rgb += vec3(2.0, 2.0, 2.0)*albedo*1.8 + 5.5*albedo.b;
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
float albedoMax = max(albedo.r, max(albedo.g, albedo.b));

vec3 nomax = outputColor.rgb = outputColor.rgb * (0.7 + (abs(0.4 - pow(albedoMax, 0.5)))/4)*0.3;
vec3 yesmax = outputColor.rgb * max((0.7 + (abs(0.4 - pow(max(albedo.r, max(albedo.g, albedo.b)), 0.5)))/2)*0.8, 1.0);

        if (albedoMax > 0.8) {
          outputColor.rgb = mix(nomax, yesmax, albedoMax*5 - 4);
        }else {
       outputColor.rgb = yesmax;
        }
    }



    outColor0 = vec4(pow(outputColor.rgb, vec3(1/2.2)), transparency);
    //outColor0 = vec4(1.0);
    outColor1 = vec4(storeWater, transparency);

}
