fn main() {
    wesl::PkgBuilder::new("bevy")
        .scan_root("src/shaders/bevy")
        .expect("failed to scan WESL files")
        .validate()
        .map_err(|e| eprintln!("{e}"))
        .expect("validation error")
        .build_artifact()
        .expect("failed to build artifact");
}
