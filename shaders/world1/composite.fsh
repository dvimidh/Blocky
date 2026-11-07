#version 330 compatibility

#include "/programs/settings.glsl"

varying vec2 texCoord;

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
#include "/programs/include/fogColorCalc.glsl"
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

float mixAmount = 1.;
float GetLuminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 tonemapMe3(vec3 color) {
	float exposure = 3.0 + 1.0/sqrt(mix(FOG_INTENSITY, RAIN_FOG_INTENSITY, rainStrength));
	// Apply tonemapping operator here
	color = pow((pow(color, vec3(exposure)))/(1.0+pow(color, vec3(exposure))), vec3(1.0/exposure));
	return color;
}


const vec3 endFogColor = vec3(0.12, 0.08, 0.18);
vec3 myFogColor = endFogColor;
	vec3 applyFog( in vec3  col,  // color of pixel
               in float t,    // distnace to point
               in vec3  ro,   // camera position
               in vec3  rd,   // camera to point vector
			   in float a,    // constant
			   in float b,    // constant
			   in bool sky)   // if pixel is part of the sky
{

    float fogAmount = (a/b) * exp(-(ro.y+0.3)*b) * (1.0-exp(-t*(rd.y+0.3)*b))/(rd.y+0.3);
	float s = 10.0/(FOG_DECAY_END - FOG_DECAY_START);
	float h = (FOG_DECAY_START+FOG_DECAY_END)/2.0;
	float c3 = ro.y;		
	float p3 = ro.y + t*rd.y;
	//fogAmount = t*10*(-log(-pow(2.71828182846,-s*(p3-h))+1)/s - (-log(-pow(2.71828182846,-s*(c3-h))+1)/s))/(p3-c3);	
	float heightDelta = p3 - c3;
	float cameraExp = exp(clamp(-s * (c3 - h), -80.0, 80.0));
	float pointExp = exp(clamp(-s * (p3 - h), -80.0, 80.0));
	float fogProfile;
	if (abs(heightDelta) < 0.001) {
		fogProfile = cameraExp / (1.0 + cameraExp);
	} else {
		fogProfile = abs(
			(log(1.0 + pointExp) - log(1.0 + cameraExp)) /
			(s * heightDelta)
		);
	}
	fogAmount = t * 0.01 * mix(FOG_INTENSITY, RAIN_FOG_INTENSITY, rainStrength) * fogProfile;
	myFogColor = endFogColor;

	if (isEyeInWater == 1) {
		fogAmount = t * 0.02;
		myFogColor = mix(fogColor, vec3(0.0, 0.3, 0.5), 0.5);
		col.r /= 2.5;
		col.g /= 1.5;
		return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.9));
	}
	if (isEyeInWater == 0) {
		return mix(col, myFogColor, clamp(tonemapMe3(vec3(fogAmount * 0.85)).r, 0.0, 1.0));
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
	return col;
}

