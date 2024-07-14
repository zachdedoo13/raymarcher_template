
//#include "shapes.glsl"
struct MapOut {float d; };

struct Obj {
    float dist;
    vec3 col;
    float rel;
};

vec3 repeat(vec3 pos, vec3 repeatInterval) {
    return mod(pos + repeatInterval * 0.5, repeatInterval) - repeatInterval * 0.5;
}

#define NUM 4
Obj map(const vec3 cam_pos) {
    vec3 pos = cam_pos;
    vec3 tr;
    Obj objects[NUM]; // Array to hold objects for simplified processing

    // globel transforms
    pos = pos;


    // Test sphere 1
    tr = move(pos, vec3(1.0, sin(c.time), 1.0));
    objects[0] = Obj(
        sdSphere(tr, 1.0),
        vec3(0.1),
        1.0
    );

    // Test sphere 2
    tr = move(pos, vec3(sin(c.time), 1.5 - s.diffuse, -5.0));
    objects[1] = Obj(
        sdSphere(tr, smoothstep(0.0, 2.0, abs(sin(c.time * 0.5)))),
        vec3(0.0, 0.0, 0.0),
        1.0
    );

    // Test box 1
    tr = move(pos, vec3(-2.0, 0.0, 0.0));
    tr.xy *= rot2D(sin(c.time) * 0.1);
    tr.xz *= rot2D(0.2);
    objects[2] = Obj(
        sdRoundBox(tr, vec3(1.0, 2.0, 2.0), 0.1),
        vec3(0.3),
        1.0
    );

    // Test box 2
//    tr = pos;
//    tr = move(tr, vec3(0.0, 3.5, 0.0));
//    objects[3] = Obj(
//        sdRoundBox(tr, vec3(1.0), 0.1),
//        vec3(0.5),
//        0.0
//    );

    // Test box 3
    tr = pos;
    tr = move(tr, vec3(0.0, 0.5, -15.0));
    tr = repeat(tr, vec3(15.0));

    float by = c.time * 0.2;
    tr.xz *= rot2D(by);
    tr.zy *= rot2D(by);

    objects[3] = Obj(
        sdRoundBox(tr, vec3(1.0), 0.0),
        vec3(0.0),
//        abs(sin(c.time * 0.05))
        0.6
    );


    // todo optimise
    // unions
    float dist = objects[0].dist;
    vec3 color = objects[0].col;
    float reflect = objects[0].rel;
    for (int i = 1; i < NUM; i++) {
        dist = opUnion(dist, objects[i].dist);

        color = vecOpUnion(dist, objects[i].dist, color, objects[i].col);

        reflect = floatOpUnion(dist, objects[i].dist, reflect, objects[i].rel);
    }



    Obj end = Obj(dist, color, reflect);

    return end;
}

