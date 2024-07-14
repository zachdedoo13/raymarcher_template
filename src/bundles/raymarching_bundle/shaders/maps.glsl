
//#include "shapes.glsl"
struct MapOut {float d; };

struct Obj {
    float dist;
    vec3 col;
    float rel;
};

#define NUM 3
Obj map(const vec3 pos) {
    vec3 tr;
    Obj objects[NUM]; // Array to hold objects for simplified processing

    // Test sphere 1
    tr = move(pos, vec3(1.0, sin(c.time), 1.0));
    objects[0] = Obj(
        sdSphere(tr, 1.0),
        vec3(0.0),
        0.5
    );

    // Test sphere 2
    tr = move(pos, vec3(-sin(c.time * 0.2), -3.0, -1.0));
    objects[1] = Obj(
        sdSphere(tr, 1.0),
        vec3(1.0, 0.0, 0.0),
        0.0
    );

    // Test box 1
    tr = move(pos, vec3(-2.0, 0.0, 0.0));
    tr.xy *= rot2D(sin(c.time) * 0.1);
    tr.xz *= rot2D(0.2);
    objects[2] = Obj(
        sdRoundBox(tr, vec3(1.0, 2.0, 2.0), 0.0),
        vec3(0.0),
        1.0
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

