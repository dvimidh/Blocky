#version 430 compatibility

#include "/programs/settings.glsl"

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
uniform sampler2D colortex5;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D dhDepthTex0;
uniform mat4 dhProjectionInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform float rainStrength;
uniform float playerMood;
uniform float constantMood;
uniform int isEyeInWater;
vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;
vec3 sunDirection = normalize(sunPosition);
vec3 moonDirection = normalize(moonPosition);
vec3 sunDirectionEyePlayerPos = mat3(gbufferModelViewInverse)*sunDirection;
vec3 moonDirectionEyePlayerPos = mat3(gbufferModelViewInverse)*moonDirection;
vec3 sunDirectionWorldPos = sunDirectionEyePlayerPos + cameraPosition;
float mixAmount = 1;
#include "/programs/include/fogColorCalc.glsl"
#include "/programs/include/skyColorCalc.glsl"
float GetLuminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}
vec3 tonemapMe3(vec3 color) {
	float exposure = 1 + sqrt(FOG_INTENSITY);
	// Apply tonemapping operator here
	color = pow((pow(color, vec3(exposure)))/(1+pow(color, vec3(exposure))), vec3(1/exposure));
	return color;
}

	vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
	vec4 colorCloud = texture2DLod(colortex6, texCoord, 0.0);
	vec3 colorParticles = texture2DLod(colortex5, texCoord, 0.0).rgb;
	float Particlestransparency = texture2DLod(colortex5, texCoord, 0.0).a;
	float transparency = texture2DLod(colortex7, texCoord, 0.0).b;
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
	vec3 NDCPosndh = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPosndh = projectAndDivide(gbufferProjectionInverse, NDCPosndh);
	float upDot = dot(normalize(viewPosndh), normalize(gbufferModelView[1].xyz));
	myFogColor  = mix(myFogColor,SunRiseColor, max(clamp(pow((sunAmount+0.5)*1.0,1.5)/3.6, 0.0, 1.0) - clamp(abs(1.6*upDot), 0.0, 1.0) - clamp(100/t, 0.0, 1.0),0.0)*(1-rainStrength));
	
	if (isEyeInWater == 1) {
		fogAmount = t * 0.02;
		myFogColor = mix(fogColor, vec3(0.0, 0.3, 0.5), 0.5);
		col.r /= 2.5;
		col.g /= 1.5;
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.9));
	}
	if (isEyeInWater == 0) {
		if(sky) {
			return col;
		} else {
			return mix( col, myFogColor, clamp(tonemapMe3(vec3(fogAmount*0.9)).r, 0.0, 1.0) );
	}
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

bool calctransparency = true;
void main() {
	#ifdef DISTANT_HORIZONS
	float dhDepth = texture(dhDepthTex0, texCoord).r;
	if (dhDepth < depth && colorCloud.a > 0.01) {
		colorCloud =vec4(0.0);
		calctransparency = false;
	}
#endif
	myFogColor = fogColorCalc(sunAngle, rainStrength);

  if(depth == 1.0 || !calctransparency) {
    #ifdef DISTANT_HORIZONS
	float dhDepth = texture(dhDepthTex0, texCoord).r;

	bool ifsky;
	if (dhDepth == 1.0) {
		ifsky = true;
		myFogColor = fogColorCalc(sunAngle, rainStrength);
		vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  		vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
		myFogColor = calcSkyColor(viewPos, myFogColor, sunAngle);
			float sunAmount = dot(normalize(viewPos), normalize(sunPosition));

	
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
	
	}  else if(calctransparency) {
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
	
	if (depth < depthT) {
	//if (1<2) {
			if(depthT != 1.0) {
			ifsky = false;
			vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  		vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
			float myDistanceT = length(viewPosT) - myDistance;
			vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
			vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
			vec3 cameraToPointT = worldPosT - worldPos;
			cameraToPointT = normalize(cameraToPointT);
			color.rgb = mix(applyFog(color.rgb, myDistanceT, worldPos, cameraToPointT, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky), color.rgb, transparency);
			} else {
				#ifdef DISTANT_HORIZONS
				float dhDepth = texture(dhDepthTex0, texCoord).r;
				if (dhDepth == 1.0) {
					ifsky = true;
					vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  				vec3 viewPosT = projectAndDivide(dhProjectionInverse, NDCPosT);
					vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
					vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
					vec3 cameraToPointT = worldPosT - worldPos;
					float myDistanceT = length(viewPosT) - length(viewPos);
					cameraToPointT = normalize(cameraToPointT);
					color.rgb = mix(applyFog(color.rgb, myDistanceT, worldPos, cameraToPointT, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky), color.rgb, transparency);
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
					color.rgb = mix(applyFog(color.rgb, myDistanceD, dhworldPos, cameraToPoint, sunDirectionEyePlayerPos, moonDirectionEyePlayerPos, 6*FOG_INTENSITY/1000, 0.01, ifsky), color.rgb, transparency);

				}
				#endif
			}
	}
	
  }
  
    
	#ifndef DISTANT_HORIZONS
	if (depth == 1.0) {
		myFogColor = fogColorCalc(sunAngle, rainStrength);
		vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  		vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
		myFogColor = calcSkyColor(viewPos, myFogColor, sunAngle);
			float sunAmount = dot(normalize(viewPos), normalize(sunPosition));

	
	
	}

#ifdef CHUNK_FADE
if(depth != 1.0 && (colorCloud.r + colorCloud.g + colorCloud.b) == 0.0) {
	
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse)*viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);


vec3 riseColorMore = vec3(RISCOLR, RISCOLG, RISCOLB);



float fogFactor = clamp(exp(-5.0 * (1.0 - myDistance / far)), 0.0, 1.0);
myFogColor = fogColorCalc(sunAngle, rainStrength);
	myFogColor = calcSkyColor(viewPos, myFogColor, sunAngle);
if (isEyeInWater == 0) {
color.rgb = mix(color.rgb, myFogColor, fogFactor);
if (depth < depthT-0.01) {
vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
vec3 eyePlayerPosT = mat3(gbufferModelViewInverse)*viewPosT;
vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
vec3 cameraToPointT = worldPosT - worldPos;
float myDistanceT = length(viewPosT) - length(viewPos);
cameraToPointT = normalize(cameraToPointT);
float fogFactorT = clamp(exp(-5.0 * (1.0 - myDistanceT / far)), 0.0, 1.0);
color.rgb = mix(color.rgb, mix(color.rgb, fogColor, fogFactorT), transparency);

}
}
if (isEyeInWater == 1) {
color.rgb = mix(color.rgb, mix(fogColor, mix(fogColor, vec3(0.0, 0.3, 0.5), 0.5), 0.9), fogFactor);
}

}
    #endif
	#endif
	color = mix(color, colorCloud.rgb, colorCloud.a);
	color = mix(color, colorParticles.rgb, Particlestransparency);
	vec3 baseColor = color;
	float brightness = GetLuminance(baseColor);
	float bloomThreshold = 0.8;
	float bloom = max(brightness - bloomThreshold, 0.0);
	color = baseColor * pow(clamp(bloom, 0, 1.0), 5.0) * BLOOM_STRENGTH;
	/*DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(baseColor, 1.0);
	gl_FragData[1] = vec4(color, 1.0);
}
