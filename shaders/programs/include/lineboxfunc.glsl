struct LineBoxIntersectResult {
    bool hit;
    vec3 hitpos;
    vec3 hitnormal;
    vec3 exitpos;
};

LineBoxIntersectResult lineboxintersect(vec3 start, vec3 direction, vec3 boxmin, vec3 boxmax) {
    vec3 invDir = 1.0 / direction;
    vec3 t0 = (boxmin - start) * invDir;
    vec3 t1 = (boxmax - start) * invDir;
    vec3 tsmaller = min(t0, t1);
    vec3 tbigger  = max(t0, t1);
    
    float tmin = max(0.0, max(tsmaller.x, max(tsmaller.y, tsmaller.z)));
    float tmax = min(1e30, min(tbigger.x, min(tbigger.y, tbigger.z)));
    
    LineBoxIntersectResult result;
    result.hit = tmax >= tmin;
    result.hitpos = start + direction * tmin;
    result.exitpos = start + direction * tmax;
    result.hitnormal = -sign(direction) * step(vec3(tmin), tsmaller);;
    
    return result;
}