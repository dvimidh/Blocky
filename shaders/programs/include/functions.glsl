



uniform mat4 gbufferModelView;


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

vec3 brdfg(vec3 lightDir, vec3 viewDir, float roughness, vec3 normal, vec3 albedo, float metallic, vec3 reflectance) {
    //for ease of use
    float alpha = pow(roughness,2);

    vec3 H = normalize(lightDir + viewDir);
    

    //dot products
    float NdotV = clamp(dot(normal, viewDir), 0.001,1.0);
    float NdotL = clamp(dot(normal, lightDir), 0.001,1.0);
    if (abs(EntityID - 10008) < 0.5) {
        NdotL = clamp(NdotL, 0.6,1.0);
    }
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

vec4 lightingCalculations(vec3 albedo, vec3 sunColor, float EntityID, float sunAngle, int worldTime, float transparency, float ao) {
    //light direction
    //sunColor = sunColor * 1.5;
    //normal calc
    vec3 worldGeoNormal = normalize(mat3(gbufferModelViewInverse) * geoNormal);
    vec3 worldTangent = normalize(mat3(gbufferModelViewInverse) * tangent.xyz);
    

    if (abs(EntityID-10006) < 0.5) {
        vec3 worldPos = (gbufferModelViewInverse * vec4(viewSpacePosition.xyz, 1)).xyz + cameraPosition;
        worldPos = wave(worldPos, worldTime);
        
        vec3 beforebitangent = normalize(cross(worldTangent, worldGeoNormal));
        vec3 worldPost = worldPos + normalize(worldTangent)*0.5;
        vec3 worldPosb = worldPos + beforebitangent*0.5;
        
        vec3 neighbor1 = wave(worldPost, worldTime);
        

        vec3 neighbor2 = wave(worldPosb, worldTime);
        
        vec3 nonbitangent = neighbor1 - worldPos;
        vec3 bitangent = neighbor2 - worldPos;
        
        worldGeoNormal = normalize(cross(bitangent, nonbitangent));
        worldTangent = nonbitangent;
    }
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
        smoothness = 0.9;
        metallic = 0.01;
        roughness = 0.05 * WATER_ROUGHNESS*(0.1 + 5 * pow((albedo.r + albedo.g + albedo.b)/3.0+ 0.8, 2.0));
        reflectance = vec3(WATER_SHININESS * 0.25);
        albedo = vec3(albedo.r/10, clamp(albedo.g*1.3, 0.0, 0.2), clamp(albedo.b*1.5, 0.0, 0.4));
    }
    #endif
    //space conversion
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;
    vec3 fragFeetPlayerSpaceBackup = fragFeetPlayerSpace;
    #ifdef PIXEL_LOCKED_SHADOWS
    vec3 fragWorldUnrounded = fragWorldSpace;
    fragWorldSpace = (floor(fragWorldSpace * 16.0 + 0.01) + 0.5) / 16.0;
    fragFeetPlayerSpace = fragWorldSpace - cameraPosition;
    
    #endif
    vec3 adjustedFragFeetPlayerSpace = fragFeetPlayerSpace + 0.06*worldGeoNormal;
    vec3 fragShadowViewSpace = (shadowModelView * vec4(adjustedFragFeetPlayerSpace, 1.0)).xyz;
    vec4 fragHomogenousSpace = shadowProjection * vec4(fragShadowViewSpace, 1.0);
    vec3 fragShadowNdcSpace = fragHomogenousSpace.xyz/fragHomogenousSpace.w;
    float distanceFromPlayerNDC = length(fragShadowNdcSpace.xy);
    vec3 distortedShadowNdcSpace = vec3(fragShadowNdcSpace.xy / ((0.1+distanceFromPlayerNDC)), fragShadowNdcSpace.z);
    vec3 fragShadowScreenSpace = distortedShadowNdcSpace*0.5 + 0.5; 
    
    
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
            #ifndef SHADOW_FILTERING
            shadowMultiplier = vec3(0);
            #endif
            #ifdef SHADOW_FILTERING
            shadowMultiplier = vec3(texture(shadowtex0HW, fragShadowScreenSpace.xyz));
            #endif
        } else {
            shadowMultiplier = shadowColor;
        }

    }

    if(abs(EntityID - 10008) < 0.5 && abs(fragShadowScreenSpace.z - texture(shadowtex1, fragShadowScreenSpace.xy).r) < 0.003) {
        shadowMultiplier = vec3(1.0);
    }
    //block and sky lighting
    vec3 blockLight = pow(texture(lightmap, vec2(lightMapCoords.x, 1/32.0)).rgb, vec3(2.2));
    vec3 skyLight = pow(texture(lightmap, vec2(1/32.0,lightMapCoords.y)).rgb, vec3(2.2));
    vec3 riseColor = vec3(AMBRISECOLR, AMBRISECOLG, AMBRISECOLB);
	vec3 dayColor = vec3(AMBDAYCOLR, AMBDAYCOLG, AMBDAYCOLB);
	vec3 nightColor = vec3(AMBNIGHTCOLR, AMBNIGHTCOLG, AMBNIGHTCOLB);
	
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
    skyLight = skyLight * 1.5;
    //Voxel Data (I hope)
    //vec3 voxel_pos_unrounded = fragFeetPlayerSpaceBackup-normalize(normalWorldSpace)*0.05 + fract(cameraPosition) + VOXEL_AREA/2;
    ivec3 voxel_pos = ivec3(fragFeetPlayerSpaceBackup-normalize(normalWorldSpace)*0.05 + fract(cameraPosition) + VOXEL_AREA/2);
    //if(fract(voxel_pos_unrounded.x) < 0.05 || fract(voxel_pos_unrounded.x) > 0.95) {
        //voxel_pos.x = /*int(voxel_pos.x - normalize(normalWorldSpace).x);*/ int(voxel_pos.x+1);
    //}
    vec4 bytes = unpackUnorm4x8(texture3D(cSampler2, vec3(voxel_pos)/vec3(VOXEL_AREA)).r);
    
    //ambient lighting
    vec3 ambientLightDirection = vec3(0.0, 1.0, 0.0);
    vec3 ambientLight;
    vec3 brdfv;
    if(abs(EntityID - 10008) < 0.5 && abs(fragShadowScreenSpace.z - texture(shadowtex1, fragShadowScreenSpace.xy).r) < 0.5) {
        brdfv = brdfg(shadowLightDirection, viewDirection, roughness, normalWorldSpace, albedo, metallic, reflectance);
    } else {
        brdfv = brdf(shadowLightDirection, viewDirection, roughness, normalWorldSpace, albedo, metallic, reflectance);
    }
    
   
    
    ambientLight = (blockLight/2*(AMBIENT_INTENSITY) + 0.2*skyLight*SKYLIGHT_INTENSITY)*clamp(dot(ambientLightDirection, normalWorldSpace), 0.7, 1.0);
    
    vec3 outputColor =vec3(0);

    #if WATER_STYLE == 1
    if(abs(EntityID-10006) < 0.5) {




    

     if ((brdfv.r + brdfv.g + brdfv.b)/3 < 1.0) {
        //brdf = min(brdf, brdf/5000);
     } 
     if ((brdfv.r + brdfv.g + brdfv.b)/3*(shadowMultiplier.r + shadowMultiplier.b + shadowMultiplier.g)/3 > 0.9 && transparency > 0.1) {
        
        sunColor=sunColor*5.4;
        sunColor = clamp(sunColor, vec3(0.0), vec3(1.4));
        transparency += clamp(1 + (max(((brdfv.r + brdfv.g + brdfv.b)/3 - 0.9)*(shadowMultiplier.r + shadowMultiplier.b + shadowMultiplier.g)/3, 0.0)), 1.9, 2.5);
        brdfv = clamp(brdfv, vec3(0.0), vec3(1.0));
     }
     //transparency += clamp(min((brdfv.r + brdfv.g + brdfv.b)/2, 0.3) + (max((brdfv.r + brdfv.g + brdfv.b)/2-0.4, 0.0))*(shadowMultiplier.r + shadowMultiplier.g + shadowMultiplier.b)/3, 0.0, 1.0);

     outputColor = (albedo * ambientLight*pow(ao, 2.0) + (SHADOW_INTENSITY)*shadowMultiplier*sunColor*brdfv*pow(ao, 2.0));
    } else{
        outputColor = (albedo * ambientLight*pow(ao, 2.0) + (SHADOW_INTENSITY)*shadowMultiplier*sunColor*brdfv*pow(ao, 2.0));
    }
    #endif 
    #if WATER_STYLE != 1
    
    outputColor = (albedo * ambientLight*pow(ao, 2.0) + (SHADOW_INTENSITY)*shadowMultiplier*sunColor*brdfv*pow(ao, 2.0));
    
    #endif
    //return vec4(outputColor*pow(ao, 2.0), transparency);
    //if (clamp(voxel_pos, ivec3(0), ivec3(VOXEL_AREA)) == voxel_pos) {  
      //  return vec4(bytes.rgb, transparency);
    //} else {
        return vec4(vec3(outputColor), transparency);
    //}
}

