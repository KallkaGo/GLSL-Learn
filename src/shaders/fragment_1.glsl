#define TWO_PI 6.28318530718
#define PI 3.14159265359

uniform float iTime;
uniform vec3 iResolution;
uniform sampler2D iChannel0;

varying vec2 vUv;

float noise(vec2 p) {
  return texture(iChannel0, p * 0.05).x;
}

float fbm(vec2 p) {
  float a = 1.;
  float f = 1.;
  return a * noise(p) + a * 0.5 * noise(p * f * 2.) + a * 0.25 * noise(p * f * 4.) + a * 0.1 * noise(p * f * 8.);
}

float circle(vec2 p) {
  float r = length(p);
  float radius = 0.4;
  float height = 1.;
  float width = 150.;
  //即 height/width = pow(r - radius,2.0) 所以出现了线圈
  return height - pow(r - radius, 2.) * width;
}

void main() {

  vec2 uv = (gl_FragCoord.xy - .5 * iResolution.xy) / iResolution.y;

  uv = vUv - .5;

  vec2 st = vec2(atan(uv.y, uv.x), length(uv) * 1. + iTime * 0.1);

  st.x += st.y * 1.1;// - iTime * 0.3;
  st.x = mod(st.x, TWO_PI);

  float n = fbm(st) * 1.5 - 1.;
  n = max(n, 0.1);
  float circle = max(1. - circle(uv), 0.);

  float color = n / circle;
  float mask = smoothstep(0.48, 0.02, length(uv));

  color *= mask;
  vec3 rez = vec3(1., 0.5, 0.25) * color;
    // Output to screen
  gl_FragColor = vec4(rez, 1.0);
}