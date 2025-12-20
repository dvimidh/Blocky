#version 430 compatibility

#include "/programs/settings.glsl"

mat3 generateSimpleTBN(vec3 normal) {
    // Create an arbitrary tangent vector
    vec3 tangent;
    vec3 c1 = cross(normal, vec3(0.0, 0.0, 1.0));
    vec3 c2 = cross(normal, vec3(0.0, 1.0, 0.0));
    
    // Choose the cross product that gives the longer vector
    if (length(c1) > length(c2)) {
        tangent = c1;
    } else {
        tangent = c2;
    }
    
    tangent = normalize(tangent);
    vec3 bitangent = normalize(cross(normal, tangent));
    
    return mat3(tangent, bitangent, normal);
}
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}
uniform float far;
uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform sampler2D dhDepthTex0;
uniform sampler2D normals;
uniform float viewHeight;
uniform float viewWidth;
uniform float rainStrength;
uniform vec3 fogColor;
uniform float sunAngle;
uniform mat4 gbufferModelViewInverse;
uniform mat4 dhProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 shadowLightPosition;
uniform sampler2D specular;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec2 texCoord;
in vec4 tangent;
mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    //for DirectX normal mapping you want to switch the order of these
    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}
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
    //rhoD *= (vec3(1.0)- fresnelReflectance); //energy conservation - light that doesn't reflect adds to diffuse

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

void main() {
        vec4 outputColorData = vec4(pow(blockColor.rgb, vec3(2.2)), blockColor.a);
    
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse)*shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;
    
    vec3 worldTangent = normalize(mat3(gbufferModelViewInverse) * tangent.xyz);
    vec4 normalData = texture(normals, texCoord)*2.0 - 1.0;
    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0-dot(normalData.xy, normalData.xy)));
    mat3 TBN = generateSimpleTBN(worldGeoNormal);
    vec3 normalWorldSpace = TBN * normalNormalSpace;
     vec4 specularData = texture(specular, texCoord);
    float perceptualSmoothness = specularData.r;
    
    float metallic = 0.0;
    
    vec3 reflectance = vec3(0);
    if (specularData.g*255 > 299) {
        metallic = 1.0;
        reflectance = outputColorData.rgb;
    } else {
        reflectance = vec3(specularData.g);
    }
    float roughness = pow(1.0-perceptualSmoothness, 2.0);
    float smoothness = 1-roughness;

    float lightBrightness = clamp(dot(shadowLightDirection,worldGeoNormal), 0.2, 1.0);

    vec3 skyLight = pow(texture(lightmap, vec2(1/32.0,lightMapCoords.y)).rgb, vec3(2.2));

    vec3 blockcolor = vec3(BLOCKCOLR, BLOCKCOLG, BLOCKCOLB);
	
    vec3 blockLight = pow(texture(lightmap, vec2(lightMapCoords.x, 1/32.0)).rgb, vec3(2.2));
    vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
    vec3 dhviewPos = worldPos-cameraPosition;
	float myDistance = length(dhviewPos);
    if (myDistance < far+1) {
        discard;
    }
    vec3 viewDirection = normalize(cameraPosition - worldPos);
    vec3 riseColor = vec3(1.2, 0.65, 0.5);
	vec3 dayColor = vec3(1.0);
	vec3 nightColor = vec3(0.2, 0.3, 0.3);

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
		skyLight  = skyLight*mix(nightColor, riseColor, 1/0.1 * (sunAngle-0.90));
	}

    
    vec3 sunColor = vec3(1.0);
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
     vec3 brdfv = brdf(shadowLightDirection, viewDirection, roughness, normalWorldSpace, outputColorData.rgb, metallic, reflectance);
     vec3 ambientLightDirection = worldGeoNormal;
    vec3 ambientLight = (blockLight/2*(AMBIENT_INTENSITY)*blockcolor + 0.2*skyLight*SKYLIGHT_INTENSITY)*clamp(dot(ambientLightDirection, normalWorldSpace), 0.0, 1.0);

    vec3 outputColor = outputColorData.rgb*ambientLight + SHADOW_INTENSITY*skyLight*sunColor*brdfv;
    float transparency = outputColorData.a;
    if(outputColorData.a < 0.1) {
        discard;
    }

    vec2 fragCoordTex = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    float depth = texture(depthtex0, fragCoordTex).r;

    if (depth != 1.0) {
    discard;
    }

    
    //outputColor;




    outColor0 =vec4(pow(outputColor,vec3(1/2.2)), transparency);
}