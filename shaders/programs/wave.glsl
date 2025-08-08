

vec3 wave(vec3 pos, int worldTime) {

pos.y += 0.03*sin(0.06*worldTime + 0.25*pos.z - 0.45*pos.x + 10) * sin(0.06*worldTime + 0.05*pos.z + 0.05*pos.x + 10)
      + 0.03*sin(0.02*worldTime - 0.4*pos.z - 0.15*pos.x + 5)  * sin(0.06*worldTime + 0.02*pos.z - 0.07*pos.x + 10)
      +0.03*sin(0.04*worldTime + 1.0*pos.z - 0.7*pos.x + 11) * sin(0.07*worldTime + 0.04*pos.z + 0.06*pos.x + 11)
      + 0.03*sin(0.035*worldTime + 0.8*pos.z + 0.9*pos.x + 7)  * sin(0.07*worldTime + 0.04*pos.z - 0.06*pos.x + 7)
      + 0.02 * pow(sin(0.05*worldTime + 2.8*pos.z + 2.9*pos.x + 7) *  sin(0.06*worldTime + 1.0*pos.z - 1.07*pos.x + 10), 2)
      + 0.02 * pow(sin(0.05*worldTime + 2.95*pos.z - 2.11*pos.x + 5) *  sin(0.06*worldTime + 1.0*pos.z + 1.07*pos.x + 10), 2);
return pos;

}