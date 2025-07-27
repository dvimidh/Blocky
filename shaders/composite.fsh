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
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D dhDepthTex0;
uniform mat4 dhProjectionInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform float rainStrength;
vec3 eyeCameraPosition = cameraPosition + gbufferModelViewInverse[3].xyz;

vec3 sunDirection = 0.01 * sunPosition;
vec3 sunDirectionEyePlayerPos = mat3(gbufferModelViewInverse)*sunDirection;
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

vec3 applyFog( in vec3  col,  // color of pixel
               in float t,    // distnace to point
               in vec3  ro,   // camera position
               in vec3  rd,   // camera to point vector
			   in vec3  lig,  // sun direction
			   in float a,
			   in float b)
{
    float fogAmount = (a/b) * exp(-(ro.y+0.3)*b) * (1.0-exp(-t*(rd.y+0.3)*b))/(rd.y+0.3);
	float sunAmount = max( dot(rd, lig), 0.0 );
	vec3  myFogColor  = mix(myFogColor, // blue
                           vec3(1.0,0.6,0.5), // sun
                           pow(sunAmount,2.0)/2 * 0.5);
    return mix( col, myFogColor, clamp(fogAmount, 0.0, 0.7));
}
#include "/programs/fxaa.glsl"

void main() {
	
	vec3 riseColor = vec3(1.0, 0.45, 0.3);
	vec3 dayColor = vec3(0.5, 0.7, 1.0);
	vec3 nightColor = vec3(0.06, 0.06, 0.1);
	
	if (sunAngle > 0.00 && sunAngle < 0.055) {
		myFogColor = mix(riseColor, dayColor, 1/0.055 * (sunAngle));
	}
	if (sunAngle > 0.055 && sunAngle < 0.45) {
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
		myFogColor = myFogColor = mix(nightColor, riseColor, 1/0.05 * (sunAngle-0.95));;
	}
	myFogColor = mix(myFogColor, vec3(0.1), rainStrength);
	vec3 color = texture2DLod(colortex0, texCoord, 0.0).rgb;
	
	#ifdef FXAA
	color = FXAA311(color);	
	#endif
	float depth = texture(depthtex0, texCoord).r;
	
	
  if(depth == 1.0){
    
	float dhDepth = texture(dhDepthTex0, texCoord).r;
	if(dhDepth == 1.0){

	}{
	vec3 dhNDCPos = vec3(texCoord.xy, dhDepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);
	float myDistance = length(dhviewPos);
	vec3 dheyePlayerPos = mat3(gbufferModelViewInverse)*dhviewPos;
	vec3 dhworldPos = dheyePlayerPos + eyeCameraPosition; 
	vec3 dhcameraToPoint = dhworldPos - cameraPosition;
	dhcameraToPoint = normalize(dhcameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, dhcameraToPoint, sunDirectionEyePlayerPos, FOG_INTENSITY/1000, 0.01);
	}
	}  else {
	vec3 NDCPos = vec3(texCoord.xy, depth) * 2.0 - 1.0;
  	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	float myDistance = length(viewPos);
	vec3 eyePlayerPos = mat3(gbufferModelViewInverse)*viewPos;
	vec3 worldPos = eyePlayerPos + eyeCameraPosition; 
	vec3 cameraToPoint = worldPos - cameraPosition;
	cameraToPoint = normalize(cameraToPoint);
	color.rgb = applyFog(color.rgb, myDistance, cameraPosition, cameraToPoint, sunDirectionEyePlayerPos, FOG_INTENSITY/1000, 0.01);
  }
    /*DRAWBUFFERS:0*/
	 
	
	
	
	gl_FragData[0] = vec4(color, 1.0);
}
