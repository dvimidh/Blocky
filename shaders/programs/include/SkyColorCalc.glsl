float fogify(float x, float w) {
	return clamp(w / (x * x + w), 0.0, 1.0);
}

vec3 calcSkyColor(vec3 pos, vec3 myFogColor, float sunAngle) {



float sunAmount = dot(normalize(pos), normalize(sunPosition));


	vec3 riseColorMore = vec3(RISCOLR, RISCOLG, RISCOLB);
	vec3 SunRiseColor = myFogColor;
	if (sunAngle > 0.00 && sunAngle < 0.025) {
		SunRiseColor = riseColorMore;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		SunRiseColor = mix(riseColorMore, myFogColor, 1/0.05 * (sunAngle - 0.025));
	} 
	if (sunAngle > 0.45 && sunAngle < 0.5) {
		SunRiseColor = mix(myFogColor, riseColorMore, 1/0.05 * (sunAngle-0.45));
	}
	if (sunAngle > 0.50 && sunAngle < 0.55) {
		SunRiseColor = mix(riseColorMore, myFogColor, 1/0.05 * (sunAngle-0.5));
	}
	if ((sunAngle > 0.95 && sunAngle < 1.0) ) {
		SunRiseColor = mix(myFogColor, riseColorMore, 1/0.05 * (sunAngle-0.95));
	}
	myFogColor  = mix(myFogColor,SunRiseColor,max(pow(sunAmount,0.60)/1.1,0.0));



	float upDot = dot(normalize(pos), gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 baseSkyColor = mix(skyColor, myFogColor, clamp(fogify(max(upDot, 0.0), 0.1)+pow(max(sunAmount, 0.0), 2.0)*0.5, 0.0, 1.0));
	baseSkyColor = mix(baseSkyColor, vec3(1.0, 0.65, 0.3), clamp(pow(max(sunAmount, 0.0), 75.0), 0.0, 0.4)*max(upDot, 0.0));
	return baseSkyColor;
}