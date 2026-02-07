
vec3 increaseSaturation(vec3 rgb, float adjustment) {
    const vec3 W = vec3(0.3333333, 0.3333333, 0.3333333); // Luminance weights
    vec3 intensity = vec3(dot(rgb, W)); // Calculate luminance (grayscale)
    return mix(intensity, rgb, adjustment); // Interpolate between grayscale and original color
}
vec3 calcSkyColor(vec3 pos, vec3 myFogColor, float sunAngle, float HaloMult) {	
pos = normalize(pos);

float upDot = dot(normalize(pos), gbufferModelView[1].xyz);
float sunAmount = dot(normalize(pos), normalize(sunPosition)); 
	vec3 dayMult = vec3(SKYDAYCOLR, SKYDAYCOLG, SKYDAYCOLB);
	vec3 nightMult = vec3(SKYNIGHTCOLR, SKYNIGHTCOLG, SKYNIGHTCOLB);
	vec3 RiseMult = vec3(SKYRISECOLR, SKYRISECOLG, SKYRISECOLB);
	vec3 SkyMult;
	vec3 riseColorMore = vec3(RISCOLR, RISCOLG, RISCOLB);
	vec3 SunRiseColor = myFogColor;
	if (sunAngle > 0.00 && sunAngle < 0.025) {
		SunRiseColor = riseColorMore;
		SkyMult = RiseMult;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		SunRiseColor = mix(riseColorMore, myFogColor, 1/0.05 * (sunAngle - 0.025));
	} 	SkyMult = mix(RiseMult, dayMult, 1/0.05 * (sunAngle - 0.025));
	if (sunAngle >0.075 && sunAngle < 0.0425) {
		SkyMult = dayMult;
	}
	if (sunAngle > 0.425 && sunAngle < 0.475) {
		SunRiseColor = mix(myFogColor, riseColorMore, 1/0.05 * (sunAngle-0.425));
		SkyMult = mix(dayMult, RiseMult, 1/0.05 * (sunAngle-0.425));
	}
	if (sunAngle > 0.475 && sunAngle < 0.50) {
		SunRiseColor = riseColorMore;
		SkyMult = RiseMult;
	}
	if (sunAngle > 0.50 && sunAngle < 0.55) {
		SunRiseColor = mix(riseColorMore, myFogColor, 1/0.05 * (sunAngle-0.5));
		SkyMult = mix(RiseMult, nightMult, 1/0.05 * (sunAngle-0.5));
	}
	if (sunAngle > 0.55 && sunAngle < 0.95) {
		SkyMult = nightMult;
	}
	if ((sunAngle > 0.95 && sunAngle < 1.0) ) {
		SunRiseColor = mix(myFogColor, riseColorMore, 1/0.05 * (sunAngle-0.95));
		SkyMult = mix(nightMult, RiseMult, 1/0.05 * (sunAngle-0.95));
	}
	myFogColor  = mix(myFogColor,SunRiseColor, max(clamp(pow((sunAmount+0.6)*1.0,1.5)/3.6, 0.0, 1.0) - clamp(abs(0.6*upDot)+upDot, 0.0, 1.0),0.0)*(1-rainStrength));


	vec3 MyskyColor = skyColor*SkyMult;
	float myFar = far;
	#ifdef CHUNK_FADE
	#ifdef DISTANT_HORIZONS
	myFar = 100000000.0;
	#endif
	#endif
	vec3 baseSkyColor = mix(MyskyColor, myFogColor,clamp(1 - upDot*2 + 100/(myFar + 500.0) + 0.4*mix(FOG_INTENSITY, RAIN_FOG_INTENSITY, rainStrength), 0.0, 1.0));
	baseSkyColor = mix(baseSkyColor, vec3(1.4, 0.85, -0.1), clamp(pow(max(sunAmount, 0.0), 100.0)*HALO_STRENGTH* HaloMult, 0.0, 0.4*(1-rainStrength))*max(pow(upDot, 0.4), 0.0));//sun halo
	
	return increaseSaturation(baseSkyColor, SKY_SATURATION);
}	