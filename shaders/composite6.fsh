#version 430 compatibility

#include "/programs/settings.glsl"

#ifdef BLOOM

in vec2 texCoord; // full-res input
uniform sampler2D colortex4;
float offset = BLOOM_SPREAD;        
uniform float viewWidth;
uniform float viewHeight;
vec2 frameSizeRCP = vec2(1.0 / viewWidth, 1.0 / viewHeight);
float gaussianWeight(float x, float sigma)
{
	/* e ^ ( - x² / 2 σ² ) */
	return exp(-(x * x) / (2.0 * sigma * sigma));
}
vec2 direction = vec2(0.0, 1.0); // Horizontal blur
void main() {

    int kernel_size = BLOOM_KERNEL_SIZE; // Number of samples on one side of the center sample
    /* Variable to hold our final color for the current pixel */
	vec4 sum = vec4(0.0);
	/* Sum of all weights */
	float weightSum = 0.0;
	
	/* How big one side of the sampled line is */

	/* Sample along the direction vector (horizontal or vertical) */
	for (int i = -kernel_size; i <= kernel_size; ++i) {
		/* Calculate the required weight for this 1D sample */
		float w = gaussianWeight(float(i), BLOOM_SIGMA);
		
		/* Offset from the current pixel along the specified direction */
		vec2 offset = vec2(i) * direction * BLOOM_SPREAD * frameSizeRCP;

		/* Read and sum up the contribution of that pixel, weighted */
		sum += texture(colortex4, texCoord + offset) * w;
		weightSum += w;
	}

	/* Return the sum, divided by the total weight (normalization) */
	

    /*DRAWBUFFERS:4 */
    
	gl_FragData[0] = (sum / weightSum);

}

#endif