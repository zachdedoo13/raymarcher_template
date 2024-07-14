vec2 calc_uv()
{
    vec2 uv = vec2(fragUV.x * c.aspect, fragUV.y);
    return uv;
}

vec3 calc_point(const Ray ray, const float t)
{
    return ray.ro + ray.rd * t;
}

vec3 skybox(const Ray ray) {
    return vec3(0.30, 0.36, 0.60) - (ray.rd.y * 0.6); // skybox
}

vec3 druggy_skybox(const Ray ray) {
    return vec3(
    smoothstep(0.0, 1.0, abs(sin(c.time * 3.5) * 0.2)),
    smoothstep(0.0, 1.0, abs(sin(c.time * 0.5) * 0.4)),
    smoothstep(0.0, 1.0, abs(sin(c.time * 1.0) * 0.3))
    )
    - (ray.rd.y * smoothstep(0.0, 1.0, abs(sin(c.time * 1.0) * 0.3))); // skybox
}


//March map(const vec3 pos); // placeholder
float pull(const vec3 p, const vec3 e) {
    return map(p + e).dist;
}

vec3 calc_normal(const vec3 p) {
    const vec3 e = vec3(.001, 0.0, 0.0);
    return normalize(
        vec3(
            pull(p, e.xyy) - pull(p, -e.xyy),
            pull(p, e.yxy) - pull(p, -e.yxy),
            pull(p, e.yyx) - pull(p, -e.yyx)
        )
    );
}



//#define C const
//vec3 lighting(C Ray ray, C vec3 pos) {
//// object values
//    vec3 color = color(map(pos));
//    vec3 normal = getNormal(pos);
//
//
//    // diffuse lighting
//    vec3 light_col = vec3(1.0, 1.0, 1.0);
//    vec3 light_pos = vec3(s.light_x, s.light_y, s.light_z);
//    float diffuse_strength = max(
//    0.0,
//    dot(normalize(light_pos), normal)
//    );
//    vec3 diffuse = light_col + diffuse_strength;
//
//    // speculer lighting
//    vec3 view_source = normalize(ray.ro);
//    vec3 reflect_source = normalize(reflect(-light_pos, normal));
//    float speculer_strength = max(0.0, dot(view_source, reflect_source));
//    speculer_strength = pow(speculer_strength, 64.0);
//    vec3 speculer = speculer_strength * light_col;
//
//
//    // shadows
//    vec3 light_dir = normalize(light_pos);
//    float dist_to_source = length(light_pos - pos);
//    Ray shadow_ray;
//    shadow_ray.ro = pos + normal * 0.05;
//    shadow_ray.rd = light_dir;
//    Prog shadow_out = cast_ray(shadow_ray, 80);
//
//    vec3 shadows = vec3(1.0);
//    if (shadow_out.dist < dist_to_source && shadow_out.dist > 0.0) {
//        shadows = vec3(s.shadows);
//    } else { // soft shadows
//        float shadow_val = float(shadow_out.steps) / float(s.soft_shadows_const_steps);
//
//        float smooth_shadow = smoothstep(0.0, s.soft_shadows, shadow_val);
//
//        shadows = vec3(s.shadows * (1.0 / smooth_shadow));
//    }
//
//
//    // compileing
//    vec3 lighting = diffuse * s.diffuse + speculer * s.speculer;
//    lighting *= shadows;
//
//    vec3 final_color = color * lighting;
//
//
//    return final_color;
//}

