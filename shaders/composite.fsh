#version 460 compatibility

#include "/programs/settings.glsl"
#include "/programs/fogColorCalc.glsl"
in vec2 texCoord;
in vec3 viewSpacePosition;
uniform float frameTimeCounter;
uniform float sunAngle;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform sampler2D colortex0;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D dhDepthTex0;
uniform mat4 dhProjectionInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float rainStrength;
uniform float playerMood;
uniform float constantMood;
uniform int isEyeInWater;
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
float depthT = texture(depthtex1, texCoord).r;
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
	if ((col.r + col.g + col.b)/3 < 1.05) {
		if((col.r + col.g + col.b)/3 > 1.0) {
		myFogColor  = mix(myFogColor, // fog
                           mix(vec3(1.0,0.7,0.4), vec3(1.0,1.0,1.0), ((col.r + col.g + col.b)/3-1.0)*20), // sun
                           pow(sunAmount,1.0)/1);
	} else {
	myFogColor  = mix(myFogColor, // fog
                           vec3(1.2,0.8,0.5), // sun
                           pow(sunAmount,40.0));
	}
	} else {
		myFogColor  = mix(myFogColor, vec3(1.0,1.0,1.0), pow(sunAmount,1.0)/1.0);
	}
	float moonAmount = max( dot(rd, ligm), 0.0 );
	myFogColor  = mix(myFogColor, // fog
                           vec3(1.0,1.0, 1.0), // sun
                           pow(moonAmount,300.0)*0.7);
	}
	vec3 riseColorMore = vec3(0.8, 0.4, 0.2);

	vec3 SunRiseColor = myFogColor;
if ((col.r + col.g + col.b)/3 < 1.01) {
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
	myFogColor  = mix(myFogColor,SunRiseColor,pow(sunAmount,1.50)/1.1);
	}

	if (isEyeInWater == 1) {
		fogAmount = t * 0.02;
		myFogColor = mix(fogColor, vec3(0.0, 0.3, 0.5), 0.5);
		col.r /= 2.5;
		col.g /= 1.5;
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.9));
	}
	if (isEyeInWater == 0) {
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.6));
	}
    if (isEyeInWater == 2) {
		fogAmount = pow(1.1, t)/1.2;
		myFogColor = vec3(0.7, 0.4, 0.1);
		col.b /= 2.5;
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 1.0));
	}
	if (isEyeInWater == 3) {
		fogAmount = pow(1.1, t)/1.5;
		myFogColor = vec3(0.4, 0.45, 0.5) + 0.2;
		col.b /= 2.5;
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 1.0));
	}
}
#include "/programs/fxaa.glsl"

void main() {
	myFogColor = fogColorCalc(sunAngle, rainStrength);
	vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
	vec3 colorCloud = texture2DLod(colortex6, texCoord, 0.0).rgb;
	vec3 colorWater = texture2DLod(colortex7, texCoord, 0.0).rgb;
	
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
	vec3 cameraToPoint = dhworldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
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
	
	//if (depth < depthT) {
	if (1>2) {
			if(depthT != 1.0) {
				
			vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  		vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
			vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
			vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
			vec3 cameraToPointT = worldPosT - worldPos;
			float myDistanceT = length(viewPosT) - length(viewPos);
			cameraToPointT = normalize(cameraToPointT);
			color.rgb = applyFog(color.rgb, myDistanceT, cameraPosition, cameraToPointT, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
			} else {
				float dhDepth = texture(dhDepthTex0, texCoord).r;
				if (dhDepth == 1.0) {
					ifsky = true;
					vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  				vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
					vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
					vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
					vec3 cameraToPointT = worldPosT - worldPos;
					float myDistanceT = length(viewPosT) - length(viewPos);
					cameraToPointT = normalize(cameraToPointT);
					color.rgb = applyFog(color.rgb, myDistanceT, worldPos, cameraToPointT, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);
				}
				else{
					ifsky = false;
					vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
					vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
					float myDistanceD = length(dhviewPos) - length(viewPos);
					vec3 dheyePlayerPos = mat3(gbufferModelViewInverse)*dhviewPos;
					vec3 dhworldPos = dheyePlayerPos + eyeCameraPosition; 
					vec3 cameraToPoint = dhworldPos - worldPos;
					cameraToPoint = normalize(cameraToPoint);
					color.rgb = applyFog(color.rgb, myDistanceD/2, dhworldPos, cameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky);

				}
			}
		if(colorWater.r + colorWater.g + colorWater.b > 0.1) {
			if (isEyeInWater == 0) {
				vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  			vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
				vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
				vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
				vec3 cameraToPointT = worldPosT - worldPos;
				float myDistanceT = length(viewPosT) - length(viewPos);
				cameraToPointT = normalize(cameraToPointT);
				float fogAmount = myDistanceT * 0.02;
				myFogColor = mix(colorWater.rgb, vec3(0.0, 0.3, 0.5), 0.3);
				//color.r /= 1.5;
				//color.g /= 1.25;
				color.rgb = mix(color.rgb, myFogColor, clamp(fogAmount, 0.0, 0.3));
			}	
		}
	}
	
  }
  
    
	#ifndef DISTANT_HORIZONS


#ifdef CHUNK_FADE
if(depth != 1.0 && (colorCloud.r + colorCloud.g + colorCloud.b) < 0.1) {
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse)*viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);

float sunAmount = max( dot(cameraToPoint, sunDirectionEyePlayerPos), 0.0 );
float moonAmount = max( dot(cameraToPoint, moonDirectionEyePlayerPos), 0.0 );
vec3 riseColorMore = vec3(0.8, 0.4, 0.2);
myFogColor = fogColorCalc(sunAngle, rainStrength);
	vec3 SunRiseColor = myFogColor;
if ((color.r + color.g + color.b)/3 < 1.01) {
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
	myFogColor  = mix(myFogColor,SunRiseColor,pow(sunAmount,1.50)/1.1);
	}



float fogFactor = clamp(exp(-5.0 * (1.0 - myDistance / far)), 0.0, 1.0);

if (isEyeInWater == 0) {
color.rgb = mix(color.rgb, mix(fogColor, myFogColor, 0.6), fogFactor);
}
if (isEyeInWater == 1) {
color.rgb = mix(color.rgb, mix(fogColor, mix(fogColor, vec3(0.0, 0.3, 0.5), 0.5), 0.9), fogFactor);
}
}
    #endif
	#endif
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
