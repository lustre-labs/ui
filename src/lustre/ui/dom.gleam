// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}

// TYPES -----------------------------------------------------------------------

pub type HtmlElement

// ELEMENT PROPERTIES ----------------------------------------------------------

@external(javascript, "./dom.ffi.mjs", "assigned_elements")
pub fn assigned_elements(_slot: HtmlElement) -> List(HtmlElement)

@external(javascript, "./dom.ffi.mjs", "tag")
pub fn tag(element: HtmlElement) -> String

@external(javascript, "./dom.ffi.mjs", "text_content")
pub fn text_content(element: HtmlElement) -> String

@external(javascript, "./dom.ffi.mjs", "children")
pub fn children(element: HtmlElement) -> List(HtmlElement)

///
pub fn attribute(element: HtmlElement, name: String) -> Result(String, Nil) {
  do_attribute(element, name)
}

@external(javascript, "./dom.ffi.mjs", "get_attribute")
fn do_attribute(_element: HtmlElement, _name: String) -> Result(String, Nil)

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

@external(javascript, "./dom.ffi.mjs", "make_fallback_element")
fn make_fallback_element() -> HtmlElement
