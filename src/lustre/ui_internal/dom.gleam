// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError, type Decoder}

// TYPES -----------------------------------------------------------------------

pub type HtmlElement

// ELEMENT PROPERTIES ----------------------------------------------------------

@external(javascript, "./dom.ffi.mjs", "assigned_elements")
pub fn assigned_elements(_slot: HtmlElement) -> List(HtmlElement)

@external(javascript, "./dom.ffi.mjs", "tag")
pub fn tag(element: HtmlElement) -> String

///
pub fn attribute(element: HtmlElement, name: String) -> Result(String, Nil) {
  do_attribute(element, name)
}

@external(javascript, "./dom.ffi.mjs", "get_attribute")
fn do_attribute(_element: HtmlElement, _name: String) -> Result(String, Nil)

///
///
pub fn property(
  element: HtmlElement,
  name: String,
  decoder: Decoder(a),
) -> Result(a, List(DecodeError)) {
  decode.run(as_dynamic(element), decode.at([name], decoder))
}

// DECODERS --------------------------------------------------------------------

pub fn element_decoder() -> Decoder(HtmlElement) {
  use dynamic <- decode.new_primitive_decoder("HtmlElement")

  case is_element(dynamic) {
    True -> Ok(as_element(dynamic))
    False -> Error(make_fallback_element())
  }
}

@external(javascript, "./dom.ffi.mjs", "is_element")
fn is_element(_value: Dynamic) -> Bool

@external(javascript, "../../../gleam_stdlib/gleam/function.mjs", "identity")
fn as_element(_: Dynamic) -> HtmlElement

@external(javascript, "../../../gleam_stdlib/gleam/function.mjs", "identity")
fn as_dynamic(_: HtmlElement) -> Dynamic

@external(javascript, "./dom.ffi.mjs", "make_fallback_element")
fn make_fallback_element() -> HtmlElement
