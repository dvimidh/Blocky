
vec3 SunColor(float sunAngle, float rainStrength) {
vec3 SunColorTemp;
if (sunAngle < 0.5) {// || sunAngle > 0.98) {
        if (sunAngle > 0.00 && sunAngle < 0.055) {// || sunAngle > 0.98) {
            SunColorTemp = mix(vec3(SUNRISECOLR, SUNRISECOLG, SUNRISECOLB), vec3(SUNDAYCOLR, SUNDAYCOLG, SUNDAYCOLB), 1/0.055 * (sunAngle));
        } else {
            SunColorTemp = vec3(SUNDAYCOLR, SUNDAYCOLG, SUNDAYCOLB);
        }
        SunColorTemp = mix(SunColorTemp, vec3(0.2, 0.1, 0.05), rainStrength);
    } else {
        SunColorTemp = vec3(SUNNIGHTCOLR, SUNNIGHTCOLG, SUNNIGHTCOLB);
    }
    return SunColorTemp;
}