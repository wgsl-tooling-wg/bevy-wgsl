

import bevy::pbr::pbr_types::StandardMaterial;

@if(BINDLESS)
struct StandardMaterialBindings {
    material: u32,                      // 0
    base_color_texture: u32,            // 1
    base_color_sampler: u32,            // 2
    emissive_texture: u32,              // 3
    emissive_sampler: u32,              // 4
    metallic_roughness_texture: u32,    // 5
    metallic_roughness_sampler: u32,    // 6
    occlusion_texture: u32,             // 7
    occlusion_sampler: u32,             // 8
    normal_map_texture: u32,            // 9
    normal_map_sampler: u32,            // 10
    depth_map_texture: u32,             // 11
    depth_map_sampler: u32,             // 12
    anisotropy_texture: u32,            // 13
    anisotropy_sampler: u32,            // 14
    specular_transmission_texture: u32, // 15
    specular_transmission_sampler: u32, // 16
    thickness_texture: u32,             // 17
    thickness_sampler: u32,             // 18
    diffuse_transmission_texture: u32,  // 19
    diffuse_transmission_sampler: u32,  // 20
    clearcoat_texture: u32,             // 21
    clearcoat_sampler: u32,             // 22
    clearcoat_roughness_texture: u32,   // 23
    clearcoat_roughness_sampler: u32,   // 24
    clearcoat_normal_texture: u32,      // 25
    clearcoat_normal_sampler: u32,      // 26
    specular_texture: u32,              // 27
    specular_sampler: u32,              // 28
    specular_tint_texture: u32,         // 29
    specular_tint_sampler: u32,         // 30
}

@if(BINDLESS)
@group(2) @binding(0) var<storage> material_indices: array<StandardMaterialBindings>;
@if(BINDLESS)
@group(2) @binding(10) var<storage> material_array: array<StandardMaterial>;

@if(!BINDLESS)
@group(2) @binding(0) var<uniform> material: StandardMaterial;
@if(!BINDLESS)
@group(2) @binding(1) var base_color_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(2) var base_color_sampler: sampler;
@if(!BINDLESS)
@group(2) @binding(3) var emissive_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(4) var emissive_sampler: sampler;
@if(!BINDLESS)
@group(2) @binding(5) var metallic_roughness_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(6) var metallic_roughness_sampler: sampler;
@if(!BINDLESS)
@group(2) @binding(7) var occlusion_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(8) var occlusion_sampler: sampler;
@if(!BINDLESS)
@group(2) @binding(9) var normal_map_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(10) var normal_map_sampler: sampler;
@if(!BINDLESS)
@group(2) @binding(11) var depth_map_texture: texture_2d<f32>;
@if(!BINDLESS)
@group(2) @binding(12) var depth_map_sampler: sampler;

@if(!BINDLESS && PBR_ANISOTROPY_TEXTURE_SUPPORTED)
@group(2) @binding(13) var anisotropy_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_ANISOTROPY_TEXTURE_SUPPORTED)
@group(2) @binding(14) var anisotropy_sampler: sampler;

@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(15) var specular_transmission_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(16) var specular_transmission_sampler: sampler;
@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(17) var thickness_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(18) var thickness_sampler: sampler;
@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(19) var diffuse_transmission_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_TRANSMISSION_TEXTURES_SUPPORTED)
@group(2) @binding(20) var diffuse_transmission_sampler: sampler;

@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(21) var clearcoat_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(22) var clearcoat_sampler: sampler;
@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(23) var clearcoat_roughness_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(24) var clearcoat_roughness_sampler: sampler;
@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(25) var clearcoat_normal_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_MULTI_LAYER_MATERIAL_TEXTURES_SUPPORTED)
@group(2) @binding(26) var clearcoat_normal_sampler: sampler;

@if(!BINDLESS && PBR_SPECULAR_TEXTURES_SUPPORTED)
@group(2) @binding(27) var specular_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_SPECULAR_TEXTURES_SUPPORTED)
@group(2) @binding(28) var specular_sampler: sampler;
@if(!BINDLESS && PBR_SPECULAR_TEXTURES_SUPPORTED)
@group(2) @binding(29) var specular_tint_texture: texture_2d<f32>;
@if(!BINDLESS && PBR_SPECULAR_TEXTURES_SUPPORTED)
@group(2) @binding(30) var specular_tint_sampler: sampler;
