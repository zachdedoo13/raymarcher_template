
//#include "shapes.glsl"
struct MapOut {float d; };
// x = depth yzw = color
vec4 map(const vec3 pos, const bool color_calc) {
    vec3 p = pos;
    vec3 tr;

    // box sphere mix
    tr = p;
    tr = move(tr, vec3(0.0, 0.0, 1.0));
    tr.xy *= rot2D(c.time);
    tr.zy *= rot2D(c.time);
    float sphere = sdSphere(tr,  1.0);
    float frame = sdBoxFrame(tr, vec3(1.0), 0.2);
    float sphere_box = mix(sphere, frame, sin(c.time) * 0.5 + 0.5);
    vec3 sphere_box_color = vec3(1.0, 0.0, 0.0);

    // floor
    tr = p;
    tr = move(tr, vec3(0.0, -2.0, 0.0));
    float floor = sdBox(tr, vec3(4.0, 0.25, 4.0));
    vec3 floor_color = vec3(0.0, 1.0, 0.0);


    float depth = 0.0;
    if (!color_calc) {
        depth = sphere_box;
        depth = opUnion(depth, floor);
    }

    vec3 color = vec3(0.);
    if (color_calc) {
        color = sphere_box_color;
        color = vecOpUnion(sphere_box, floor, color, floor_color);
    }

    vec4 end = vec4(depth, color);

    return end;
}