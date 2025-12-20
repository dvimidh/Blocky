vec3 fogColorCalc(float sunAngle, float rainStrength) {

    vec3 myFogColor;
	vec3 riseColor = vec3(FOGRISECOLR, FOGRISECOLG, FOGRISECOLB)*1.15;
	vec3 dayColor = vec3(FOGDAYCOLR, FOGDAYCOLG, FOGDAYCOLB)*1.15;
	vec3 nightColor = vec3(FOGNIGHTCOLR, FOGNIGHTCOLG, FOGNIGHTCOLB)*1.15;
	
	if (sunAngle > 0.00 && sunAngle < 0.025) {
		myFogColor = riseColor;
	}
	if (sunAngle > 0.025 && sunAngle < 0.075) {
		myFogColor = mix(riseColor, dayColor, 1/0.05 * (sunAngle - 0.025));
	}
	if (sunAngle > 0.075 && sunAngle < 0.45) {
		myFogColor = dayColor;
	}
	if (sunAngle > 0.425 && sunAngle < 0.475) {
		myFogColor = mix(dayColor, riseColor, 1/0.05 * (sunAngle-0.425));
	}
	if (sunAngle > 0.475 && sunAngle < 0.50) {
		myFogColor = riseColor;
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
	
	myFogColor = mix(myFogColor, vec3(1)*(skyColor.r + skyColor.g + skyColor.b + 0.6)/4, max(rainStrength, 0.0));
    return myFogColor;
}