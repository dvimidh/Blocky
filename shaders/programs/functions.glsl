
#include "/programs/settings.glsl"

//functions
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

vec3 lightingCalculations(vec3 albedo, vec3 sunColor, float EntityID) {
    //light direction
    
    //normal calc
    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;
    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;
    vec4 normalData = texture(normals, texCoord)*2.0 - 1.0;
    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0-dot(normalData.xy, normalData.xy)));
    mat3 TBN = tbnNormalTangent(worldGeoNormal, worldTangent.rgb);
    vec3 normalWorldSpace = TBN * normalNormalSpace;

    //mat data
    vec4 specularData = texture(specular, texCoord);
    float perceptualSmoothness = specularData.r;
    
    float metallic = 0.0;
    
    vec3 reflectance = vec3(0);
    if (specularData.g*255 > 299) {
        metallic = 1.0;
        reflectance = albedo;
    } else {
        reflectance = vec3(specularData.g);
    }
    float roughness = pow(1.0-perceptualSmoothness, 2.0);
    float smoothness = 1-roughness;
    #if WATER_STYLE == 1
    if(abs(EntityID-10006) < 0.5) {
        smoothness = 0.8;
        metallic = 0.8;
        roughness = 0.5;
        reflectance = vec3(0.5);
        albedo = vec3(albedo.r/100, albedo.g + 0.3, albedo.b+0.5);
    }
    #endif
    //space conversion
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;
    vec3 adjustedFragFeetPlayerSpace = fragFeetPlayerSpace + 0.03 * worldGeoNormal;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;
    vec3 fragShadowViewSpace = (shadowModelView * vec4(adjustedFragFeetPlayerSpace, 1.0)).xyz;
    vec4 fragHomogenousSpace = shadowProjection * vec4(fragShadowViewSpace, 1.0);
    vec3 fragShadowNdcSpace = fragHomogenousSpace.xyz/fragHomogenousSpace.w;
    float distanceFromPlayerNDC = length(fragShadowNdcSpace.xy);
    vec3 distortedShadowNdcSpace = vec3(fragShadowNdcSpace.xy / (0.1+distanceFromPlayerNDC), fragShadowNdcSpace.z);
    vec3 fragShadowScreenSpace = distortedShadowNdcSpace*0.5 + 0.5; 

    //directions
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse)*shadowLightPosition);
    vec3 reflectionDirection = reflect(-shadowLightDirection, normalWorldSpace);
    vec3 viewDirection = normalize(cameraPosition - fragWorldSpace);

    //shadow
    float isInShadow = step(fragShadowScreenSpace.z, texture(shadowtex0HW, fragShadowScreenSpace.xyz).r);
    float isInNonColoredShadow = step(fragShadowScreenSpace.z, texture(shadowtex1, fragShadowScreenSpace.xy).r);
    vec3 shadowColor = texture(shadowcolor0, fragShadowScreenSpace.xy).rgb;

    vec3 shadowMultiplier = vec3(1.0);

    if(isInShadow == 0.0) {
        if(isInNonColoredShadow == 0.0) {
            shadowMultiplier = vec3(texture(shadowtex0HW, fragShadowScreenSpace.xyz));
        } else {
            shadowMultiplier = shadowColor;
        }

    }
    //block and sky lighting
    vec3 blockLight = pow(texture(lightmap, vec2(lightMapCoords.x, 1/32.0)).rgb, vec3(2.2));
    vec3 skyLight = pow(texture(lightmap, vec2(1/32.0,lightMapCoords.y)).rgb, vec3(2.2));

    //ambient lighting
    vec3 ambientLightDirection = worldGeoNormal;
    vec3 ambientLight = (blockLight + 0.2*skyLight*SKYLIGHT_INTENSITY)*clamp(dot(ambientLightDirection, normalWorldSpace), 0.0, 1.0);

    //brdf calculations
    vec3 outputColor = (albedo * ambientLight*(1/SHADOW_INTENSITY) + (SHADOW_INTENSITY)*skyLight*shadowMultiplier*sunColor*brdf(shadowLightDirection, viewDirection, roughness, normalWorldSpace, albedo, metallic, reflectance));

    
    return outputColor;

}