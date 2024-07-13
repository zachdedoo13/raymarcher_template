vec2 calc_uv()
{
    vec2 uv = vec2(fragUV.x * c.aspect, fragUV.y);
    return uv;
}

vec3 calc_point(const Ray ray, float t)
{
    return ray.ro + ray.rd * t;
}

float dist(const mat2x4 map_out)
{
    return map_out[0][0];
}
vec3 color(const mat2x4 map_out)
{
    return vec3(
        map_out[0][1],
        map_out[0][2],
        map_out[0][3]
    );
}


vec3 skybox(const Ray ray) {
    return vec3(0.30, 0.36, 0.60) - (ray.rd.y * 0.7); // skybox
}


//March map(const vec3 pos); // placeholder
float pull(const vec3 p, const vec3 e) {
    return dist(map(p + e, false));
}

vec3 getNormal(const vec3 p) {
    const vec3 e = vec3(.001, 0.0, 0.0);
    return normalize(
        vec3(
            pull(p, e.xyy) - pull(p, -e.xyy),
            pull(p, e.yxy) - pull(p, -e.yxy),
            pull(p, e.yyx) - pull(p, -e.yyx)
        )
    );
}


