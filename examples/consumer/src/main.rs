fn main() {
    let source = wesl::Wesl::new("src/shaders")
        .add_package(&bevy_wgsl::bevy::Mod)
        .compile("main")
        .inspect_err(|e| {
            eprintln!("{e}");
            panic!();
        })
        .unwrap()
        .to_string();

    println!("{source}")
}
