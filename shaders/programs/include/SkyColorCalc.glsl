float fogify(float x, float w) {
	return clamp(w / (x * x + w*1/FOG_INTENSITY+clamp(1-FOG_INTENSITY, w*1/FOG_INTENSITY, 0.0)), 0.0, 1.0);
}

vec3 calcSkyColor(vec3 pos, vec3 myFogColor, float sunAngle) {	
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
	myFogColor  = mix(myFogColor,SunRiseColor, max(clamp(pow((sunAmount+0.6)*1.0,1.5)/3.6, 0.0, 1.0) - clamp(abs(1.6*upDot), 0.0, 1.0),0.0)*(1-rainStrength));


	vec3 MyskyColor = skyColor*SkyMult;

	vec3 baseSkyColor = mix(MyskyColor, myFogColor, clamp(fogify(max(upDot/pow(mix(FOG_INTENSITY, RAIN_FOG_INTENSITY, rainStrength) + 100/far, 0.5), 0), 0.1)+pow(max(sunAmount, 0.0), 2.0)*0.2, 0.0, 1.0));
	baseSkyColor = mix(baseSkyColor, vec3(1.4, 0.85, -0.1), clamp(pow(max(sunAmount, 0.0), 100.0)*HALO_STRENGTH, 0.0, 0.4*(1-rainStrength))*max(pow(upDot, 0.4), 0.0));//sun halo
	
	return baseSkyColor;
}	