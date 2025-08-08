#version 460




//uniforms
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2DShadow shadowtex0HW;

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
uniform vec4 entityColor;
vec3 sunColor = vec3(1);
/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
#include "/programs/wave.glsl"
#include "/programs/functions.glsl"

void main() {

    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = mix(pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2)), entityColor.rgb, entityColor.a);
    float transparency = outputColorData.a;

    if(transparency < 0.1) {
        discard;
    }

    
    if (sunAngle < 0.5) {// || sunAngle > 0.98) {
        if (sunAngle > 0.00 && sunAngle < 0.055) {// || sunAngle > 0.98) {
            sunColor = mix(vec3(1.0, 0.2, 0.01), vec3(1.0, 0.5, 0.3), 1/0.055 * (sunAngle));
        } else {
            sunColor = vec3(1.0, 0.5, 0.3);
        }
        sunColor = mix(sunColor, vec3(0.2, 0.1, 0.05), rainStrength);
    } else {
        sunColor = vec3(0.3, 0.3, 0.3);
    }
    vec3 outputColor = lightingCalculations(albedo, sunColor, -1.0, sunAngle, worldTime);

    float distanceFromCamera = distance(viewSpacePosition, vec3(0));
    float dhBlend = smoothstep(far-.5*far, far, distanceFromCamera);
    transparency = mix(0.0, transparency, pow((1-dhBlend), .6));
    outColor0 =vec4(pow(outputColor,vec3(1/2.2)), transparency);
}
