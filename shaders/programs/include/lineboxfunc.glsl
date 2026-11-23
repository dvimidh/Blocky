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
    return ((sin(x*scale*0.3 + t*speed)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.7 + t*speed)*0.5 + 0.5)*midstrength + (sin(x*1.5*scale + t*speed)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
}

float ydens(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return ((sin(x*scale*0.25 + t*speed*0.9)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.75 + t*speed*0.9)*0.5 + 0.5)*midstrength + (sin(x*1.45*scale + t*speed*0.9)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
}

float zdens(float x, float t, float speed, float scale, float tinystrenght, float midstrength, float bigstrenght) {
    return ((sin(x*scale*0.2 + t*speed*1.1)*0.5 + 0.5)*bigstrenght + (sin(x*scale*0.8 + t*speed*1.1)*0.5 + 0.5)*midstrength + (sin(x*1.4*scale + t*speed*1.1)*0.5 + 0.5)*tinystrenght)*0.7 + 0.4;
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

float lineintegral(vec3 start, vec3 end, float time){
    float Bigstren = 0.4;
    float Smalstren = 0.04;
    float Medstren = 0.01;
    vec3 dir = normalize(end - start);
    float xintegral = xint(end.x, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - xint(start.x, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);
    float yintegral = yint(end.y, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - yint(start.y, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);
    float zintegral = zint(end.z, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) - zint(start.z, time, 1.0, 1.0, Smalstren, Medstren, Bigstren);

    if (dir.x == 0.0) {
        xintegral = 0.0;
    } else {
        xintegral = xintegral / dir.x;
    }
    if (dir.y == 0.0) {
        yintegral = 0.0;
    } else {
        yintegral = yintegral / dir.y;
    }
    if (dir.z == 0.0) {
        zintegral = 0.0;
    }  else {
        zintegral = zintegral / dir.z;
    }

    return xintegral + yintegral + zintegral;
}


float tracebox(vec3 start, vec3 direction, tuple box, float maxdist, float time) {
    LineBoxIntersectResult result = lineboxintersect(start, direction, box.a, box.b);

    float integral = 0.0;
    float ysmoothintegral = 0.0;
    if(length(result.hitpos-start) > maxdist) {
        return 0.0;
    }
    if(!result.hit) {
        return 0.0;
    }
    if(length(result.hitpos - result.exitpos) < length(result.exitpos - start)) {
        if (length(result.exitpos - start) > maxdist) {
            integral = lineintegral(result.hitpos, maxdist*direction + start, time);
        } else {
            integral = lineintegral(result.hitpos, result.exitpos, time);
        }
  
    } else {
        if (length(result.exitpos - start) > maxdist) {
            integral = lineintegral(start, maxdist*direction + start, time);
        } else {
            integral = lineintegral(start, result.exitpos, time);
        }

    }
    

    // Convert integrated density to exponential scattering opacity.
    const float extinction = 0.25;
    return 1.0 - exp(-extinction * (max(abs(integral) - 10.0, 0.0)));
}