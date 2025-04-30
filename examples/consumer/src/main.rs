use std::collections::HashMap;

use wesl::Feature;

fn main() {
    let source = wesl::Wesl::new("src/shaders")
        .add_package(&bevy_wgsl::bevy::Mod)
        .add_constants([
            ("MAX_CASCADES_PER_LIGHT", 10.0),
            ("MAX_DIRECTIONAL_LIGHTS", 10.0),
            ("PER_OBJECT_BUFFER_BATCH_SIZE", 10.0),
        ])
        .set_options(wesl::CompileOptions {
            validate: true,
            lower: true,
            lazy: false,
            strip: false,
            features: wesl::Features {
                default: Feature::Enable,
                flags: HashMap::from_iter([(
                    "MESHLET_MESH_MATERIAL_PASS".to_string(),
                    Feature::Disable,
                )]),
            },
            ..Default::default()
        })
        .compile("main")
        .inspect_err(|e| {
            eprintln!("{e}");
            panic!();
        })
        .unwrap()
        .to_string();

    println!("{source}")
}
