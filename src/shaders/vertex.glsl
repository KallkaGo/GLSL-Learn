varying vec3 pos_world;
varying vec2 vUv;
varying vec3 normal_pos;
varying vec3 modelToCameraDir;

void main() {
    vec4 modelPosition = modelMatrix * vec4(position, 1.);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    normal_pos = normalize(modelMatrix * vec4(normal, 0.0)).xyz;
    pos_world = modelPosition.xyz;
    modelToCameraDir = cameraPosition - pos_world;
    vUv = uv;
    gl_Position = projectedPosition;
}