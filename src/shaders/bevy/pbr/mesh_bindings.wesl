import package::pbr::mesh_types::Mesh;

// TODO(mbr): not sure about the else, did it match both if conditions?
@if(!MESHLET_MESH_MATERIAL_PASS && PER_OBJECT_BUFFER_BATCH_SIZE)
@group(1) @binding(0) var<uniform> mesh: array<Mesh, u32(constants::PER_OBJECT_BUFFER_BATCH_SIZE)>;
@else
@group(1) @binding(0) var<storage> mesh: array<Mesh>;
