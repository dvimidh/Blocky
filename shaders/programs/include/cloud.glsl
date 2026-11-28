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
/*
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
        float midX = 0.5 * (start.x + end.x);
        xintegral = xdens(midX, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) * length(end-start);
    } 
    if (abs(dir.y) <= 1e-5) {
        float midY = 0.5 * (start.y + end.y);
        yintegral = ydens(midY, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) * length(end - start);
    } 

    if (abs(dir.z) <= 1e-5) {
        float midZ = 0.5 * (start.z + end.z);
        zintegral = zdens(midZ, time, 1.0, 1.0, Smalstren, Medstren, Bigstren) * length(end - start);
    } 

    return xintegral + yintegral + zintegral;
}
*/
struct floatvec3 {
    float scalar; 
    vec3 vector3;
    };

floatvec3 tracebox(vec3 start, vec3 direction, tuple box, float maxdist, float time) {
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
    vec3 rayEnd = start + maxdist * direction;
    if(length(result.hitpos - result.exitpos) < length(result.exitpos - start)) {
        loc = result.hitpos +  0.01*direction - 0.01*result.hitnormal;
        if (length(result.exitpos - start) > maxdist) {
            //integral = lineintegral(result.hitpos, maxdist*direction + start, time, wiggleStrenMul);
            integral = length(rayEnd - result.hitpos);
        } else {
            //integral = lineintegral(result.hitpos, result.exitpos, time, wiggleStrenMul);
            integral = length(result.hitpos - result.exitpos);
        }
  
    } else {
        loc = start;
        if (length(result.exitpos - start) > maxdist) {
            //integral = lineintegral(start, maxdist*direction + start, time, wiggleStrenMul);
            integral = length(rayEnd - start);
        } else {
            //integral = lineintegral(start, result.exitpos, time, wiggleStrenMul);
            integral = length(start - result.exitpos);
        }

    }

    // Convert integrated density to exponential scattering opacity.
    return floatvec3(integral, loc);
}

struct vec2vec2{
    vec2 a;
    vec2 b;
};

vec2vec2 getXZ(vec3 pos, vec3 direction, float center, float thick){
    float lowheight = center - thick/2.0;
    float highheight = center + thick/2.0;
    vec3 worldLowHit = pos + ((lowheight - pos.y) / normalize(direction).y) * direction;
    vec3 worldHighHit = pos + ((highheight - pos.y) / normalize(direction).y) * direction;
    return vec2vec2(vec2(worldLowHit.x, worldLowHit.z), vec2(worldHighHit.x, worldHighHit.z));
}

vec2 getUV(vec2 XY, float scale) {
    vec2 scaled = XY * scale / (12.0*256.0);
    vec2 UV = fract(scaled);
    return UV;
}

