@if(BINDLESS)
import package::render::bindless::{bindless_samplers_filtering, bindless_textures_2d};

import package::pbr::{
    prepass_io::VertexOutput,
    prepass_bindings::previous_view_uniforms,
    mesh_bindings::mesh,
    mesh_view_bindings::view,
    pbr_bindings,
    pbr_types,
};

@if(BINDLESS)
import package::pbr::pbr_bindings::material_indices;

// Cutoff used for the premultiplied alpha modes BLEND, ADD, and ALPHA_TO_COVERAGE.
const PREMULTIPLIED_ALPHA_CUTOFF = 0.05;

// We can use a simplified version of alpha_discard() here since we only need to handle the alpha_cutoff
fn prepass_alpha_discard(in: VertexOutput) {
    @if(!MAY_DISCARD)
    return;

    @if(BINDLESS)
    let slot = mesh[in.instance_index].material_and_lightmap_bind_group_slot & 0xffffu;

    @if(BINDLESS)
    var output_color: vec4<f32> = pbr_bindings::material_array[material_indices[slot].material].base_color;
    @else
    var output_color: vec4<f32> = pbr_bindings::material.base_color;

    @if(BINDLESS)
    let flags = pbr_bindings::material_array[material_indices[slot].material].flags;
    @else
    let flags = pbr_bindings::material.flags;

    @if(VERTEX_UVS) {
        @if(STANDARD_MATERIAL_BASE_COLOR_UV_B)
        var uv = in.uv_b;
        @else
        var uv = in.uv;

        @if(BINDLESS)
        let uv_transform = pbr_bindings::material_array[material_indices[slot].material].uv_transform;
        @else
        let uv_transform = pbr_bindings::material.uv_transform;

        uv = (uv_transform * vec3(uv, 1.0)).xy;
        if (flags & pbr_types::STANDARD_MATERIAL_FLAGS_BASE_COLOR_TEXTURE_BIT) != 0u {
            @if(BINDLESS) {
                output_color = output_color * textureSampleBias(
                    bindless_textures_2d[material_indices[slot].base_color_texture],
                    bindless_samplers_filtering[material_indices[slot].base_color_sampler],
                    uv,
                    view.mip_bias
                );
            }
            @else {
                output_color = output_color * textureSampleBias(
                    pbr_bindings::base_color_texture,
                    pbr_bindings::base_color_sampler,
                    uv,
                    view.mip_bias
                );
            }
        }
    }

    let alpha_mode = flags & pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_RESERVED_BITS;
    if alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_MASK {
        @if(BINDLESS)
        let alpha_cutoff = pbr_bindings::material_array[material_indices[slot].material].alpha_cutoff;
        @else
        let alpha_cutoff = pbr_bindings::material.alpha_cutoff;

        if output_color.a < alpha_cutoff {
            discard;
        }
    } else if (alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_BLEND ||
            alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_ADD ||
            alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_ALPHA_TO_COVERAGE) {
        if output_color.a < PREMULTIPLIED_ALPHA_CUTOFF {
            discard;
        }
    } else if alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_PREMULTIPLIED {
        if all(output_color < vec4(PREMULTIPLIED_ALPHA_CUTOFF)) {
            discard;
        }
    }
}

@if(MOTION_VECTOR_PREPASS)
fn calculate_motion_vector(world_position: vec4<f32>, previous_world_position: vec4<f32>) -> vec2<f32> {
    let clip_position_t = view.unjittered_clip_from_world * world_position;
    let clip_position = clip_position_t.xy / clip_position_t.w;
    let previous_clip_position_t = previous_view_uniforms.clip_from_world * previous_world_position;
    let previous_clip_position = previous_clip_position_t.xy / previous_clip_position_t.w;
    // These motion vectors are used as offsets to UV positions and are stored
    // in the range -1,1 to allow offsetting from the one corner to the
    // diagonally-opposite corner in UV coordinates, in either direction.
    // A difference between diagonally-opposite corners of clip space is in the
    // range -2,2, so this needs to be scaled by 0.5. And the V direction goes
    // down where clip space y goes up, so y needs to be flipped.
    return (clip_position - previous_clip_position) * vec2(0.5, -0.5);
}
