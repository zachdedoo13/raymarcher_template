// the consts are nessocery so shaderc dosent fuck it over during its compalation
#define C const

// Shapes
float sdSphere(C vec3 p, C float s )
{
    return length(p)-s;
}

float sdBox( C vec3 p, C vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


float sdRoundBox( C vec3 p, C vec3 b, C float r )
{
    vec3 q = abs(p) - b + r;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdBoxFrame( C vec3 p, C vec3 b, C float e )
{
    vec3 np = abs(p)-b;
    vec3 q = abs(np+e)-e;
    return min(min(
    length(max(vec3(np.x,q.y,q.z),0.0))+min(max(np.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,np.y,q.z),0.0))+min(max(q.x,max(np.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,np.z),0.0))+min(max(q.x,max(q.y,np.z)),0.0));
}

float sdTorus( C vec3 p, C vec2 t )
{
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float sdCappedTorus( C vec3 p, C vec2 sc, C float ra, C float rb)
{
    vec3 np = p;
    np.x = abs(np.x);
    float k = (sc.y*np.x>sc.x*np.y) ? dot(np.xy,sc) : length(np.xy);
    return sqrt( dot(np,np) + ra*ra - 2.0*ra*k ) - rb;
}

float sdLink( C vec3 p, C float le, C float r1, C float r2 )
{
    vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
    return length(vec2(length(q.xy)-r1,q.z)) - r2;
}



// translations
vec3 move(C vec3 pos, C vec3 by) {
    return pos - by;
}

mat2 rot2D(C float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    mat2 rot = mat2(c, -s, s, c);

    return rot;
}


// unions

float opUnion( C float d1, C float d2 )
{
    return min(d1,d2);
}

vec3 vecOpUnion( C float d1, C float d2, C vec3 v1, C vec3 v2 )
{
    return d1 < d2 ? v1 : v2;
}

float floatOpUnion( C float d1, C float d2, C float v1, C float v2 )
{
    return d1 < d2 ? v1 : v2;
}


float opSubtraction( C float d1, C float d2 )
{
    return max(-d1,d2);
}


float opIntersection( C float d1, C float d2 )
{
    return max(d1,d2);
}


float opXor(C float d1, C float d2 )
{
    return max(min(d1,d2),-max(d1,d2));
}


// distortions

vec3 opCheapBend( C vec3 p, C float by )
{
    const float k = by; // or some other amount
    float c = cos(k*p.x);
    float s = sin(k*p.x);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xy,p.z);
    return q;
}


vec3 opTwist( C vec3 p, C float by )
{
    const float k = by; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xz,p.y);
    return q;
}

float displacement(C vec3 p, C float by) {
    return sin(by*p.x)*sin(by*p.y)*sin(by*p.z);
}

float opDisplace( C vec3 p, C float dist, C float by )
{
    float d1 = dist;
    float d2 = displacement(p, by);
    return d1+d2;
}