floatvec3 traceClouds(vec3 pos, vec3 direction, float maxdist, float time, float extinction, float center, float thick, float scale, sampler2D CloudTex, float maxTraceDist) {
    vec2 bottomXZ;
    vec2 topXZ;
    vec2 pos2 = vec2(pos.x, pos.z);
    vec3 rayDirection = normalize(direction);
    float layerMinY = center - thick * 0.5;
    float layerMaxY = center + thick * 0.5;
    float traceLimit = min(maxdist, maxTraceDist);
    float tEnter;
    float tExit;

    if (abs(rayDirection.y) < 1.0E-6) {
        if (pos.y < layerMinY || pos.y > layerMaxY) {
            return floatvec3(0.0, vec3(0.0));
        }
        tEnter = 0.0;
        tExit = traceLimit;
    } else {
        tEnter = (layerMinY - pos.y) / rayDirection.y;
        tExit = (layerMaxY - pos.y) / rayDirection.y;
        if (tEnter > tExit) {
            float swapT = tEnter;
            tEnter = tExit;
            tExit = swapT;
        }
        tEnter = max(tEnter, 0.0);
        tExit = min(tExit, traceLimit);
        if (tExit <= tEnter) {
            return floatvec3(0.0, vec3(0.0));
        }
    }

    bottomXZ = pos2 + rayDirection.xz * tEnter;
    topXZ = pos2 + rayDirection.xz * tExit;






    float blockSize = 12.0 * scale;
    vec2 startXZ;
    vec2 endXZ;
    if (length(topXZ - pos2) > length(bottomXZ - pos2)) {
        startXZ = bottomXZ;
        endXZ = topXZ;
    } else {
        startXZ = topXZ;
        endXZ = bottomXZ;
    }
    
    vec2 windVelocity = vec2(-0.75*CLOUDS_SPEED, 0.0);
    vec2 cloudOffset = windVelocity * time*scale;
    vec2 gridStartXZ = startXZ - cloudOffset;
    vec2 gridEndXZ = endXZ - cloudOffset;

    ivec2 cell = ivec2(floor(gridStartXZ / blockSize));
    ivec2 endCell = ivec2(floor(gridEndXZ / blockSize));
    int nx = endCell.x - cell.x;
    if (nx < 0) {
        nx = -nx;
    }
    int ny = endCell.y - cell.y;
    if (ny < 0) {
        ny = -ny;
    }
    int stepX = 1;
    if (endCell.x < cell.x) {
        stepX = -1;
    }
    int stepY = 1;
    if (endCell.y < cell.y) {
        stepY = -1;
    }

    vec2 rayXZ = gridEndXZ - gridStartXZ;
    float tDeltaX = 1.0E30;
    float tDeltaY = 1.0E30;
    float tMaxX = 1.0E30;
    float tMaxY = 1.0E30;
    if (cell.x != endCell.x && abs(rayXZ.x) > 1.0E-6) {
        tDeltaX = blockSize / abs(rayXZ.x);
        float boundaryX;
        if (stepX > 0) {
            boundaryX = (float(cell.x) + 1.0) * blockSize;
        } else {
            boundaryX = float(cell.x) * blockSize;
        }
        tMaxX = (boundaryX - gridStartXZ.x) / rayXZ.x;
    }
    if (cell.y != endCell.y && abs(rayXZ.y) > 1.0E-6) {
        tDeltaY = blockSize / abs(rayXZ.y);
        float boundaryY;
        if (stepY > 0) {
            boundaryY = (float(cell.y) + 1.0) * blockSize;
        } else {
            boundaryY = float(cell.y) * blockSize;
        }
        tMaxY = (boundaryY - gridStartXZ.y) / rayXZ.y;
    }

    float sum = 0.0;
    vec3 hitpos = pos;
    vec4 fetched;
    bool hityet = false;
    tuple box;
    floatvec3 result;

    vec2 cellCenterXZ = vec2(float(cell.x) + 0.5, float(cell.y) + 0.5) * blockSize;
    fetched = texture2D(CloudTex, getUV(cellCenterXZ, scale));
    if ((fetched.r + fetched.g + fetched.b + fetched.a)/4.0 > 0.5) {
        vec2 worldCellCenterXZ = cellCenterXZ + cloudOffset;
        box = boxify(vec3(worldCellCenterXZ.x, center, worldCellCenterXZ.y), vec3(blockSize + 0.02, thick, blockSize + 0.02));
        result = tracebox(pos, normalize(direction), box, maxdist, time);
        sum += result.scalar;
        if (result.scalar > 0.0 && !hityet) {
            hityet = true;
        hitpos = result.vector3;
        }
    }


    int maxiter = nx + ny + 1;
    for (int i = 0; i < maxiter; ++i) {
        if (cell.x == endCell.x && cell.y == endCell.y) {
            break;
        }
        if (1.0 - exp(-extinction * (max(abs(sum), 0.0))) > 0.999) {
            break;
        }

        if (tMaxX < tMaxY) {
            cell.x += stepX;
            tMaxX += tDeltaX;
        } else if (tMaxY < tMaxX) {
            cell.y += stepY;
            tMaxY += tDeltaY;
        } else {
            // A corner touch has zero path length in the side cells; step diagonally.
            cell.x += stepX;
            cell.y += stepY;
            tMaxX += tDeltaX;
            tMaxY += tDeltaY;
        }

        cellCenterXZ = vec2(float(cell.x) + 0.5, float(cell.y) + 0.5) * blockSize;
        fetched = texture2D(CloudTex, getUV(cellCenterXZ, scale));
        if ((fetched.r + fetched.g + fetched.b + fetched.a) / 4.0 > 0.5) {
            vec2 worldCellCenterXZ = cellCenterXZ + cloudOffset;
            box = boxify(vec3(worldCellCenterXZ.x, center, worldCellCenterXZ.y), vec3(blockSize + 0.02, thick, blockSize + 0.02));
            result = tracebox(pos, normalize(direction), box, maxdist, time);
            sum += result.scalar;
            if (result.scalar > 0.0) {
                if (!hityet) {
                    hitpos = result.vector3;
                }
                hityet = true;
            }
        }
    }
    


    return floatvec3(1.0 - exp(-extinction * (max(abs(sum), 0.0))), vec3(hitpos));
}