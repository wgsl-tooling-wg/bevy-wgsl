struct VertexOutput {
    // this is `clip position` when the struct is used as a vertex stage output 
    // and `frag coord` when used as a fragment stage input
    @builtin(position) position: vec4<f32>,
    @location(0) world_position: vec4<f32>,
    @location(1) world_normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
    @if(VERTEX_TANGENTS)
    @location(3) world_tangent: vec4<f32>,
    @if(VERTEX_COLORS)
    @location(4) color: vec4<f32>,
}
