uniform float uGrowMin;
uniform float uGrowMax;
uniform float uEndMin;
uniform float uEndMax;
uniform float uExpand;
uniform float uScale;
uniform float uGrow;
varying vec2 vUv;

void main() {
  float weight_expand = smoothstep(uGrowMin, uGrowMax, (uv.y - uGrow));
  float weight_end = smoothstep(uEndMin, uEndMax, uv.y);
  float weight_combiend = max(weight_expand, weight_end);
  vec3 vertex_offset = normalize(normal) * uExpand * 0.05 * weight_combiend;
  vec3 vertex_scale = normalize(normal) * uScale * 0.01;
  vec3 finalOffset = vertex_offset + vertex_scale;
  vec3 pos = position + finalOffset;

  vec4 modelPosition = modelMatrix * vec4(pos, 1.);
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;
  vUv = uv;
}