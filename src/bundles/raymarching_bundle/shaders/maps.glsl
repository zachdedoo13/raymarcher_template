
//#include "shapes.glsl"
struct MapOut {float d; };

struct Obj {
    float dist;
    vec3 col;
};

// #0 0 = depth 123 = color #1 1 = reflectivity ..
mat2x4 map(const vec3 pos, const bool color_calc) {
    vec3 p = pos;
    vec3 tr;

    // box sphere mix
    tr = p;
    tr = move(tr, vec3(0.0, 0.0, 1.0));
    tr.xy *= rot2D(c.time);
    tr.zy *= rot2D(c.time);
    float sphere = sdSphere(tr,  1.0);
    float frame = sdBoxFrame(tr, vec3(1.0), 0.175);

    Obj sb = Obj(
        mix(sphere, frame, sin(c.time) * 0.5 + 0.5), // shape
        vec3(1.0, 0.0, 0.0) // color
    );

    // floor
    tr = p;
    tr = move(tr, vec3(0.0, -6.0, 0.0));
    float f_shape = sdBox(tr, vec3(4.0, 4.0, 4.0));
    float f_dist = opDisplace(tr, f_shape, s.dis * 0.02);
    Obj floor = Obj(f_dist, vec3(0.0, 1.0, 0.0));


    // light_placeholder
    tr = p;
    tr = move(tr, vec3(s.light_x, s.light_y, s.light_z));
    Obj light = Obj(sdSphere(tr, 0.2), vec3(1.0));



    float depth = 0.0;
    if (!color_calc) {
        depth = sb.dist;  // 1
        depth = opUnion(depth, floor.dist); // 2
//        depth = opUnion(depth, light.dist); // 3
    }

    vec3 color = vec3(0.);
    if (color_calc) {
        color = sb.col; // 1
        color = vecOpUnion(sb.dist, floor.dist, color, floor.col); // 2
//        color = vecOpUnion(floor.dist, light.dist, color, light.col); // 2
    }

    mat2x4 end = mat2x4(
        vec4(depth, color),
        vec4(0.0)
    );

    return end;
}