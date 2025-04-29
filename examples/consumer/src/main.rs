fn main() {
    let source = wesl::Wesl::new("src/shaders")
        .add_package(&bevy_wgsl::bevy::Mod)
        .set_options(wesl::CompileOptions {
            validate: true,
            lower: true,
            // lazy: false,
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
