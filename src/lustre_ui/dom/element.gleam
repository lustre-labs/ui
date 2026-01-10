// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/order.{type Order}
import gleam/result
import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

///
///
pub type HtmlElement

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn decoder() -> decode.Decoder(HtmlElement) {
  use value <- decode.new_primitive_decoder("HtmlElement")

  case is_html_element(value) {
    True -> Ok(as_html_element(value))
    False -> Error(create_html_element("div"))
  }
}

pub fn host_decoder() -> decode.Decoder(HtmlElement) {
  use value <- decode.new_primitive_decoder("HtmlElement")

  case is_shadow_root(value) {
    True -> as_html_element(value) |> host |> result.replace_error(nil())
    False -> Error(nil())
  }
}

pub fn nil() -> HtmlElement {
  create_html_element("div")
}

///
///
@external(javascript, "./element.ffi.mjs", "createHtmlElement")
fn create_html_element(tag: String) -> HtmlElement

// QUERIES ---------------------------------------------------------------------

///
///
@external(javascript, "./element.ffi.mjs", "assignedElements")
pub fn assigned_elements(element: HtmlElement) -> List(HtmlElement)

///
///
@external(javascript, "./element.ffi.mjs", "attribute")
pub fn attribute(element: HtmlElement, name: String) -> Result(String, Nil)

///
///
@external(javascript, "./element.ffi.mjs", "closest")
pub fn closest(
  element: HtmlElement,
  selector: String,
) -> Result(HtmlElement, Nil)

/// Test whether the `parent` element contains the `child` element as a descendant.
///
@external(javascript, "./element.ffi.mjs", "contains")
pub fn contains(parent: HtmlElement, child: HtmlElement) -> Bool

/// Compare two elements in document order. Returns `Lt` if the `left` element
/// appears before the `right` element, `Gt` if it appears after, and `Eq` if they
/// are the same element by reference.
///
@external(javascript, "./element.ffi.mjs", "compare")
pub fn compare(left: HtmlElement, right: HtmlElement) -> Order

///
///
pub fn with_component(
  shadow_root: Dynamic,
  callback: fn(HtmlElement) -> Nil,
) -> Nil {
  case decode.run(shadow_root, host_decoder()) {
    Ok(component) -> callback(component)
    Error(_) -> Nil
  }
}

///
///
@external(javascript, "./element.ffi.mjs", "host")
pub fn host(element: HtmlElement) -> Result(HtmlElement, Nil)

///
///
@external(javascript, "./element.ffi.mjs", "is")
pub fn is(element: HtmlElement, other: HtmlElement) -> Bool

/// Test whether the given element matches the provided CSS selector.
///
@external(javascript, "./element.ffi.mjs", "matches")
pub fn matches(element: HtmlElement, selector: String) -> Bool

///
///
@external(javascript, "./element.ffi.mjs", "querySelector")
pub fn query_selector(
  element: HtmlElement,
  selector: String,
) -> Result(HtmlElement, Nil)

///
///
@external(javascript, "./element.ffi.mjs", "querySelectorAll")
pub fn query_selector_all(
  element: HtmlElement,
  selector: String,
) -> List(HtmlElement)

@external(javascript, "./element.ffi.mjs", "root")
pub fn root(control: HtmlElement) -> HtmlElement

///
///
@external(javascript, "./element.ffi.mjs", "selection")
pub fn selection(element: HtmlElement) -> Result(#(Int, Int), Nil)

/// Get the lowercase tag name of the given element.
///
@external(javascript, "./element.ffi.mjs", "tag")
pub fn tag(element: HtmlElement) -> String

///
///
@external(javascript, "./element.ffi.mjs", "value")
pub fn value(element: HtmlElement) -> Result(String, Nil)

// MANIPULATIONS ---------------------------------------------------------------

/// Programmatically focus the given element.
///
pub fn focus(element: HtmlElement) -> Effect(message) {
  effect.from(fn(_) { do_focus(element) })
}

///
///
@external(javascript, "./element.ffi.mjs", "focus")
pub fn do_focus(element: HtmlElement) -> Nil

@external(javascript, "./element.ffi.mjs", "setAttribute")
pub fn set_attribute(element: HtmlElement, key: String, value: String) -> Nil

@external(javascript, "./element.ffi.mjs", "removeAttribute")
pub fn remove_attribute(element: HtmlElement, key: String) -> Nil

// UTILS -----------------------------------------------------------------------

///
///
@external(javascript, "./element.ffi.mjs", "coerce")
fn as_html_element(value: Dynamic) -> HtmlElement

///
///
@external(javascript, "./element.ffi.mjs", "isHtmlElement")
fn is_html_element(value: Dynamic) -> Bool

///
///
@external(javascript, "./element.ffi.mjs", "isShadowRoot")
fn is_shadow_root(value: Dynamic) -> Bool
