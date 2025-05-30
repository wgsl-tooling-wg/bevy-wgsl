import bevy::pbr::mesh_view_types as types;
import bevy::render::{
    view::View,
    globals::Globals,
};

@group(0) @binding(0) var<uniform> view: View;
@group(0) @binding(1) var<uniform> lights: types::Lights;

@if(NO_CUBE_ARRAY_TEXTURES_SUPPORT)
@group(0) @binding(2) var point_shadow_textures: texture_depth_cube;
@else
@group(0) @binding(2) var point_shadow_textures: texture_depth_cube_array;

@group(0) @binding(3) var point_shadow_textures_comparison_sampler: sampler_comparison;

@if(PCSS_SAMPLERS_AVAILABLE)
@group(0) @binding(4) var point_shadow_textures_linear_sampler: sampler;

@if(NO_ARRAY_TEXTURES_SUPPORT)
@group(0) @binding(5) var directional_shadow_textures: texture_depth_2d;
@else
@group(0) @binding(5) var directional_shadow_textures: texture_depth_2d_array;

@group(0) @binding(6) var directional_shadow_textures_comparison_sampler: sampler_comparison;

@if(PCSS_SAMPLERS_AVAILABLE)
@group(0) @binding(7) var directional_shadow_textures_linear_sampler: sampler;

@if(AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3)
@group(0) @binding(8) var<storage> clusterable_objects: types::ClusterableObjects;
@else
@group(0) @binding(8) var<uniform> clusterable_objects: types::ClusterableObjects;

@if(AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3)
@group(0) @binding(9) var<storage> clusterable_object_index_lists: types::ClusterLightIndexLists;
@else
@group(0) @binding(9) var<uniform> clusterable_object_index_lists: types::ClusterLightIndexLists;

@if(AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3)
@group(0) @binding(10) var<storage> cluster_offsets_and_counts: types::ClusterOffsetsAndCounts;
@else
@group(0) @binding(10) var<uniform> cluster_offsets_and_counts: types::ClusterOffsetsAndCounts;

@group(0) @binding(11) var<uniform> globals: Globals;
@group(0) @binding(12) var<uniform> fog: types::Fog;
@group(0) @binding(13) var<uniform> light_probes: types::LightProbes;

const VISIBILITY_RANGE_UNIFORM_BUFFER_SIZE: u32 = 64u;
@if(AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_6)
@group(0) @binding(14) var<storage> visibility_ranges: array<vec4<f32>>;
@else
@group(0) @binding(14) var<uniform> visibility_ranges: array<vec4<f32>, VISIBILITY_RANGE_UNIFORM_BUFFER_SIZE>;

@group(0) @binding(15) var<uniform> ssr_settings: types::ScreenSpaceReflectionsSettings;
@group(0) @binding(16) var screen_space_ambient_occlusion_texture: texture_2d<f32>;

@if(MULTIPLE_LIGHT_PROBES_IN_ARRAY)
@group(0) @binding(17) var diffuse_environment_maps: binding_array<texture_cube<f32>, 8u>;
@else
@group(0) @binding(17) var diffuse_environment_map: texture_cube<f32>;

@if(MULTIPLE_LIGHT_PROBES_IN_ARRAY)
@group(0) @binding(18) var specular_environment_maps: binding_array<texture_cube<f32>, 8u>;
@else
@group(0) @binding(18) var specular_environment_map: texture_cube<f32>;

@group(0) @binding(19) var environment_map_sampler: sampler;
@group(0) @binding(20) var<uniform> environment_map_uniform: types::EnvironmentMapUniform;

@if(IRRADIANCE_VOLUMES_ARE_USABLE && MULTIPLE_LIGHT_PROBES_IN_ARRAY)
@group(0) @binding(21) var irradiance_volumes: binding_array<texture_3d<f32>, 8u>;
@elif(IRRADIANCE_VOLUMES_ARE_USABLE)
@group(0) @binding(21) var irradiance_volume: texture_3d<f32>;
@if(IRRADIANCE_VOLUMES_ARE_USABLE)
@group(0) @binding(22) var irradiance_volume_sampler: sampler;

@if(CLUSTERED_DECALS_ARE_USABLE)
@group(0) @binding(23) var<storage> clustered_decals: types::ClusteredDecals;

@if(CLUSTERED_DECALS_ARE_USABLE)
@group(0) @binding(24) var clustered_decal_textures: binding_array<texture_2d<f32>, 8u>;

@if(CLUSTERED_DECALS_ARE_USABLE)
@group(0) @binding(25) var clustered_decal_sampler: sampler;

// NB: If you change these, make sure to update `tonemapping_shared.wgsl` too.
@group(0) @binding(26) var dt_lut_texture: texture_3d<f32>;
@group(0) @binding(27) var dt_lut_sampler: sampler;

@if(MULTISAMPLED && DEPTH_PREPASS)
@group(0) @binding(28) var depth_prepass_texture: texture_depth_multisampled_2d;

@if(MULTISAMPLED && NORMAL_PREPASS)
@group(0) @binding(29) var normal_prepass_texture: texture_multisampled_2d<f32>;

@if(MULTISAMPLED && MOTION_VECTOR_PREPASS)
@group(0) @binding(30) var motion_vector_prepass_texture: texture_multisampled_2d<f32>;

@if(!MULTISAMPLED && DEPTH_PREPASS)
@group(0) @binding(28) var depth_prepass_texture: texture_depth_2d;

@if(!MULTISAMPLED && NORMAL_PREPASS)
@group(0) @binding(29) var normal_prepass_texture: texture_2d<f32>;

@if(!MULTISAMPLED && MOTION_VECTOR_PREPASS)
@group(0) @binding(30) var motion_vector_prepass_texture: texture_2d<f32>;

@if(DEFERRED_PREPASS)
@group(0) @binding(31) var deferred_prepass_texture: texture_2d<u32>;

@group(0) @binding(32) var view_transmission_texture: texture_2d<f32>;
@group(0) @binding(33) var view_transmission_sampler: sampler;

@if(OIT_ENABLED)
@group(0) @binding(34) var<storage, read_write> oit_layers: array<vec2<u32>>;
@if(OIT_ENABLED)
@group(0) @binding(35) var<storage, read_write> oit_layer_ids: array<atomic<i32>>;
@if(OIT_ENABLED)
@group(0) @binding(36) var<uniform> oit_settings: types::OrderIndependentTransparencySettings;
