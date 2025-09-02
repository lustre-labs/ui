// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import lustre/effect.{type Effect}

// EFFECTS ---------------------------------------------------------------------

pub fn add_event_listener(name: String, decoder: Decoder(msg)) -> Effect(msg) {
  use dispatch, shadow_root <- effect.before_paint
  use event <- do_add_event_listener(shadow_root, name)

  case decode.run(event, decoder) {
    Ok(msg) -> dispatch(msg)
    Error(_) -> Nil
  }
}

@external(javascript, "./host.ffi.mjs", "add_event_listener")
fn do_add_event_listener(
  shadow_root: Dynamic,
  name: String,
  handler: fn(Dynamic) -> Nil,
) -> Nil

pub fn set_role(value: String) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_role(shadow_root, value)
}

@external(javascript, "./host.ffi.mjs", "set_role")
fn do_set_role(shadow_root: Dynamic, role: String) -> Nil
