uniform sampler2D uMatcap;
uniform sampler2D uMatcapAdd;
uniform sampler2D uDiffuse;
uniform sampler2D uRamTex;
uniform float uMatcapIntensity;
uniform float uMatcapAddIntensity;
varying float fresnel;
varying vec3 normal_viewspace;
varying vec2 vUv;

void main() {
  vec3 normal_view = normalize(normal_viewspace);
  vec2 matcapUV = (normal_view.xy + 1.) * .5;
  vec2 RamTexuv = vec2(fresnel, .5);
  vec4 MainTexColor = texture2D(uDiffuse, vUv);
  vec4 RamTexColor = texture2D(uRamTex, RamTexuv);
  vec4 MatcapTexColor = texture2D(uMatcap, matcapUV) * uMatcapIntensity;
  vec4 MatcapAddTexColor = texture2D(uMatcapAdd, matcapUV) * uMatcapAddIntensity;
  vec4 col = MatcapTexColor * MainTexColor * RamTexColor + MatcapAddTexColor;
  gl_FragColor = col;
}