use std::{path::Path, time::Instant};

fn main() {
    println!("compiling package...");

    let start = Instant::now();

    // must be run from examples/builder folder.
    let path = Path::new("../../src/shaders/bevy");
    // .canonicalize()
    // .expect("input path not found");

    let pkg = wesl::PkgBuilder::new("bevy")
        .scan_root(&path)
        .expect("failed to scan WESL files");

    let pkg_end = Instant::now();
    let duration = pkg_end - start;
    println!("packaging done in {} ms", duration.as_millis());

    let pkg = pkg
        .validate()
        .map_err(|e| eprintln!("{e}"))
        .expect("validation error");

    let valid_end = Instant::now();
    let duration = valid_end - pkg_end;
    println!("validation done in {} ms", duration.as_millis());

    let file = pkg.codegen().expect("failed to build artifact");

    let codegen_end = Instant::now();
    let duration = codegen_end - pkg_end;
    println!("codegen done in {} ms", duration.as_millis());

    let mut path = Path::new(".")
        .canonicalize()
        .expect("invalid output file path");
    path.push("codegen.rs");
    std::fs::write(&path, file).expect("failed to write file");

    let duration = Instant::now() - start;
    println!(
        "file written to {}, total time: {} ms",
        path.display(),
        duration.as_millis()
    );
}
