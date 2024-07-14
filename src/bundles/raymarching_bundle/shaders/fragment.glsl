#version 450


layout(location = 0) out vec4 fragColor;
layout(location = 1) in vec2 fragUV;

layout(set = 0, binding = 0) uniform Constants {
    float aspect;
    float time;
} c;

layout(set = 1, binding = 0) uniform Settings {
    int main_steps;
    int reflect_steps;
    float farplane;
    float dis;

    float light_x;
    float light_y;
    float light_z;

    float diffuse;
    float speculer;
    float shadows;
    float soft_shadows;
    int soft_shadows_const_steps;
} s;

struct Ray {vec3 ro; vec3 rd; };
struct Prog {int steps; float dist;};
struct March {float depth; vec3 color; };


#include "shapes.glsl"
#include "maps.glsl"
#include "funcs.glsl"

#define GetTheFuckOut break
#define C const

Prog cast_ray(const Ray ray, const int steps) {
    float t = 0.0;
    int i;

    // Raymarching
    for (i = 0; i < steps; i++) {
        vec3 p = calc_point(ray, t);

        Obj the_cast_ray = map(p);
        float d = the_cast_ray.dist;   // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > s.farplane) return Prog(i, -1.);      // early stop if too far
    }

    return Prog(i, t); // defult to reguler type
}

vec3 get_color(C Obj ob, C Ray ray, C Prog p) {
//    return ob.col * p.dist * s.speculer;
    return ob.col;
}

#define MAX_BOUNCES 32
vec3 reflection_ray(C Ray start_ray, C vec3 start_point, C float start_rel, C int steps) {
    vec3 normal = calc_normal(start_point);
    Ray ray = Ray(start_point + normal*0.03, reflect(start_ray.rd, normal));
    vec3 out_color = vec3(0.0);

    float pre_rel = start_rel;
    int bounces = 0;
    float t = 0.0;

    vec3[MAX_BOUNCES] colors;
    float[MAX_BOUNCES] rels;

    int i;
    int sub_i = 0;
    for (i = 0; i < steps; i++) {
        sub_i++;
        vec3 p = calc_point(ray, t);

        Obj the_cast_ray = map(p);
        float d = the_cast_ray.dist;

        t += d;

        if (d < 0.001) {
            vec3 hit_col = get_color(the_cast_ray, ray, Prog(sub_i, t));
            sub_i = 0;

            colors[bounces] = hit_col;
            rels[bounces] = pre_rel;

            pre_rel = the_cast_ray.rel;

            normal = calc_normal(p);
            ray = Ray(p + normal*0.03, reflect(ray.rd, normal));

            bounces += 1;
            t = 0.0;
            if (bounces >= MAX_BOUNCES) break;
        }

        if (t > s.farplane || i == steps) {
            colors[bounces] = skybox(ray);
            rels[bounces] = pre_rel;
            break;
        };
    }

    for (int j = MAX_BOUNCES - 1; j > -1; j--) {
        out_color = (out_color + colors[j]) * rels[j];
    }

    return out_color;
}


vec3 calc_color(C Prog p, C Ray ray) {
    vec3 col;
    if (p.dist == -1.)  // skybox
    {
        col = skybox(ray);
    }

    else
    {
        vec3 point = calc_point(ray, p.dist);
        vec3 normal = calc_normal(point);

        Obj hit = map(point);
        vec3 o_col = get_color(hit, ray, p);

        vec3 reflections_color = reflection_ray(ray, point, hit.rel, s.reflect_steps);

        col = vec3(o_col + reflections_color);
    }

    return col;
}

void main() {
    vec2 uv = calc_uv();

    // Initialization
    vec3 pos = vec3(0, 1, -8);
    vec3 dir = normalize(vec3(uv, 1));
    dir.yz *= rot2D(0.1); // rotate down
    Ray ray = Ray(pos, dir);

    // first pass
    Prog first_pass = cast_ray(ray, s.main_steps); // first pass depth only

    // Coloring
    vec3 col = calc_color(first_pass, ray);

    // dislay lights


    fragColor = vec4(col, 1.0);
}