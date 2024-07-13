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
struct Prog {int steps; float dist; };
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

        float d = dist(map(p, false));         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) GetTheFuckOut;      // early stop if close enough
        if (t > s.farplane) return Prog(i, -1.);      // early stop if too far
    }

    return Prog(i, t);
}


vec3 lighting(C Ray ray, C vec3 pos) {
    // object values
    vec3 color = color(map(pos, true));
    vec3 normal = getNormal(pos);


    // diffuse lighting
    vec3 light_col = vec3(1.0, 1.0, 1.0);
    vec3 light_pos = vec3(s.light_x, s.light_y, s.light_z);
    float diffuse_strength = max(
        0.0,
        dot(normalize(light_pos), normal)
    );
    vec3 diffuse = light_col + diffuse_strength;

    // speculer lighting
    vec3 view_source = normalize(ray.ro);
    vec3 reflect_source = normalize(reflect(-light_pos, normal));
    float speculer_strength = max(0.0, dot(view_source, reflect_source));
    speculer_strength = pow(speculer_strength, 64.0);
    vec3 speculer = speculer_strength * light_col;


    // shadows
    vec3 light_dir = normalize(light_pos);
    float dist_to_source = length(light_pos - pos);
    Ray shadow_ray;
    shadow_ray.ro = pos + normal * 0.05;
    shadow_ray.rd = light_dir;
    Prog shadow_out = cast_ray(shadow_ray, 80);

    vec3 shadows = vec3(1.0);
    if (shadow_out.dist < dist_to_source && shadow_out.dist > 0.0) {
        shadows = vec3(s.shadows);
    } else { // soft shadows
        float shadow_val = float(shadow_out.steps) / float(s.soft_shadows_const_steps);

        float smooth_shadow = smoothstep(0.0, s.soft_shadows, shadow_val);

        shadows = vec3(s.shadows * (1.0 / smooth_shadow));
    }


    // compileing
    vec3 lighting = diffuse * s.diffuse + speculer * s.speculer;
    lighting *= shadows;

    vec3 final_color = color * lighting;


    return final_color;
}

vec3 calc_color(C Prog p, C Ray ray) {
    vec3 col;
    if (p.dist == -1.) {
        col = skybox(ray);
    }
    else if (p.dist == -2.) {

    }
    else {
        // lighting and color
        vec3 pos = calc_point(ray, p.dist);

        col = lighting(ray, pos);
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