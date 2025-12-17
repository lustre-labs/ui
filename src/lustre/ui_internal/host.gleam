// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import lustre/effect.{type Effect}
import lustre/ui_internal/dom.{type HtmlElement}

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

pub fn remove_event_listener(name: String) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_remove_event_listener(shadow_root, name)
}

@external(javascript, "./host.ffi.mjs", "remove_event_listener")
fn do_remove_event_listener(shadow_root: Dynamic, name: String) -> Nil

pub fn set_tabindex(value: Int) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_tabindex(shadow_root, value)
}

@external(javascript, "./host.ffi.mjs", "set_tabindex")
fn do_set_tabindex(shadow_root: Dynamic, value: Int) -> Nil

pub fn set_role(value: String) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_role(shadow_root, value)
}

@external(javascript, "./host.ffi.mjs", "set_role")
fn do_set_role(shadow_root: Dynamic, role: String) -> Nil

pub fn set_aria_has_popup(value: String) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_aria_has_popup(shadow_root, value)
}

@external(javascript, "./host.ffi.mjs", "set_aria_has_popup")
fn do_set_aria_has_popup(shadow_root: Dynamic, value: String) -> Nil

pub fn set_aria_expanded(value: Bool) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_aria_expanded(shadow_root, case value {
    True -> "true"
    False -> "false"
  })
}

@external(javascript, "./host.ffi.mjs", "set_aria_expanded")
fn do_set_aria_expanded(shadow_root: Dynamic, value: String) -> Nil

pub fn set_aria_controls(element: HtmlElement) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_aria_controls(shadow_root, element)
}

@external(javascript, "./host.ffi.mjs", "set_aria_controls")
fn do_set_aria_controls(shadow_root: Dynamic, element: HtmlElement) -> Nil

// FFI CRIMES ------------------------------------------------------------------

@external(javascript, "./host.ffi.mjs", "inject_unique_id")
pub fn inject_unique_id(name: String) -> Nil
