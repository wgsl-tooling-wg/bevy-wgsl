# `bevy-wgsl` - Bevy shaders in a WESL package

This package contains all Bevy shaders converted to [WESL].

WESL packages can be used in your shader projects like any other Rust crates.
See the [example] to get started.

See the shader documentation by @jannik4 [here](https://jannik4.github.io/shader_docs/bevy/latest/bevy/index.html).

---

This is an early release that may contain bugs! Help use improve it by opening issues or reaching us on Bevy and WESL Discord servers.

[WESL]: https://wesl-lang.dev
[example]: https://github.com/wgsl-tooling-wg/bevy-wgsl/tree/main/examples/consumer


## List of feature flags
```
ALPHA_TO_COVERAGE                                  
AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3            workaround while WESL doesn't support comparisons
AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_6            workaround while WESL doesn't support comparisons
BINDLESS                                           
BLEND_MULTIPLY                                     
BLEND_PREMULTIPLIED_ALPHA                          
CLUSTERED_DECALS_ARE_USABLE                        
CLUSTERED_FORWARD_DEBUG_CLUSTER_COHERENCY          
CLUSTERED_FORWARD_DEBUG_CLUSTER_COMPLEXITY         
CLUSTERED_FORWARD_DEBUG_Z_SLICES                   
DEBAND_DITHER                                      
DEFERRED_PREPASS                                   
DEPTH_PREPASS                                      
DIRECTIONAL_LIGHT_SHADOW_MAP_DEBUG_CASCADES        
DISTANCE_FOG                                       
ENVIRONMENT_MAP                                    
HUE_ROTATE                                         
IRRADIANCE_VOLUME                                  
IRRADIANCE_VOLUMES_ARE_USABLE                      
LIGHTMAP                                           
LIGHTMAP_BICUBIC_SAMPLING                          
LOAD_PREPASS_NORMALS                               
MAY_DISCARD                                        
MESHLET_CULLING_PASS                               
MESHLET_FILL_CLUSTER_BUFFERS_PASS                  
MESHLET_MESH_MATERIAL_PASS                         
MESHLET_VISIBILITY_BUFFER_RASTER_PASS              
MORPH_TARGETS                                      
MOTION_VECTOR_PREPASS                              
MULTIPLE_LIGHT_PROBES_IN_ARRAY                     
MULTIPLE_LIGHTMAPS_IN_ARRAY                        
MULTISAMPLED                                       
NO_ARRAY_TEXTURES_SUPPORT                          
NO_CUBE_ARRAY_TEXTURES_SUPPORT                     
NORMAL_PREPASS                                     
NORMAL_PREPASS_OR_DEFERRED_PREPASS                 
OIT_ENABLED                                        
PCSS_SAMPLERS_AVAILABLE                            
PER_OBJECT_BUFFER_BATCH_SIZE                       
PREMULTIPLY_ALPHA                                  
PREPASS_FRAGMENT                                   
PREPASS_PIPELINE                                   
RELIEF_MAPPING                                     
SCREEN_SPACE_AMBIENT_OCCLUSION                     
SCREEN_SPACE_REFLECTIONS                           
SCREEN_SPACE_SPECULAR_TRANSMISSION_BLUR_TAPS       
SECTIONAL_COLOR_GRADING                            
SHADOW_FILTER_METHOD_GAUSSIAN                      
SHADOW_FILTER_METHOD_HARDWARE_2X2                  
SHADOW_FILTER_METHOD_TEMPORAL                      
SIXTEEN_BYTE_ALIGNMENT                             
SKINNED                                            
SKINS_USE_UNIFORM_BUFFERS                          
STANDARD_MATERIAL_ANISOTROPY                       
STANDARD_MATERIAL_ANISOTROPY_MAP_UV_B              
STANDARD_MATERIAL_BASE_COLOR_UV_B                  
STANDARD_MATERIAL_CLEARCOAT                        
STANDARD_MATERIAL_CLEARCOAT_NORMAL_MAP_UV_B        
STANDARD_MATERIAL_CLEARCOAT_ROUGHNESS_UV_B         
STANDARD_MATERIAL_CLEARCOAT_UV_B                   
STANDARD_MATERIAL_DIFFUSE_OR_SPECULAR_TRANSMISSION 
STANDARD_MATERIAL_DIFFUSE_TRANSMISSION             
STANDARD_MATERIAL_DIFFUSE_TRANSMISSION_UV_B        
STANDARD_MATERIAL_EMISSIVE_UV_B                    
STANDARD_MATERIAL_METALLIC_ROUGHNESS_UV_B          
STANDARD_MATERIAL_NORMAL_MAP                       
STANDARD_MATERIAL_NORMAL_MAP_UV_B                  
STANDARD_MATERIAL_OCCLUSION_UV_B                   
STANDARD_MATERIAL_SPECULAR_TINT_UV_B               
STANDARD_MATERIAL_SPECULAR_TRANSMISSION            
STANDARD_MATERIAL_SPECULAR_TRANSMISSION_UV_B       
STANDARD_MATERIAL_SPECULAR_UV_B                    
STANDARD_MATERIAL_THICKNESS_UV_B                   
TEMPORAL_JITTER                                    
TONEMAP_IN_SHADER                                  
TONEMAP_METHOD_ACES_FITTED                         
TONEMAP_METHOD_AGX                                 
TONEMAP_METHOD_BLENDER_FILMIC                      
TONEMAP_METHOD_NONE                                
TONEMAP_METHOD_REINHARD                            
TONEMAP_METHOD_REINHARD_LUMINANCE                  
TONEMAP_METHOD_SOMEWHAT_BORING_DISPLAY_TRANSFORM   
TONEMAP_METHOD_TONY_MC_MAPFACE                     
UNCLIPPED_DEPTH_ORTHO_EMULATION                    
VERTEX_COLORS                                      
VERTEX_NORMALS                                     
VERTEX_OUTPUT_INSTANCE_INDEX                       
VERTEX_POSITIONS                                   
VERTEX_TANGENTS                                    
VERTEX_UVS                                         
VERTEX_UVS_A                                       
VERTEX_UVS_B                                       
VIEW_PROJECTION_ORTHOGRAPHIC                       
VIEW_PROJECTION_PERSPECTIVE                        
VISIBILITY_RANGE_DITHER                            
WEBGL2                                             
WHITE_BALANCE                                      
WRITE_INDIRECT_PARAMETERS_METADATA                 
```

```
bevy::core_pipeline::tonemapping              HUE_ROTATE
bevy::core_pipeline::tonemapping              SECTIONAL_COLOR_GRADING
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_ACES_FITTED
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_AGX
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_BLENDER_FILMIC
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_NONE
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_REINHARD
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_REINHARD_LUMINANCE
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_SOMEWHAT_BORING_DISPLAY_TRANSFORM
bevy::core_pipeline::tonemapping              TONEMAP_METHOD_TONY_MC_MAPFACE
bevy::core_pipeline::tonemapping              WHITE_BALANCE
bevy::pbr::clustered_forward                  AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3
bevy::pbr::clustered_forward                  CLUSTERED_FORWARD_DEBUG_CLUSTER_COHERENCY
bevy::pbr::clustered_forward                  CLUSTERED_FORWARD_DEBUG_CLUSTER_COMPLEXITY
bevy::pbr::clustered_forward                  CLUSTERED_FORWARD_DEBUG_Z_SLICES
bevy::pbr::decal::clustered                   CLUSTERED_DECALS_ARE_USABLE
bevy::pbr::environment_map                    LIGHTMAP
bevy::pbr::environment_map                    MULTIPLE_LIGHT_PROBES_IN_ARRAY
bevy::pbr::environment_map                    STANDARD_MATERIAL_CLEARCOAT
bevy::pbr::forward_io                         MORPH_TARGETS
bevy::pbr::forward_io                         SKINNED
bevy::pbr::forward_io                         VERTEX_COLORS
bevy::pbr::forward_io                         VERTEX_NORMALS
bevy::pbr::forward_io                         VERTEX_OUTPUT_INSTANCE_INDEX
bevy::pbr::forward_io                         VERTEX_POSITIONS
bevy::pbr::forward_io                         VERTEX_TANGENTS
bevy::pbr::forward_io                         VERTEX_UVS_A
bevy::pbr::forward_io                         VERTEX_UVS_B
bevy::pbr::forward_io                         VISIBILITY_RANGE_DITHER
bevy::pbr::irradiance_volume                  IRRADIANCE_VOLUMES_ARE_USABLE
bevy::pbr::irradiance_volume                  LIGHTMAP
bevy::pbr::irradiance_volume                  MULTIPLE_LIGHT_PROBES_IN_ARRAY
bevy::pbr::light_probe                        AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3
bevy::pbr::lighting                           STANDARD_MATERIAL_ANISOTROPY
bevy::pbr::lighting                           STANDARD_MATERIAL_CLEARCOAT
bevy::pbr::lightmap                           LIGHTMAP_BICUBIC_SAMPLING
bevy::pbr::lightmap                           MULTIPLE_LIGHTMAPS_IN_ARRAY
bevy::pbr::mesh_functions                     AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_6
bevy::pbr::mesh_functions                     VISIBILITY_RANGE_DITHER
bevy::pbr::mesh_preprocess_types              WRITE_INDIRECT_PARAMETERS_METADATA
bevy::pbr::mesh_types                         MORPH_TARGETS
bevy::pbr::mesh_types                         SKINNED
bevy::pbr::mesh_view_bindings                 AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3
bevy::pbr::mesh_view_bindings                 AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_6
bevy::pbr::mesh_view_bindings                 CLUSTERED_DECALS_ARE_USABLE
bevy::pbr::mesh_view_bindings                 DEFERRED_PREPASS
bevy::pbr::mesh_view_bindings                 IRRADIANCE_VOLUMES_ARE_USABLE
bevy::pbr::mesh_view_bindings                 MULTIPLE_LIGHT_PROBES_IN_ARRAY
bevy::pbr::mesh_view_bindings                 NO_ARRAY_TEXTURES_SUPPORT
bevy::pbr::mesh_view_bindings                 NO_CUBE_ARRAY_TEXTURES_SUPPORT
bevy::pbr::mesh_view_bindings                 OIT_ENABLED
bevy::pbr::mesh_view_bindings                 PCSS_SAMPLERS_AVAILABLE
bevy::pbr::mesh_view_types                    AVAILABLE_STORAGE_BUFFER_BINDINGS__GE_3
bevy::pbr::meshlet_bindings                   MESHLET_CULLING_PASS
bevy::pbr::meshlet_bindings                   MESHLET_FILL_CLUSTER_BUFFERS_PASS
bevy::pbr::meshlet_bindings                   MESHLET_MESH_MATERIAL_PASS
bevy::pbr::meshlet_bindings                   MESHLET_VISIBILITY_BUFFER_RASTER_PASS
bevy::pbr::meshlet_visibility_buffer_resolve  MESHLET_MESH_MATERIAL_PASS
bevy::pbr::parallax_mapping                   BINDLESS
bevy::pbr::parallax_mapping                   RELIEF_MAPPING
bevy::pbr::pbr_bindings                       BINDLESS
bevy::pbr::pbr_deferred_functions             MESHLET_MESH_MATERIAL_PASS
bevy::pbr::pbr_deferred_functions             MOTION_VECTOR_PREPASS
bevy::pbr::pbr_deferred_functions             NORMAL_PREPASS
bevy::pbr::pbr_deferred_functions             PREPASS_PIPELINE
bevy::pbr::pbr_deferred_functions             WEBGL2
bevy::pbr::pbr_fragment                       ALPHA_TO_COVERAGE
bevy::pbr::pbr_fragment                       BINDLESS
bevy::pbr::pbr_fragment                       LIGHTMAP
bevy::pbr::pbr_fragment                       LOAD_PREPASS_NORMALS
bevy::pbr::pbr_fragment                       MESHLET_MESH_MATERIAL_PASS
bevy::pbr::pbr_fragment                       PREPASS_PIPELINE
bevy::pbr::pbr_fragment                       SCREEN_SPACE_AMBIENT_OCCLUSION
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_ANISOTROPY_MAP_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_BASE_COLOR_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_CLEARCOAT_NORMAL_MAP_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_CLEARCOAT_ROUGHNESS_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_CLEARCOAT_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_DIFFUSE_TRANSMISSION_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_EMISSIVE_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_METALLIC_ROUGHNESS_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_NORMAL_MAP
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_NORMAL_MAP_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_OCCLUSION_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_SPECULAR_TINT_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_SPECULAR_TRANSMISSION_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_SPECULAR_UV_B
bevy::pbr::pbr_fragment                       STANDARD_MATERIAL_THICKNESS_UV_B
bevy::pbr::pbr_fragment                       VERTEX_COLORS
bevy::pbr::pbr_fragment                       VERTEX_UVS
bevy::pbr::pbr_fragment                       VERTEX_UVS_A
bevy::pbr::pbr_fragment                       VERTEX_UVS_B
bevy::pbr::pbr_functions                      BLEND_MULTIPLY
bevy::pbr::pbr_functions                      BLEND_PREMULTIPLIED_ALPHA
bevy::pbr::pbr_functions                      DEBAND_DITHER
bevy::pbr::pbr_functions                      DIRECTIONAL_LIGHT_SHADOW_MAP_DEBUG_CASCADES
bevy::pbr::pbr_functions                      DISTANCE_FOG
bevy::pbr::pbr_functions                      ENVIRONMENT_MAP
bevy::pbr::pbr_functions                      IRRADIANCE_VOLUME
bevy::pbr::pbr_functions                      LIGHTMAP
bevy::pbr::pbr_functions                      MAY_DISCARD
bevy::pbr::pbr_functions                      MESHLET_MESH_MATERIAL_PASS
bevy::pbr::pbr_functions                      PREMULTIPLY_ALPHA
bevy::pbr::pbr_functions                      PREPASS_PIPELINE
bevy::pbr::pbr_functions                      SCREEN_SPACE_REFLECTIONS
bevy::pbr::pbr_functions                      STANDARD_MATERIAL_ANISOTROPY
bevy::pbr::pbr_functions                      STANDARD_MATERIAL_CLEARCOAT
bevy::pbr::pbr_functions                      STANDARD_MATERIAL_DIFFUSE_OR_SPECULAR_TRANSMISSION
bevy::pbr::pbr_functions                      STANDARD_MATERIAL_DIFFUSE_TRANSMISSION
bevy::pbr::pbr_functions                      STANDARD_MATERIAL_SPECULAR_TRANSMISSION
bevy::pbr::pbr_functions                      TONEMAP_IN_SHADER
bevy::pbr::pbr_functions                      VISIBILITY_RANGE_DITHER
bevy::pbr::pbr_prepass_functions              BINDLESS
bevy::pbr::pbr_prepass_functions              MOTION_VECTOR_PREPASS
bevy::pbr::pbr_prepass_functions              STANDARD_MATERIAL_BASE_COLOR_UV_B
bevy::pbr::pbr_prepass_functions              VERTEX_UVS
bevy::pbr::prepass_io                         DEFERRED_PREPASS
bevy::pbr::prepass_io                         MORPH_TARGETS
bevy::pbr::prepass_io                         MOTION_VECTOR_PREPASS
bevy::pbr::prepass_io                         NORMAL_PREPASS
bevy::pbr::prepass_io                         NORMAL_PREPASS_OR_DEFERRED_PREPASS
bevy::pbr::prepass_io                         PREPASS_FRAGMENT
bevy::pbr::prepass_io                         SKINNED
bevy::pbr::prepass_io                         UNCLIPPED_DEPTH_ORTHO_EMULATION
bevy::pbr::prepass_io                         VERTEX_COLORS
bevy::pbr::prepass_io                         VERTEX_OUTPUT_INSTANCE_INDEX
bevy::pbr::prepass_io                         VERTEX_UVS_A
bevy::pbr::prepass_io                         VERTEX_UVS_B
bevy::pbr::prepass_io                         VISIBILITY_RANGE_DITHER
bevy::pbr::prepass_utils                      DEPTH_PREPASS
bevy::pbr::prepass_utils                      MOTION_VECTOR_PREPASS
bevy::pbr::prepass_utils                      MULTISAMPLED
bevy::pbr::prepass_utils                      NORMAL_PREPASS
bevy::pbr::shadow_sampling                    NO_ARRAY_TEXTURES_SUPPORT
bevy::pbr::shadow_sampling                    NO_CUBE_ARRAY_TEXTURES_SUPPORT
bevy::pbr::shadow_sampling                    PCSS_SAMPLERS_AVAILABLE
bevy::pbr::shadow_sampling                    SHADOW_FILTER_METHOD_GAUSSIAN
bevy::pbr::shadow_sampling                    SHADOW_FILTER_METHOD_HARDWARE_2X2
bevy::pbr::shadow_sampling                    SHADOW_FILTER_METHOD_TEMPORAL
bevy::pbr::shadow_sampling                    WEBGL2
bevy::pbr::skinning                           SKINS_USE_UNIFORM_BUFFERS
bevy::pbr::ssr                                ENVIRONMENT_MAP
bevy::pbr::ssr                                STANDARD_MATERIAL_CLEARCOAT
bevy::pbr::transmission                       SCREEN_SPACE_SPECULAR_TRANSMISSION_BLUR_TAPS
bevy::pbr::transmission                       TEMPORAL_JITTER
bevy::pbr::transmission                       TONEMAP_IN_SHADER
bevy::pbr::view_transformations               VIEW_PROJECTION_ORTHOGRAPHIC
bevy::pbr::view_transformations               VIEW_PROJECTION_PERSPECTIVE
bevy::render::globals                         SIXTEEN_BYTE_ALIGNMENT
bevy::sprite::mesh2d_bindings                 PER_OBJECT_BUFFER_BATCH_SIZE
bevy::sprite::mesh2d_vertex_output            VERTEX_COLORS
bevy::sprite::mesh2d_vertex_output            VERTEX_TANGENTS
```
