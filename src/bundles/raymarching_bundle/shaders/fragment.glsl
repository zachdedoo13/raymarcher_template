#version 450


layout(location = 0) out vec4 fragColor;
layout(location = 1) in vec2 fragUV;

layout(set = 0, binding = 0) uniform Constants {
    float aspect;
    float time;
} c;

#include "shapes.glsl"

vec2 calc_uv() {
    vec2 uv = vec2(fragUV.x * c.aspect, fragUV.y);
    return uv;
}


float map(const vec3 p) {
    float ns = sdSphere(p - vec3(sin(c.time)), 1.0);

    return ns; // distance to a sphere of radius 1
}

void main() {
    vec2 uv = calc_uv();

    // Initialization
    vec3 ro = vec3(0, 0, -3);         // ray origin
    vec3 rd = normalize(vec3(uv, 1)); // ray direction
    vec3 col = vec3(0);               // final pixel color

    float t = 0.; // total distance travelled

    // Raymarching
    for (int i = 0; i < 80; i++) {
        vec3 p = ro + rd * t;     // position along the ray

        float d = map(p);         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > 100.) break;      // early stop if too far
    }

    // Coloring
    col = vec3(1. / t * .2);           // color based on distance

    fragColor = vec4(col, 1);
}