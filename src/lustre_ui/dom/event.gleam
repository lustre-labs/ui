import gleam/dynamic/decode.{type Dynamic}

@external(javascript, "./event.ffi.mjs", "preventDefault")
pub fn prevent_default(event: Dynamic) -> Nil

@external(javascript, "./event.ffi.mjs", "stopPropagation")
pub fn stop_propagation(event: Dynamic) -> Nil
