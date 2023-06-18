varying vec3 normal_pos;
varying vec3 pos_world;
uniform vec3 uCameraPos;
void main() {
  vec3 normalWorld = normalize(normal_pos);
  vec3 viewWorld = normalize(uCameraPos - pos_world);
  float NdotV = clamp(dot(normalWorld, viewWorld), 0., 1.);
  float alpha = 1. - NdotV;
  float emiss = 1.5;


  float fresnel = clamp(pow(alpha, emiss),0.,1.);

  vec3 col = vec3(1., 1., 0.);

  vec4 color = vec4(col, fresnel);

  gl_FragColor = color;

}