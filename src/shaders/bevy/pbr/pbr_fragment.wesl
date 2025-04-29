import bevy::render::bindless::{bindless_samplers_filtering, bindless_textures_2d};

import bevy::pbr::{
    pbr_functions,
    pbr_functions::SampleBias,
    pbr_bindings,
    pbr_types,
    prepass_utils,
    lighting,
    mesh_bindings::mesh,
    mesh_view_bindings::view,
    parallax_mapping::parallaxed_uv,
    lightmap::lightmap,
};

@if(SCREEN_SPACE_AMBIENT_OCCLUSION)
import bevy::pbr::mesh_view_bindings::screen_space_ambient_occlusion_texture;
@if(SCREEN_SPACE_AMBIENT_OCCLUSION)
import bevy::pbr::ssao_utils::ssao_multibounce;

@if(MESHLET_MESH_MATERIAL_PASS)
import bevy::pbr::meshlet_visibility_buffer_resolve::VertexOutput;
@elif(PREPASS_PIPELINE)
import bevy::pbr::prepass_io::VertexOutput;
@else
import bevy::pbr::forward_io::VertexOutput;

@if(BINDLESS)
import bevy::pbr::pbr_bindings::material_indices;

// prepare a basic PbrInput from the vertex stage output, mesh binding and view binding
fn pbr_input_from_vertex_output(
    in: VertexOutput,
    is_front: bool,
    double_sided: bool,
) -> pbr_types::PbrInput {
    var pbr_input: pbr_types::PbrInput = pbr_types::pbr_input_new();

    @if(MESHLET_MESH_MATERIAL_PASS) {
        pbr_input.flags = in.mesh_flags;
    }
    @else {
        pbr_input.flags = mesh[in.instance_index].flags;
    }

    pbr_input.is_orthographic = view.clip_from_view[3].w == 1.0;
    pbr_input.V = pbr_functions::calculate_view(in.world_position, pbr_input.is_orthographic);
    pbr_input.frag_coord = in.position;
    pbr_input.world_position = in.world_position;

    @if(VERTEX_COLORS) {
        pbr_input.material.base_color = in.color;
    }

    pbr_input.world_normal = pbr_functions::prepare_world_normal(
        in.world_normal,
        double_sided,
        is_front,
    );

    @if(LOAD_PREPASS_NORMALS) {
        pbr_input.N = prepass_utils::prepass_normal(in.position, 0u);
    }
    @else {
        pbr_input.N = normalize(pbr_input.world_normal);
    }

    return pbr_input;
}

