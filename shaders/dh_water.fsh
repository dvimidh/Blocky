#version 460 compatibility

int dhMaterialId;
#include "/programs/wave.glsl"
#include "/programs/settings.glsl"
vec3 brdf(vec3 lightDir, vec3 viewDir, float roughness, vec3 normal, vec3 albedo, float metallic, vec3 reflectance) {
    //for ease of use
    float alpha = pow(roughness,2);

    vec3 H = normalize(lightDir + viewDir);
    

    //dot products
    float NdotV = clamp(dot(normal, viewDir), 0.001,1.0);
    float NdotL = clamp(dot(normal, lightDir), 0.001,1.0);
    float NdotH = clamp(dot(normal,H), 0.001,1.0);
    float VdotH = clamp(dot(viewDir, H), 0.001,1.0);

    // Fresnel
    vec3 F0 = reflectance;
    vec3 fresnelReflectance = F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0); //Schlick's Approximation

    //phong diffuse
    vec3 rhoD = albedo;
    rhoD *= (vec3(1.0)- fresnelReflectance); //energy conservation - light that doesn't reflect adds to diffuse

    //rhoD *= (1-metallic); //diffuse is 0 for metals

    // Geometric attenuation
    float k = alpha/2;
    float geometry = (NdotL / (NdotL*(1.0-k)+k)) * (NdotV / ((NdotV*(1.0-k)+k)));

    // Distribution of Microfacets
    float lowerTerm = pow(NdotH,2) * (pow(alpha,2) - 1.0) + 1.0;
    float normalDistributionFunctionGGX = pow(alpha,2.0) / (3.14159 * pow(lowerTerm,2.0));

    vec3 phongDiffuse = rhoD; //
    vec3 cookTorrance = (fresnelReflectance*normalDistributionFunctionGGX*geometry)/(4*NdotL*NdotV);
    
    vec3 BRDF = (phongDiffuse+cookTorrance)*NdotL;
   
    vec3 diffFunction = BRDF;
    
    return BRDF;
    
}
uniform sampler2D lightmap;
uniform sampler2D depthtex0;

uniform float viewHeight;
uniform float viewWidth;

uniform vec3 fogColor;
uniform float sunAngle;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightDirection;
uniform vec3 shadowLightPosition;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;

void main() {
    
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse)*shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;

    float lightBrightness = clamp(dot(shadowLightDirection,worldGeoNormal), 0.2, 1.0);

    vec3 skyLight = pow(texture(lightmap, vec2(1/32.0,lightMapCoords.y)).rgb, vec3(2.2));

    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    vec3 riseColor = vec3(1.2, 0.65, 0.5);
	vec3 dayColor = vec3(1.0);
	vec3 nightColor = vec3(0.06, 0.06, 0.6);

    if (sunAngle > 0.00 && sunAngle < 0.025) {
		skyLight = skyLight*riseColor;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		skyLight = skyLight*mix(riseColor, dayColor, 1/0.05 * (sunAngle - 0.025));
	}
	if (sunAngle > 0.075 && sunAngle < 0.45) {
		skyLight = skyLight*dayColor;
	}
	if (sunAngle > 0.45 && sunAngle < 0.5) {
		skyLight = skyLight*mix(dayColor, riseColor, 1/0.05 * (sunAngle-0.45));
	}
	if (sunAngle > 0.50 && sunAngle < 0.55) {
		skyLight = skyLight*mix(riseColor, nightColor, 1/0.05 * (sunAngle-0.5));
	}
	if ((sunAngle > 0.55 && sunAngle < 0.90) ) {
		skyLight = skyLight*nightColor;
	}
	if ((sunAngle > 0.90 && sunAngle < 1.0) ) {
		skyLight  = skyLight*mix(nightColor, riseColor, 1/0.1 * (sunAngle-0.90));;
	}

    
    vec4 outputColorData = pow(blockColor, vec4(2.2));
    vec3 outputColor = outputColorData.rgb*(lightColor*vec3(0.2) + skyLight*vec3(1.0));
    float transparency = outputColorData.a;
    if(outputColorData.a < 0.1) {
        discard;
    }

    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, texCoord).r;

    if (depth != 1.0) {
    discard;
    }
    float distanceFromCamera = distance(vec3(0), viewSpacePosition);

    float maxFogDistance = 2800;

    float minFogDistance = 1500;
    
    outputColor*=lightBrightness;
    #if WATER_STYLE == 1
    
    transparency = transparency * (outputColor.x + outputColor.y + outputColor.z) * WATER_TRANSLUCENCY_MULTIPLIER + 0.1;
    outputColor = vec3(outputColor.r/100, outputColor.g + 0.3, outputColor.b+0.6);
    #endif

    //outputColor += brdf(shadowLightDirection, viewDirection, 0.2 *WATER_ROUGHNESS, normalWorldSpace, outputColor, WATER_SHININESS, WATER_SHININESS);

    //float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance), 0, 1);

    //outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);

    outColor0 =vec4(pow(outputColor,vec3(1/2.2)), transparency);
}