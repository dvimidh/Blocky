

//uniforms
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;

uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrixInverse;

uniform float far;
uniform float dhNearPlane;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

//vertexToFragment
in vec2 texCoord;
in vec3 foliageColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;
in vec4 tangent;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 outColor0;
 

void main() {

    

    vec4 outputColorData = texture(gtexture,texCoord);
    vec3 albedo = pow(outputColorData.rgb,vec3(2.2)) * pow(foliageColor,vec3(2.2));
    float transparency = outputColorData.a;


    if(outputColorData.a < 0.1) {
        discard;
    }
    //output color
    outColor0 =vec4(pow(albedo, vec3(1/2.2)), transparency);
}
