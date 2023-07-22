uniform float uGrow;
uniform float uGrowMin;
uniform float uGrowMax;
varying vec2 vUv;
uniform sampler2D uDiffuse;

void main() {
  if((1.0 - (vUv.y - uGrow)) < 0.)
    discard;
  vec4 MainTex = texture2D(uDiffuse, vUv);
  float col = smoothstep(uGrowMin, uGrowMax, (vUv.y - uGrow));
  gl_FragColor = MainTex;
}