// the consts are nessocery so shaderc dosent fuck it over during its compalation


float sdSphere(const vec3 p, const float s )
{
    return length(p)- abs(sin(c.time * 2.));
}