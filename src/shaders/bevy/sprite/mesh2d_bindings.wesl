import package::sprite::mesh2d_types::Mesh2d;

@if(PER_OBJECT_BUFFER_BATCH_SIZE)
@group(1) @binding(0) var<uniform> mesh: array<Mesh2d, u32(constants::PER_OBJECT_BUFFER_BATCH_SIZE)>;
@else
@group(1) @binding(0) var<storage> mesh: array<Mesh2d>;
