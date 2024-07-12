#version 450


layout(location = 0) in vec3 inPosition;

layout(location = 1) out vec2 outUV;

void main() {
    gl_Position = vec4(inPosition, 1.0);
    outUV = inPosition.xy * 0.5; // Assuming the XY components are your UVs
}