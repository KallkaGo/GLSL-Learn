varying vec3 pos_world;
varying vec2 vUv;
varying float fresnel;
varying vec3 normal_pos;
varying vec3 modelToCameraDir;
varying vec3 normal_viewspace;

void main() {
    vec4 modelPosition = modelMatrix * vec4(position, 1.);
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectedPosition = projectionMatrix * viewPosition;
    normal_pos = normalize(modelMatrix * vec4(normal, 0.0)).xyz;
    pos_world = modelPosition.xyz;
    normal_viewspace = (modelViewMatrix * vec4(normal, 0.0)).xyz;
    modelToCameraDir = normalize(cameraPosition - pos_world);
    float NdotV = clamp(dot(modelToCameraDir, normal_pos), 0., 1.);
    fresnel = 1. - NdotV;
    vUv = uv;
    gl_Position = projectedPosition;
}