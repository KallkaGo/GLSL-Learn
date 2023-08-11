/* 
溶解特效
 */

uniform sampler2D iChannel1;
uniform sampler2D iDissloveTex;
uniform sampler2D iRamTex;
uniform float iClip;
varying vec2 vUv;
varying vec3 normal_pos;
varying vec3 modelToCameraDir;

float customSmoothstep(float min, float max, float x) {
  return (x - min) / (max - min);
}

void main() {
  vec3 dir = normalize(modelToCameraDir);
  vec3 nor = normalize(normal_pos);
  float NdotV = clamp(dot(dir, nor), 0., 1.);
  float alpha = 1. - NdotV;
  float emiss = 2.;
  float instensity = 2.;

  float fresnel = pow(alpha, emiss);

  vec3 c = vec3(.1, .5, 1.);

  vec4 DissloveTex = texture2D(iDissloveTex, vUv);
  if((DissloveTex.r - iClip) < 0.) {
    discard;
  }
  float dissloveValue = clamp(customSmoothstep(iClip, iClip + .1, DissloveTex.r), 0., 1.);
  vec4 RamTex = texture2D(iRamTex, vec2(dissloveValue));
  vec4 Tex = texture2D(iChannel1, vUv);
  // vec4 col = Tex + RamTex;

  c = vec3(clamp(Tex.rbg * c * instensity,0.,1.));
  // col.a = Tex.a;
  gl_FragColor = vec4(c,fresnel);
}