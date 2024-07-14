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
    mat2x4 the_cast_ray;

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

struct Reflect { float rel; vec3 f_col; Prog march; Ray ray; };

Reflect calc_reflection(C vec3 point, C vec3 normal, C Ray o_ray, C float rel) {
    Ray reflect_ray = Ray(point + normal*0.03, reflect(o_ray.rd, normal));
    Prog reflect_pass = cast_ray( reflect_ray, 80 );

    if (reflect_pass.dist == -1) { // skybox exseption
        vec3 col = skybox(reflect_ray) * rel;
        return Reflect(-1.0, col, reflect_pass, Ray(vec3(0.0), vec3(0.0)));
    }

    vec3 reflect_point = calc_point(reflect_ray, reflect_pass.dist);
    Obj reflect = map(reflect_point);

    vec3 reflect_col = (reflect.col * reflect_pass.dist * s.soft_shadows) * rel;
    return Reflect(reflect.rel, reflect_col, reflect_pass, reflect_ray);
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
        vec3 o_col = hit.col * p.dist * s.soft_shadows;

        vec3 reflections_color;

        Reflect reflect = calc_reflection(point, normal, ray, hit.rel);
        reflections_color += reflect.f_col;

        for (int i = 0; i < 5; i++){
            if (reflect.rel != -1) {
                point = calc_point(reflect.ray, reflect.march.dist);
                normal = calc_normal(point);
                reflect = calc_reflection(point, normal, reflect.ray, reflect.rel);
                reflections_color += reflect.f_col;
            }
        }

        col = vec3(o_col + reflections_color * hit.rel);
    }

    return col;
}

void main() {
    vec2 uv = calc_uv();

    // Initialization
    vec3 pos = vec3(0, 1, -8);
    vec3 dir = normalize(vec3(uv, 1));
    dir.yz *= rot2D(0.2); // rotate down
    Ray ray = Ray(pos, dir);

    // first pass
    Prog first_pass = cast_ray(ray, s.main_steps); // first pass depth only

    // Coloring
    vec3 col = calc_color(first_pass, ray);

    // dislay lights


    fragColor = vec4(col, 1.0);
}