// Prepare a full PbrInput by sampling all textures to resolve
// the material members
fn pbr_input_from_standard_material(
    in: VertexOutput,
    is_front: bool,
) -> pbr_types::PbrInput {
    @if(MESHLET_MESH_MATERIAL_PASS)
    let slot = in.material_bind_group_slot;
    @else
    let slot = mesh[in.instance_index].material_and_lightmap_bind_group_slot & 0xffffu;

    @if(BINDLESS)
    let material = pbr_bindings::material_array[material_indices[slot].material];
    @else
    let material = pbr_bindings::material;

    let double_sided = (material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_DOUBLE_SIDED_BIT) != 0u;

    var pbr_input: pbr_types::PbrInput = pbr_input_from_vertex_output(in, is_front, double_sided);
    pbr_input.material.flags = material.flags;
    pbr_input.material.base_color *= material.base_color;
    pbr_input.material.deferred_lighting_pass_id = material.deferred_lighting_pass_id;

    // Neubelt and Pettineo 2013, "Crafting a Next-gen Material Pipeline for The Order: 1886"
    let NdotV = max(dot(pbr_input.N, pbr_input.V), 0.0001);

    // Fill in the sample bias so we can sample from textures.
    var bias: SampleBias;
    @if(MESHLET_MESH_MATERIAL_PASS) {
        bias.ddx_uv = in.ddx_uv;
        bias.ddy_uv = in.ddy_uv;
    }
    @else {
        bias.mip_bias = view.mip_bias;
    }

    // TODO(mbr): control-flow violation: VERTEX_UVS_A must be set when VERTEX_UVS is set.
    @if(VERTEX_UVS && VERTEX_UVS_A)
    var uv = (material.uv_transform * vec3(in.uv, 1.0)).xy;
    @if(VERTEX_UVS && VERTEX_UVS_B)
    var uv_b = (material.uv_transform * vec3(in.uv_b, 1.0)).xy;
    @elif(VERTEX_UVS)
    var uv_b = uv; // TODO(mbr): control-flow violation here

    // TODO: Transforming UVs mean we need to apply derivative chain rule for meshlet mesh material pass
    @if(VERTEX_UVS && VERTEX_TANGENTS)
    if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_DEPTH_MAP_BIT) != 0u) {
        let V = pbr_input.V;
        let TBN = pbr_functions::calculate_tbn_mikktspace(in.world_normal, in.world_tangent);
        let T = TBN[0];
        let B = TBN[1];
        let N = TBN[2];
        // Transform V from fragment to camera in world space to tangent space.
        let Vt = vec3(dot(V, T), dot(V, B), dot(V, N));

        @if(VERTEX_UVS_A) {
            // TODO: Transforming UVs mean we need to apply derivative chain rule for meshlet mesh material pass
            uv = parallaxed_uv(
                material.parallax_depth_scale,
                material.max_parallax_layer_count,
                material.max_relief_mapping_search_steps,
                uv,
                // Flip the direction of Vt to go toward the surface to make the
                // parallax mapping algorithm easier to understand and reason
                // about.
                -Vt,
                slot,
            );
        }

        @if(VERTEX_UVS_B) {
            // TODO: Transforming UVs mean we need to apply derivative chain rule for meshlet mesh material pass
            uv_b = parallaxed_uv(
                material.parallax_depth_scale,
                material.max_parallax_layer_count,
                material.max_relief_mapping_search_steps,
                uv_b,
                // Flip the direction of Vt to go toward the surface to make the
                // parallax mapping algorithm easier to understand and reason
                // about.
                -Vt,
                slot,
            );
        }
        @else { // TODO(mbr) control-flow violation here too
            uv_b = uv;
        }
    }

    @if(VERTEX_UVS)
    if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_BASE_COLOR_TEXTURE_BIT) != 0u) {
        // TODO(mbr): see refactor here: https://github.com/wgsl-tooling-wg/wesl-spec/issues/63
        @if(BINDLESS)
        let texture = pbr_bindings::base_color_texture[slot];
        @else 
        let texture = pbr_bindings::base_color_texture;

        @if(BINDLESS)
        let sampler = pbr_bindings::base_color_sampler[slot];
        @else
        let sampler = pbr_bindings::base_color_sampler;

        @if(STANDARD_MATERIAL_BASE_COLOR_UV_B)
        let coords = uv_b;
        @else
        let coords = uv;

        @if(MESHLET_MESH_MATERIAL_PASS)
        let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv);
        @else
        let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias);

        pbr_input.material.base_color *= sample;

        @if(ALPHA_TO_COVERAGE) {
            // Sharpen alpha edges.
            //
            // https://bgolus.medium.com/anti-aliased-alpha-test-the-esoteric-alpha-to-coverage-8b177335ae4f
            let alpha_mode = material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_RESERVED_BITS;
            if alpha_mode == pbr_types::STANDARD_MATERIAL_FLAGS_ALPHA_MODE_ALPHA_TO_COVERAGE {
                let alpha = pbr_input.material.base_color.a;
                pbr_input.material.base_color.a = (alpha - material.alpha_cutoff)
                    / max(fwidth(alpha), 0.0001) + 0.5;
            }
        }
    }

    // NOTE: Unlit bit not set means == 0 is true, so the true case is if lit
    if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_UNLIT_BIT) == 0u) {
        pbr_input.material.ior = material.ior;
        pbr_input.material.attenuation_color = material.attenuation_color;
        pbr_input.material.attenuation_distance = material.attenuation_distance;
        pbr_input.material.alpha_cutoff = material.alpha_cutoff;

        // the following material values can be updated by texture sampling below.
        pbr_input.material.reflectance = material.reflectance;
        pbr_input.material.emissive = material.emissive;
        pbr_input.material.metallic = material.metallic;
        pbr_input.material.perceptual_roughness = material.perceptual_roughness;
        pbr_input.material.clearcoat = material.clearcoat;
        pbr_input.material.clearcoat_perceptual_roughness = material.clearcoat_perceptual_roughness;
        // TODO(mbr): in the original code in BINDLESS case there was this: 
        // var specular_transmission: f32 = pbr_bindings::material_array[slot].specular_transmission
        // I suspect this was a bug; should have been:
        // var specular_transmission: f32 = pbr_bindings::material_array[material_indices[slot].material].specular_transmission
        pbr_input.material.specular_transmission = material.specular_transmission;
        pbr_input.material.thickness = material.thickness;
        pbr_input.material.diffuse_transmission = material.diffuse_transmission;
        pbr_input.material.diffuse_occlusion = vec3(1.0);
        pbr_input.material.specular_occlusion = 1.0;

        // Specular texture
        @if(VERTEX_UVS && PBR_SPECULAR_TEXTURES_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_SPECULAR_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].specular_texture];
            @else
            let texture = pbr_bindings::specular_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].specular_sampler];
            @else
            let sampler = pbr_bindings::specular_sampler;

            @if(STANDARD_MATERIAL_SPECULAR_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).a;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).a;

            // This 0.5 factor is from the `KHR_materials_specular` specification:
            // <https://github.com/KhronosGroup/glTF/tree/main/extensions/2.0/Khronos/KHR_materials_specular#materials-with-reflectance-parameter>
            pbr_input.material.reflectance *= sample * 0.5;
        }

        // Specular tint texture
        @if(VERTEX_UVS && PBR_SPECULAR_TEXTURES_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_SPECULAR_TINT_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].specular_tint_texture];
            @else
            let texture = pbr_bindings::specular_tint_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].specular_tint_sampler];
            @else
            let sampler = pbr_bindings::specular_tint_sampler;

            @if(STANDARD_MATERIAL_SPECULAR_TINT_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).rgb;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).rgb;

            pbr_input.material.reflectance *= sample;
        }

        // emissive
        @if(VERTEX_UVS)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_EMISSIVE_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].emissive_texture];
            @else
            let texture = pbr_bindings::emissive_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].emissive_sampler];
            @else
            let sampler = pbr_bindings::emissive_sampler;

            @if(STANDARD_MATERIAL_EMISSIVE_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).rgb;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).rgb;

            pbr_input.material.emissive = vec4<f32>(
                material.emissive.rgb * sample,
                material.emissive.a
            );
        }

        // metallic and perceptual roughness
        let roughness = lighting::perceptualRoughnessToRoughness(material.perceptual_roughness);
        @if(VERTEX_UVS)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_METALLIC_ROUGHNESS_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].metallic_roughness_texture];
            @else
            let texture = pbr_bindings::metallic_roughness_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].metallic_roughness_sampler];
            @else
            let sampler = pbr_bindings::metallic_roughness_sampler;

            @if(STANDARD_MATERIAL_METALLIC_ROUGHNESS_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv);
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias);

            // Sampling from GLTF standard channels for now
            pbr_input.material.metallic *= sample.b;
            pbr_input.material.perceptual_roughness *= sample.g;
        }

        // Clearcoat factor
        @if(VERTEX_UVS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_CLEARCOAT_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].clearcoat_texture];
            @else
            let texture = pbr_bindings::clearcoat_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].clearcoat_sampler];
            @else
            let sampler = pbr_bindings::clearcoat_sampler;

            @if(STANDARD_MATERIAL_CLEARCOAT_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).r;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).r;

            pbr_input.material.clearcoat *= sample;
        }

        // Clearcoat roughness
        @if(VERTEX_UVS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_CLEARCOAT_ROUGHNESS_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].clearcoat_roughness_texture];
            @else
            let texture = pbr_bindings::clearcoat_roughness_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].clearcoat_roughness_sampler];
            @else
            let sampler = pbr_bindings::clearcoat_roughness_sampler;

            @if(STANDARD_MATERIAL_CLEARCOAT_ROUGHNESS_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).r;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).r;

            pbr_input.material.clearcoat_perceptual_roughness *= sample;
        }

        // Specular transmission
        @if(VERTEX_UVS && PBR_TRANSMISSION_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_SPECULAR_TRANSMISSION_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].specular_transmission_texture];
            @else
            let texture = pbr_bindings::specular_transmission_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].specular_transmission_sampler];
            @else
            let sampler = pbr_bindings::specular_transmission_sampler;

            @if(STANDARD_MATERIAL_SPECULAR_TRANSMISSION_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).r;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).r;

            pbr_input.material.specular_transmission *= sample;
        }

        // Thickness
        @if(VERTEX_UVS && PBR_TRANSMISSION_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_THICKNESS_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].thickness_texture];
            @else
            let texture = pbr_bindings::thickness_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].thickness_sampler];
            @else
            let sampler = pbr_bindings::thickness_sampler;

            @if(STANDARD_MATERIAL_THICKNESS_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).g;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).g;

            pbr_input.material.thickness *= sample;
        }

        // scale thickness, accounting for non-uniform scaling (e.g. a “squished” mesh)
        // TODO: Meshlet support
        @if(!MESHLET_MESH_MATERIAL_PASS) {
            pbr_input.material.thickness *= length(
                (transpose(mesh[in.instance_index].world_from_local) * vec4(pbr_input.N, 0.0)).xyz
            );
        }

        // Diffuse transmission
        @if(VERTEX_UVS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_DIFFUSE_TRANSMISSION_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].diffuse_transmission_texture];
            @else
            let texture = pbr_bindings::diffuse_transmission_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].diffuse_transmission_sampler];
            @else
            let sampler = pbr_bindings::diffuse_transmission_sampler;

            @if(STANDARD_MATERIAL_DIFFUSE_TRANSMISSION_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).a;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).a;

            pbr_input.material.diffuse_transmission *= sample;
        }


        // Occlusion
        @if(VERTEX_UVS)
        if ((material.flags & pbr_types::STANDARD_MATERIAL_FLAGS_OCCLUSION_TEXTURE_BIT) != 0u) {
            @if(BINDLESS)
            let texture = bindless_textures_2d[material_indices[slot].occlusion_texture];
            @else
            let texture = pbr_bindings::occlusion_texture;

            @if(BINDLESS)
            let sampler = bindless_samplers_filtering[material_indices[slot].occlusion_sampler];
            @else
            let sampler = pbr_bindings::occlusion_sampler;

            @if(STANDARD_MATERIAL_OCCLUSION_UV_B)
            let coords = uv_b;
            @else
            let coords = uv;

            @if(MESHLET_MESH_MATERIAL_PASS)
            let sample = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).r;
            @else
            let sample = textureSampleBias(texture, sampler, coords, bias.mip_bias).r;

            pbr_input.material.diffuse_occlusion *= sample;
        }

        @if(SCREEN_SPACE_AMBIENT_OCCLUSION) {
            let ssao = textureLoad(screen_space_ambient_occlusion_texture, vec2<i32>(in.position.xy), 0i).r;
            let ssao_multibounce = ssao_multibounce(ssao, pbr_input.material.base_color.rgb);
            pbr_input.material.diffuse_occlusion = min(pbr_input.material.diffuse_occlusion, ssao_multibounce);
            // Use SSAO to estimate the specular occlusion.
            // Lagarde and Rousiers 2014, "Moving Frostbite to Physically Based Rendering"
            pbr_input.material.specular_occlusion = saturate(pow(NdotV + ssao, exp2(-16.0 * pbr_input.material.roughness - 1.0)) - 1.0 + ssao);
        }

        // N (normal vector)
        @if(!LOAD_PREPASS_NORMALS) {

            pbr_input.N = normalize(pbr_input.world_normal);
            pbr_input.clearcoat_N = pbr_input.N;

            @if(VERTEX_UVS && VERTEX_TANGENTS) {
                let TBN = pbr_functions::calculate_tbn_mikktspace(pbr_input.world_normal, in.world_tangent);

                @if(STANDARD_MATERIAL_NORMAL_MAP) {
                    @if(BINDLESS)
                    let texture = bindless_textures_2d[material_indices[slot].normal_map_texture];
                    @else
                    let texture = pbr_bindings::normal_map_texture;

                    @if(BINDLESS)
                    let sampler = bindless_samplers_filtering[material_indices[slot].normal_map_sampler];
                    @else
                    let sampler = pbr_bindings::normal_map_sampler;

                    @if(STANDARD_MATERIAL_NORMAL_MAP_UV_B)
                    let coords = uv_b;
                    @else
                    let coords = uv;

                    @if(MESHLET_MESH_MATERIAL_PASS)
                    let Nt = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).rgb;
                    @else
                    let Nt = textureSampleBias(texture, sampler, coords, bias.mip_bias).rgb;

                    pbr_input.N = pbr_functions::apply_normal_mapping(material.flags, TBN, double_sided, is_front, Nt);
                } // NORMAL_MAP
                
                @if(STANDARD_MATERIAL_CLEARCOAT && STANDARD_MATERIAL_CLEARCOAT_NORMAL_MAP) {
                    // Note: `KHR_materials_clearcoat` specifies that, if there's no
                    // clearcoat normal map, we must set the normal to the mesh's normal,
                    // and not to the main layer's bumped normal.

                    @if(BINDLESS)
                    let texture = bindless_textures_2d[material_indices[slot].clearcoat_normal_texture];
                    @else
                    let texture = pbr_bindings::clearcoat_normal_texture;

                    @if(BINDLESS)
                    let sampler = bindless_samplers_filtering[material_indices[slot].clearcoat_normal_sampler];
                    @else
                    let sampler = pbr_bindings::clearcoat_normal_sampler;

                    @if(STANDARD_MATERIAL_CLEARCOAT_NORMAL_MAP_UV_B)
                    let coords = uv_b;
                    @else
                    let coords = uv;

                    @if(MESHLET_MESH_MATERIAL_PASS)
                    let clearcoat_Nt = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).rgb;
                    @else
                    let clearcoat_Nt = textureSampleBias(texture, sampler, coords, bias.mip_bias).rgb;

                    pbr_input.clearcoat_N = pbr_functions::apply_normal_mapping(
                        material.flags,
                        TBN,
                        double_sided,
                        is_front,
                        clearcoat_Nt,
                    );
                }

            } // VERTEX_UVS && VERTEX_TANGENTS

            // Take anisotropy into account.
            //
            // This code comes from the `KHR_materials_anisotropy` spec:
            // <https://github.com/KhronosGroup/glTF/blob/main/extensions/2.0/Khronos/KHR_materials_anisotropy/README.md#individual-lights>
            // Adjust based on the anisotropy map if there is one.
            @if(PBR_ANISOTROPY_TEXTURE_SUPPORTED && VERTEX_TANGENTS && STANDARD_MATERIAL_ANISOTROPY) {
                var anisotropy_strength = material.anisotropy_strength;
                var anisotropy_direction = material.anisotropy_rotation;
                
                if ((flags & pbr_types::STANDARD_MATERIAL_FLAGS_ANISOTROPY_TEXTURE_BIT) != 0u) {
                    @if(BINDLESS)
                    let texture = bindless_textures_2d[material_indices[slot].anisotropy_texture];
                    @else
                    let texture = pbr_bindings::anisotropy_texture;

                    @if(BINDLESS)
                    let sampler = bindless_samplers_filtering[material_indices[slot].anisotropy_sampler];
                    @else
                    let sampler = pbr_bindings::anisotropy_sampler;

                    @if(STANDARD_MATERIAL_ANISOTROPY_MAP_UV_B)
                    let coords = uv_b;
                    @else
                    let coords = uv;

                    @if(MESHLET_MESH_MATERIAL_PASS)
                    let anisotropy_texel = textureSampleGrad(texture, sampler, coords, bias.ddx_uv, bias.ddy_uv).rgb;
                    @else
                    let anisotropy_texel = textureSampleBias(texture, sampler, coords, bias.mip_bias).rgb;

                    let anisotropy_direction_from_texture = normalize(anisotropy_texel.rg * 2.0 - 1.0);
                    // Rotate by the anisotropy direction.
                    anisotropy_direction =
                        mat2x2(anisotropy_direction.xy, anisotropy_direction.yx * vec2(-1.0, 1.0)) *
                        anisotropy_direction_from_texture;
                    anisotropy_strength *= anisotropy_texel.b;
                }

                pbr_input.anisotropy_strength = anisotropy_strength;

                let anisotropy_T = normalize(TBN * vec3(anisotropy_direction, 0.0));
                let anisotropy_B = normalize(cross(pbr_input.world_normal, anisotropy_T));
                pbr_input.anisotropy_T = anisotropy_T;
                pbr_input.anisotropy_B = anisotropy_B;
            }
        } // @if(!LOAD_PREPASS_NORMALS)

        // TODO: Meshlet support
        @if(LIGHTMAP) {
            pbr_input.lightmap_light = lightmap(in.uv_b, material.lightmap_exposure, in.instance_index);
        }
    }

    return pbr_input;
}
