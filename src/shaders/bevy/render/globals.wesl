struct Globals {
    // The time since startup in seconds
    // Wraps to 0 after 1 hour.
    time: f32,
    // The delta time since the previous frame in seconds
    delta_time: f32,
    // Frame count since the start of the app.
    // It wraps to zero when it reaches the maximum value of a u32.
    frame_count: u32,
    // WebGL2 structs must be 16 byte aligned.
    @if(SIXTEEN_BYTE_ALIGNMENT)
    _webgl2_padding: f32
};
