vec3 fogColorCalc(float sunAngle, float rainStrength) {

    vec3 myFogColor;
	vec3 riseColor = vec3(0.7, 0.4, 0.4);
	vec3 dayColor = vec3(0.5, 0.7, 1.0);
	vec3 nightColor = vec3(0.06, 0.1, 0.15);
	
	if (sunAngle > 0.00 && sunAngle < 0.025) {
		myFogColor = riseColor;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		myFogColor = mix(riseColor, dayColor, 1/0.05 * (sunAngle - 0.025));
	}
	if (sunAngle > 0.075 && sunAngle < 0.45) {
		myFogColor = dayColor;
	}
	if (sunAngle > 0.45 && sunAngle < 0.5) {
		myFogColor = mix(dayColor, riseColor, 1/0.05 * (sunAngle-0.45));
	}
	if (sunAngle > 0.50 && sunAngle < 0.55) {
		myFogColor = mix(riseColor, nightColor, 1/0.05 * (sunAngle-0.5));
	}
	if ((sunAngle > 0.55 && sunAngle < 0.95) ) {
		myFogColor = nightColor;
	}
	if ((sunAngle > 0.95 && sunAngle < 1.0) ) {
		myFogColor = mix(nightColor, riseColor, 1/0.05 * (sunAngle-0.95));
	}
	
	myFogColor = mix(myFogColor, vec3(0.04), max(rainStrength-0.3, 0.0));
    return myFogColor;
}