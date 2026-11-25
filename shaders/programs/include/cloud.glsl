struct LineBoxIntersectResult {
    bool hit;
    vec3 hitpos;
    vec3 hitnormal;
    vec3 exitpos;
};

struct tuple {
    vec3 a;
    vec3 b;
};

tuple boxify(vec3 center, vec3 size) {
    tuple result;
    result.a = center - size * 0.5;
    result.b = center + size * 0.5;
    return result;
}

LineBoxIntersectResult lineboxintersect(vec3 start, vec3 direction, vec3 boxmin, vec3 boxmax) {//Williams Slab method
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
    result.hitnormal = -sign(direction) * step(vec3(tmin), tsmaller);
    
    return result;
}

//density functions for reference
float xdens(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 0.7*((sin(x*scale*0.3 + t*speed)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.7 + t*speed)*0.5 + 0.5)*midstrength + (sin(x*1.5*scale + t*speed)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
}

float ydens(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 1.4*((sin(x*scale*0.25 + t*speed*0.9)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.75 + t*speed*0.9)*0.5 + 0.5)*midstrength + (sin(x*1.45*scale + t*speed*0.9)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
}

float zdens(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 0.7*((sin(x*scale*0.2 + t*speed*1.1)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.8 + t*speed*1.1)*0.5 + 0.5)*midstrength + (sin(x*1.4*scale + t*speed*1.1)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
}

//partial integrals for use in line integrals
float xint(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 0.7 * (bigstrenght * (0.5*x - cos(x*scale*0.3 + t*speed)/(2.0*0.3*scale)) + midstrength * (0.5*x - cos(x*scale*0.7 + t*speed)/(2.0*0.7*scale)) + tinystrenght * (0.5*x - cos(x*1.5*scale + t*speed)/(2.0*1.5*scale))) + 0.4*x;
}

float yint(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 1.4 * (bigstrenght * (0.5*x - cos(x*scale*0.25 + t*speed*0.9)/(2.0*0.25*scale)) + midstrength * (0.5*x - cos(x*scale*0.75 + t*speed*0.9)/(2.0*0.75*scale)) + tinystrenght * (0.5*x - cos(x*1.45*scale + t*speed*0.9)/(2.0*1.45*scale))) + 0.4*x;
}

float zint(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return 0.7 * (bigstrenght * (0.5*x - cos(x*scale*0.2 + t*speed*1.1)/(2.0*0.2*scale)) + midstrength * (0.5*x - cos(x*scale*0.8 + t*speed*1.1)/(2.0*0.8*scale)) + tinystrenght * (0.5*x - cos(x*1.4*scale + t*speed*1.1)/(2.0*1.4*scale))) + 0.4*x;
}

float lineintegral(vec3 start, vec3 end, float time, float wiggleStrenMul){
    float Bigstren = 0.4*wiggleStrenMul;
    float Smalstren = 0.04*wiggleStrenMul;
    float Medstren = 0.01*wiggleStrenMul;
    vec3 dir = normalize(end - start);
    if (length(end-start) < 1e-6) {
        return 0.0;
    }
    float xintegral = xint(end.x, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - xint(start.x, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);
    float yintegral = yint(end.y, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - yint(start.y, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);
    float zintegral = zint(end.z, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - zint(start.z, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);

    if (abs(dir.x) <= 1e-5) {
        xintegral = 0.0;
    } else {
        float midX = 0.5 * (start.x + end.x);
        xintegral = xdens(midX, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) * length(end-start);
    }
if (abs(dir.y) <= 1e-5) {
    yintegral = 0.0;
} else {
    float midY = 0.5 * (start.y + end.y);
    yintegral = ydens(midY, time, 1.0, 1.0,
                      Smalstren, Medstren, Bigstren) * length(end - start);
}

if (abs(dir.z) <= 1e-5) {
    zintegral = 0.0;
} else {
    float midZ = 0.5 * (start.z + end.z);
    zintegral = zdens(midZ, time, 1.0, 1.0,
                      Smalstren, Medstren, Bigstren) * length(end - start);
}

    return xintegral + yintegral + zintegral;
}

struct floatvec3 {
    float scalar; 
    vec3 vector3;
    };

floatvec3 tracebox(vec3 start, vec3 direction, tuple box, float maxdist, float time, float extinction, float wiggleStrenMul) {
    LineBoxIntersectResult result = lineboxintersect(start, direction, box.a, box.b);

    float integral = 0.0;
    float ysmoothintegral = 0.0;
    if(length(result.hitpos-start) > maxdist) {
        return floatvec3(0.0, vec3(0.0));
    }
    if(!result.hit) {
        return floatvec3(0.0, vec3(0.0));
    }
    vec3 loc;
    if(length(result.hitpos - result.exitpos) < length(result.exitpos - start)) {
        loc = result.hitpos +  0.0001*direction;
        if (length(result.exitpos - start) > maxdist) {
            integral = lineintegral(result.hitpos, maxdist*direction + start, time, wiggleStrenMul);
        } else {
            integral = lineintegral(result.hitpos, result.exitpos, time, wiggleStrenMul);
        }
  
    } else {
        loc = start;
        if (length(result.exitpos - start) > maxdist) {
            integral = lineintegral(start, maxdist*direction + start, time, wiggleStrenMul);
        } else {
            integral = lineintegral(start, result.exitpos, time, wiggleStrenMul);
        }

    }

    // Convert integrated density to exponential scattering opacity.
    return floatvec3(1.0 - exp(-extinction * (max(abs(integral), 0.0))), loc);
}


