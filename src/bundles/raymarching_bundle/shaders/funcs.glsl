vec2 calc_uv()
{
    vec2 uv = vec2(fragUV.x * c.aspect, fragUV.y);
    return uv;
}

vec3 calc_point(const Ray ray, float t)
{
    return ray.ro + ray.rd * t;
}

//March map(const vec3 pos); // placeholder
float pull(const vec3 p, const vec3 e) {
    return map(p + e, false).x;
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

float dist(const vec4 map_out) {
    return map_out.x;
}
vec3 color(const vec4 map_out) {
    return map_out.yzw;
}

