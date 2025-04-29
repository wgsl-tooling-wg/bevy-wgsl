

import bevy::sprite::mesh2d_types::Mesh2d;

@if(PER_OBJECT_BUFFER_BATCH_SIZE)
@group(1) @binding(0) var<uniform> mesh: array<Mesh2d, #{PER_OBJECT_BUFFER_BATCH_SIZE}u>;
@else // #else
@group(1) @binding(0) var<storage> mesh: array<Mesh2d>;
// #endif // PER_OBJECT_BUFFER_BATCH_SIZE
