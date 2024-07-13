#version 450


layout(location = 0) out vec4 fragColor;
layout(location = 1) in vec2 fragUV;

layout(set = 0, binding = 0) uniform Constants {
    float aspect;
    float time;
} c;

layout(set = 1, binding = 0) uniform Settings {
    int main_steps;
    float farplane;
} s;

struct Ray {vec3 ro; vec3 rd; };
struct Prog {int steps; float dist; };
struct March {float depth; vec3 color; };


#include "shapes.glsl"
#include "maps.glsl"
#include "funcs.glsl"

Prog cast_ray(const Ray ray) {
    float t = 0.0;
    int i;

    // Raymarching
    for (i = 0; i < s.main_steps; i++) {
        vec3 p = calc_point(ray, t);

        float d = map(p, false).x;         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > s.farplane) return Prog(i, -1.);      // early stop if too far
    }

    return Prog(i, t);
}

vec3 prim_color(const Prog p, const Ray ray) {
    vec3 col;
    if (p.dist == -1.) {
        col = vec3(0.30, 0.36, 0.60) - (ray.rd.y * 0.7); // skybox
    } else {
//        col = getNormal(calc_point(ray, p.dist));
//        col = vec3(1.0);
        col = color(map( calc_point(ray, p.dist), true) ) * float(p.steps) / float(s.main_steps);
    }

    return col;
}

void main() {
    vec2 uv = calc_uv();

    // Initialization
    vec3 pos = vec3(0, 1, -3);
    vec3 dir = normalize(vec3(uv, 1));
    dir.yz *= rot2D(0.2); // rotate down
    Ray ray = Ray(pos, dir);

    Prog first_pass = cast_ray(ray);

    // Coloring

    fragColor = vec4(prim_color(first_pass, ray), 1);
}