bool calctransparency = true;
void main() {
	vec3 color = texture2D(colortex0, texCoord).rgb;
	vec4 colorCloud = texture2D(colortex6, texCoord);
	vec3 colorParticles = texture2D(colortex5, texCoord).rgb;
	float Particlestransparency = texture2D(colortex5, texCoord).a;
	float transparency = texture2D(colortex7, texCoord).b;
	float depth = texture2D(depthtex0, texCoord).r;
	float depthT = texture2D(depthtex1, texCoord).r;
	vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;

	#ifdef DISTANT_HORIZONS
	float dhDepth = texture(dhDepthTex0, texCoord).r;
	vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	if (length(dhviewPos) < length(viewPos) && colorCloud.a > 0.01) {
		colorCloud =vec4(0.0);
		calctransparency = false;
	}
#endif
	myFogColor = endFogColor;

  if(depth == 1.0 || !calctransparency) {
    #ifdef DISTANT_HORIZONS
	float dhDepth = texture(dhDepthTex0, texCoord).r;
	vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
	bool ifsky;
	if (dhDepth == 1.0) {
		ifsky = true;
		myFogColor = endFogColor;

	
	}
	else{
		ifsky = false;
	}
	float myDistance = length(dhviewPos);
	vec3 dheyePlayerPos = mat3(gbufferModelViewInverse)*dhviewPos;
	vec3 dhworldPos = dheyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = dhworldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, mix(6*FOG_INTENSITY/1000, 6*RAIN_FOG_INTENSITY/1000, rainStrength), 0.01, ifsky);
	#endif
	#ifndef DISTANT_HORIZONS
	bool ifsky = depth == 1.0;
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = (gbufferModelViewInverse*vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, mix(6.*FOG_INTENSITY/1000., 6.*RAIN_FOG_INTENSITY/1000., rainStrength), 0.01, ifsky);
	
	
	#endif
	
	}  else if(calctransparency) {
	//float dhDepth = texture(dhDepthTex0, texCoord).r;
	bool ifsky = false;
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = (gbufferModelViewInverse*vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, mix(6.*FOG_INTENSITY/1000., 6.*RAIN_FOG_INTENSITY/1000., rainStrength), 0.01, ifsky);
	if (depth < depthT) {
	//if (1<2) {
			if(depthT != 1.0) {
			ifsky = false;
			vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  		vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
			float myDistanceT = length(viewPosT) - myDistance;
			vec3 eyePlayerPosT = (gbufferModelViewInverse*vec4(viewPosT, 1.0)).xyz;
			vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
			vec3 cameraToPointT = worldPosT - worldPos;
			cameraToPointT = normalize(cameraToPointT);
			color.rgb = mix(applyFog(color.rgb, myDistanceT, worldPos, cameraToPointT, mix((6.*FOG_INTENSITY/1000.), (6.*RAIN_FOG_INTENSITY/1000.), rainStrength), 0.01, ifsky), color.rgb, transparency);
			} else {
				#ifdef DISTANT_HORIZONS
				float dhDepth = texture(dhDepthTex0, texCoord).r;
				if (dhDepth == 1.0) {
					ifsky = false;
					vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
	  				vec3 viewPosT = projectAndDivide(dhProjectionInverse, NDCPosT);
					vec3 eyePlayerPosT = (gbufferModelViewInverse*vec4(viewPosT, 1.0)).xyz;
					vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
					vec3 cameraToPointT = worldPosT - worldPos;
					float myDistanceT = length(viewPosT) - length(viewPos);
					cameraToPointT = normalize(cameraToPointT);
					color.rgb = mix(applyFog(color.rgb, myDistanceT, worldPos, cameraToPointT, mix((6.*FOG_INTENSITY/1000.), (6.*RAIN_FOG_INTENSITY/1000.), rainStrength), 0.01, ifsky), color.rgb, transparency);
				}
				else{
					ifsky = false;
					vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
					vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
					float myDistanceD = length(dhviewPos) - length(viewPos);
					vec3 dheyePlayerPos = (gbufferModelViewInverse*vec4(dhviewPos, 1.0)).xyz;
					vec3 dhworldPos = dheyePlayerPos + eyeCameraPosition; 
					vec3 cameraToPoint = dhworldPos - worldPos;
					cameraToPoint = normalize(cameraToPoint);
					color.rgb = mix(applyFog(color.rgb, myDistanceD, dhworldPos, cameraToPoint, mix((6.*FOG_INTENSITY/1000.), (6.*RAIN_FOG_INTENSITY/1000.), rainStrength), 0.01, ifsky), color.rgb, transparency);

				}
				#endif
			}
	}
	
  }
  
    
	#ifndef DISTANT_HORIZONS
#ifdef CHUNK_FADE
	if (depth < 1.0) {

	
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = (gbufferModelViewInverse*vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);


vec3 riseColorMore = vec3(RISCOLR, RISCOLG, RISCOLB);



float fogFactor = clamp(exp(-1.5 * (2.0 - (myDistance / far)*2.)), 0.0, 1.0);


myFogColor = endFogColor;
if (isEyeInWater == 0) {
color.rgb = mix(color.rgb, myFogColor, fogFactor);
if (depth < depthT-0.01) {
vec3 NDCPosT = vec3(texCoord.xy, depthT) * 2.0 - 1.0;
vec3 viewPosT = projectAndDivide(gbufferProjectionInverse, NDCPosT);
vec3 eyePlayerPosT = (gbufferModelViewInverse*vec4(viewPosT, 1.0)).xyz;
vec3 worldPosT = eyePlayerPosT + eyeCameraPosition; 
vec3 cameraToPointT = worldPosT - worldPos;
float myDistanceT = length(viewPosT) - length(viewPos);
cameraToPointT = normalize(cameraToPointT);
float fogFactorT = clamp(exp(-1.5 * (2.0 - (myDistance / far)*2.)), 0.0, 1.0);
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
	color = mix(color, colorParticles, Particlestransparency);
	vec3 baseColor = color;
	float brightness = GetLuminance(baseColor);
	float bloomThreshold = 0.12;
	float bloom = max(brightness - bloomThreshold, 0.0);
	color = baseColor * pow(clamp(bloom, 0.0, 1.0), 5.0) * BLOOM_STRENGTH/2.;
	/*DRAWBUFFERS:01 */
	gl_FragData[0] = vec4(baseColor, 1.0);
	gl_FragData[1] = vec4(color, 1.0);
}
