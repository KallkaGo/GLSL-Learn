uniform sampler2D iChannel1;
uniform sampler2D iDissloveTex;
uniform sampler2D iRamTex;
uniform float iClip;
varying vec2 vUv;

float customSmoothstep(float min, float max, float x) {
  return (x - min) / (max - min);
}

void main() {
  vec4 DissloveTex = texture2D(iDissloveTex, vUv);
  if((DissloveTex.r - iClip) < 0.) {
    discard;
  }
  float dissloveValue = clamp(customSmoothstep(iClip, iClip + .1, DissloveTex.r), 0., 1.);
  vec4 RamTex = texture2D(iRamTex, vec2(dissloveValue));
  vec4 Tex = texture2D(iChannel1, vUv);
  vec4 col = Tex + RamTex;
  col.a = Tex.a;
  gl_FragColor = col;
}