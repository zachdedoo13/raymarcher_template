
#include "shapes.glsl"
struct MapOut {float d; };

struct Obj {
    float dist;
    vec3 col;
    float rel;
};

vec3 repeat(vec3 pos, vec3 repeatInterval) {
    return mod(pos + repeatInterval * 0.5, repeatInterval) - repeatInterval * 0.5;
}



#define NUM 3
Obj test_1_map(const vec3 cam_pos) {
    vec3 pos = cam_pos;
    vec3 tr;
    Obj objects[NUM]; // Array to hold objects for simplified processing

    // globel transforms
    pos = pos;


    // Test sphere 1

    // Test sphere 2
    tr = move(pos, vec3(sin(c.time), 1.5, -5.0));
    tr = repeat(tr, vec3(15.0));
    objects[0] = Obj(
        sdSphere(tr, smoothstep(0.0, 2.0, abs(sin(c.time * 0.5)))),
        vec3(0.0, 0.0, 0.0),
        1.0
    );

    // Test box 1
    tr = move(pos, vec3(-2.0, 0.0, 0.0));
    tr.xy *= rot2D(sin(c.time) * 0.1);
    tr.xz *= rot2D(0.2);
    objects[1] = Obj(
        sdRoundBox(tr, vec3(1.0, 2.0, 2.0), 0.1),
        vec3(0.0, 0.0, 0.0),
        0.000
    );


    // Test box 2
    tr = pos;
    tr = move(tr, vec3(0.0, 0.5, 0.0));
    tr = repeat(tr, vec3(15.0));

    float by = c.time * 0.2;
    tr.xz *= rot2D(by);
    tr.zy *= rot2D(by);

    objects[2] = Obj(
        sdRoundBox(tr, vec3(1.0), 0.1),
        vec3(0.0),
//        abs(sin(c.time * 0.05))
        1.0
    );


    // todo optimise
    // unions
    float dist = objects[0].dist;
    vec3 color = objects[0].col;
    float reflect = objects[0].rel;
    for (int i = 1; i < NUM; i++) {
        float us = 1.5;

        float backup = dist;
//        dist = opUnion(backup, objects[i].dist);
        dist = opSmoothUnion(backup, objects[i].dist, us);

//        color = vecOpUnion(backup, objects[i].dist, color, objects[i].col);
        color = vecSmoothUnion(backup, objects[i].dist, color, objects[i].col, us);

//        reflect = floatOpUnion(backup, objects[i].dist, reflect, objects[i].rel);
        reflect = floatSmoothUnion(backup, objects[i].dist, reflect, objects[i].rel, us);
    }



    Obj end = Obj(dist, color, reflect);

    return end;
}



Obj room(const vec3 cam_pos) {
    vec3 pos = cam_pos;
    vec3 tr;
    vec3 center;

    // test room walls & floor
    center = move(pos, vec3(0.0, 0.0, 0.0));

    // back wall
    tr = center;
    tr = move(tr, vec3(0.0, 0.0, 3.0));
    Obj back_wall = Obj(
        sdBox(tr, vec3(8.0, 8.0, 1.0)),
        vec3(0.0, 0.0, 1.0),
        0.0
    );

    // left wall
    tr = center;
    tr = move(tr, vec3(-4.0, 0.0, 0.0));
    Obj left_wall = Obj(
        sdBox(tr, vec3(1.0, 8.0, 8.0)),
        vec3(1.0, 0.0, 0.0),
        0.0
    );

    // right wall
    tr = center;
    tr = move(tr, vec3(4.0, 0.0, 0.0));
    Obj right_wall = Obj(
        sdBox(tr, vec3(1.0, 8.0, 8.0)),
        vec3(0.0, 1.0, 0.0),
        0.0
    );

    // floor
    tr = center;
    tr = move(tr, vec3(0.0, -3.0, 0.0));
    Obj floor = Obj(
        sdBox(tr, vec3(8.0, 1.0, 8.0)),
        vec3(flat_grid_2d(tr.xz, 1.0, 0.95, 0.05)),
        0.1
    );

    // floor
    tr = center;
    tr = move(tr, vec3(0.0, 5.0, 0.0));
    Obj roof = Obj(
        sdBox(tr, vec3(8.0, 1.0, 8.0)),
        vec3(flat_grid_2d(tr.xz, 0.75, 0.95, 0.05)),
        0.1
    );


    // unions
    float room_dist = back_wall.dist;
    room_dist = opUnion(room_dist, left_wall.dist);
    room_dist = opUnion(room_dist, right_wall.dist);
    room_dist = opUnion(room_dist, floor.dist);
    room_dist = opUnion(room_dist, roof.dist);

    vec3 room_color = back_wall.col;
    room_color = vecOpUnion(room_dist, left_wall.dist, room_color, left_wall.col);
    room_color = vecOpUnion(room_dist, right_wall.dist, room_color, right_wall.col);
    room_color = vecOpUnion(room_dist, floor.dist, room_color, floor.col);
    room_color = vecOpUnion(room_dist, roof.dist, room_color, roof.col);

    float room_rel = back_wall.rel;
    room_rel = floatOpUnion(room_dist, left_wall.dist, room_rel, left_wall.rel);
    room_rel = floatOpUnion(room_dist, right_wall.dist, room_rel, right_wall.rel);
    room_rel = floatOpUnion(room_dist, floor.dist, room_rel, floor.rel);
    room_rel = floatOpUnion(room_dist, roof.dist, room_rel, roof.rel);


    Obj room = Obj(
        room_dist,
        room_color,
        room_rel
    );

    return room;
}


Obj red_green_blue_room(const vec3 cam_pos) {
    vec3 pos = cam_pos;


    Obj room = room(move(pos, vec3(0.0)));


    Obj test_ball = Obj(
        sdSphere(move(pos, vec3(sin(c.time), 0.0, 0.0)), 1.5),
        vec3(0.0, 0.0, 0.0),
        0.5
    );


    Obj end = Obj(
        opUnion(room.dist, test_ball.dist),
        vecOpUnion(room.dist, test_ball.dist, room.col, test_ball.col),
        floatOpUnion(room.dist, test_ball.dist, room.rel, test_ball.rel)
    );


    return end;
}

// call the selected main map function
Obj map(const vec3 cam_pos) {
    return red_green_blue_room(cam_pos);
}