/* 
边缘高光
 */
varying vec3 normal_pos;
varying vec3 modelToCameraDir;
varying vec2 vUv;
uniform sampler2D uTex;
uniform float uTime;

void main() {
  vec3 dir = normalize(modelToCameraDir);
  vec3 nor = normalize(normal_pos);
  float NdotV = clamp(dot(dir, nor), 0., 1.);
  float alpha = 1. - NdotV;
  float emiss = 3.5;

  float fresnel = pow(alpha, emiss);

  vec3 col = vec3(1., 1., 0.);

  vec2 nuv = vUv;

  float instensity = 2.;

  nuv.y = fract(nuv.y + uTime * .3);

  vec4 tex = texture2D(uTex, nuv);

  col = vec3(clamp(tex.rbg * col * instensity,0.,1.));

  vec4 color = vec4(col, fresnel);

  gl_FragColor = color;

}