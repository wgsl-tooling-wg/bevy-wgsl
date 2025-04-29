

import bevy::pbr::mesh_types::Mesh;

@if(!MESHLET_MESH_MATERIAL_PASS)
@if(PER_OBJECT_BUFFER_BATCH_SIZE)
@group(1) @binding(0) var<uniform> mesh: array<Mesh, #{PER_OBJECT_BUFFER_BATCH_SIZE}u>;
@else // #else
@group(1) @binding(0) var<storage> mesh: array<Mesh>;
// #endif // PER_OBJECT_BUFFER_BATCH_SIZE
// #endif  // MESHLET_MESH_MATERIAL_PASS
