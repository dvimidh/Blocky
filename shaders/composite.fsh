#version 460 compatibility

#include "/programs/settings.glsl"

in vec2 texCoord;
in vec3 viewSpacePosition;
uniform float frameTimeCounter;
uniform float sunAngle;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D dhDepthTex0;
uniform mat4 dhProjectionInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float rainStrength;
uniform float playerMood;
uniform float constantMood;
vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;
vec3 sunDirection = 0.01 * sunPosition;
vec3 moonDirection = 0.01 * moonPosition;
vec3 sunDirectionEyePlayerPos = mat3(gbufferModelViewInverse)*sunDirection;
vec3 moonDirectionEyePlayerPos = mat3(gbufferModelViewInverse)*moonDirection;
vec3 sunDirectionWorldPos = sunDirectionEyePlayerPos + cameraPosition;
float mixAmount = 1;
float GetLuminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}


vec3 myFogColor = vec3(0);
float depth = texture(depthtex0, texCoord).r;
vec3 applyFog( in vec3  col,  // color of pixel
               in float t,    // distnace to point
               in vec3  ro,   // camera position
               in vec3  rd,   // camera to point vector
			   in vec3  lig,  // sun direction
			   in vec3 ligm,  // moon direction
			   in float a,    // constant
			   in float b,    // constant
			   in bool sky)   // if pixel is part of the sky
{
    float fogAmount = (a/b) * exp(-(ro.y+0.3)*b) * (1.0-exp(-t*(rd.y+0.3)*b))/(rd.y+0.3);
	
	//if(sky) 
	float sunAmount = max( dot(rd, lig), 0.0 );
	if(sky) {
		fogAmount = 1005 + fogAmount;
	if ((col.r + col.g + col.b)/3 < 0.99) {
		if((col.r + col.g + col.b)/3 > 0.94) {
		myFogColor  = mix(myFogColor, // fog
                           mix(vec3(1.0,0.7,0.4), vec3(1.7,1.7,1.7), ((col.r + col.g + col.b)/3-0.94)*20), // sun
                           pow(sunAmount,1.0));
	} else {
	myFogColor  = mix(myFogColor, // fog
                           vec3(1.0,0.7,0.4), // sun
                           pow(sunAmount,75.0));
	}
	} else {
		myFogColor  = mix(myFogColor, // fog
                           vec3(1.7,1.7,1.7), // sun
                           pow(sunAmount,1.0));
	}
	float moonAmount = max( dot(rd, ligm), 0.0 );
	myFogColor  = mix(myFogColor, // fog
                           vec3(1.0,1.0, 1.0), // sun
                           pow(moonAmount,300.0)*0.7);
	}
    return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.6));
}
#include "/programs/fxaa.glsl"

void main() {
	vec3 SunFogColor;
	vec3 riseColor = vec3(1.0, 0.45, 0.3);
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
	vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
	
	#ifdef FXAA
	color = FXAA311(color);	
	#endif
	
	
	
  if(depth == 1.0){
    #ifdef DISTANT_HORIZONS
	float dhDepth = texture(dhDepthTex0, texCoord).r;

	bool ifsky;
	if (dhDepth == 1.0) {
		ifsky = true;
	}
	else{
		ifsky = false;
	}
	vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
	float myDistance = length(dhviewPos);
	vec3 dheyePlayerPos = mat3(gbufferModelViewInverse)*dhviewPos;
	vec3 dhworldPos = dheyePlayerPos + eyeCameraPosition; 
	vec3 dhcameraToPoint = dhworldPos - cameraPosition;
	dhcameraToPoint = normalize(dhcameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, dhcameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
	#endif
	#ifndef DISTANT_HORIZONS
	bool ifsky = true;
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse)*viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
	#endif
	
	}  else {
	//float dhDepth = texture(dhDepthTex0, texCoord).r;
	bool ifsky = false;
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse)*viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
  }
  
    vec3 baseColor = color;
	if (color.r > 0.05) { 
		color.r *= 5.0;
	}
	float Brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	if (Brightness <0.0) { 
		color = vec3(0);
	}
	 if (color.r > 0.05) {
	 color.r /= 5;
	}
	
	/*DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(baseColor, 1.0);
	gl_FragData[1] = vec4(color, 1.0);
}
