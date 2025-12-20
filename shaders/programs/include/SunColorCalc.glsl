
vec3 SunColor(float sunAngle, float rainStrength) {
vec3 SunColorTemp;
if (sunAngle < 0.5) {// || sunAngle > 0.98) {
        if (sunAngle > 0.00 && sunAngle < 0.055) {// || sunAngle > 0.98) {
            SunColorTemp = mix(vec3(SUNRISECOLR, SUNRISECOLG, SUNRISECOLB), vec3(SUNDAYCOLR, SUNDAYCOLG, SUNDAYCOLB), 1/0.055 * (sunAngle));
        } else if (sunAngle > 0.445) {
            SunColorTemp = mix(vec3(SUNRISECOLR, SUNRISECOLG, SUNRISECOLB), vec3(SUNDAYCOLR, SUNDAYCOLG, SUNDAYCOLB), 1/0.055 * (0.5 - sunAngle));
        } else {
            SunColorTemp = vec3(SUNDAYCOLR, SUNDAYCOLG, SUNDAYCOLB);
        }
        SunColorTemp = mix(SunColorTemp, vec3(0.2, 0.1, 0.05)*0.4, rainStrength);   
    } else {
        SunColorTemp = 0.3*vec3(SUNNIGHTCOLR, SUNNIGHTCOLG, SUNNIGHTCOLB);
    }
    float sunfade;
    if (sunAngle > 0.47 && sunAngle < 0.5) {
        sunfade = mix(1.0, 0.0, (sunAngle - 0.47)/(0.03));
    } else if (sunAngle < 0.03) {
        sunfade = mix(0.0, 1.0, (sunAngle)/(0.03));
    } else if (sunAngle > 0.5 && sunAngle < 0.53) {
        sunfade = mix(1.0, 0.0, (sunAngle - 0.5)/(0.03));   
    } else {
        sunfade = 1.0;
    }
    return SunColorTemp * sunfade;
}