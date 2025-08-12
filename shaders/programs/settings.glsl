/* 
Blocky Shaders v0.1 Series by dvimidh 
https://dvimidh.com 
*/ 

#define INFO 0 //[0]

//Lighting//
  #define SHADOW
  #define SHADOW_INTENSITY 1.6 // [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.3 1.4 1.5 1.6 1.7 1.9 2.0 2.4 2.8 3.0 3.5 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
  #define SKYLIGHT_INTENSITY 1.0 // [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.3 1.4 1.5 1.6 1.7 1.9 2.0 2.4 2.8 3.0 3.5 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
  #define AMBIENT_INTENSITY 1.0 // [0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.3 1.4 1.5 1.6 1.7 1.9 2.0 2.4 2.8 3.0 3.5 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
  const int shadowMapResolution       = 2048; // [1024 1536 2048 3072 4096 6144 8192 16384]
  const float shadowDistance = 256.0; //[128.0 192.0 256.0 384.0 512.0 768.0 1024.0]
  const bool shadowHardwareFiltering = true;
  #define FXAA_SUBPIXEL 0.50 //[0.00 0.25 0.50 0.75 1.00
  //#define SHADOW_FILTERING
  #define PIXEL_LOCKED_SHADOWS

//Water//
  #define WATER_STYLE 1 //[1 2]
  #define WATER_TRANSLUCENCY_MULTIPLIER 1.4 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
  #define WATER_SHININESS 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
  #define WATER_ROUGHNESS 1.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
//Fog//
  #define FOG_INTENSITY 1.0 //[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.3 1.4 1.5 1.6 1.7 1.9 2.0 2.4 2.8 3.0 3.5 4.0 5.0 6.0 7.0 8.0 9.0 10.0]

//PostProcessing//
  #define FXAA