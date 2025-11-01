#version 430


#include "/programs/settings.glsl"

//uniforms
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular; 
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2DShadow shadowtex0HW;
uniform usampler3D cSampler1;
uniform usampler3D cSampler2;
uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrixInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform int worldTime;
uniform float far;
uniform float dhNearPlane;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform float sunAngle;
uniform float viewHeight;
uniform float viewWidth;
uniform float rainStrength;
//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;
in float ao;
in vec3 foot_pos;
uniform vec4 entityColor;
vec3 sunColor = vec3(1);
/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
#include "/programs/wave.glsl"
#include "/programs/functions.glsl"
#include "/programs/SunColorCalc.glsl"
void main() {

    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = mix(pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2)), entityColor.rgb, entityColor.a);
    float transparency = outputColorData.a;

    if(transparency < 0.1) {
        discard;
    }

    
    sunColor = SunColor(sunAngle, rainStrength);
    vec4 outputColor = lightingCalculations(albedo, sunColor, -1.0, sunAngle, worldTime, transparency, ao);

    float distanceFromCamera = distance(viewSpacePosition, vec3(0));
    float dhBlend = smoothstep(far-.5*far, far, distanceFromCamera);
    transparency = outputColor.a;
    //outColor0 = gbufferModelViewInverse*tangent;
    //outColor0 = gbufferModelViewInverse*vec4(geoNormal, 1.0);
    outColor0 =vec4(pow(outputColor.rgb,vec3(1/2.2)), transparency*ao);
}
