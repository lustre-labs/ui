// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/function
import gleam/list
import gleam/result
import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

pub type BoundingClientRect {
  BoundingClientRect(
    top: Float,
    right: Float,
    bottom: Float,
    left: Float,
    width: Float,
    height: Float,
  )
}

// DECODERS --------------------------------------------------------------------

/// Decode the assigned elements of a `HTMLSlotElement` using the provided
/// decoder. The `lenient` flag determines whether this should decoder should fail
/// if one of the assigned elements fails to decode. When `lenient` is `True`
/// it will continue decoding the remaining elements and return a list of only
/// those that successfully decoded. When `lenient` is `False` this decoder will
/// fail if any of the assigned elements fail to decode.
///
pub fn assigned_elements(
  decoder: Decoder(a),
  lenient lenient: Bool,
) -> Decoder(List(a)) {
  let lenient_decoder =
    decode.one_of(decode.map(decoder, Ok), [decode.success(Error(Nil))])

  use slot <- decode.new_primitive_decoder("HTMLSlotElement.assignedElements()")

  case do_assigned_elements(slot) {
    Ok(elements) if lenient ->
      elements
      |> list.try_map(decode.run(_, lenient_decoder))
      |> result.map(list.filter_map(_, function.identity))
      |> result.replace_error([])

    Ok(elements) ->
      elements
      |> list.try_map(decode.run(_, decoder))
      |> result.replace_error([])

    Error(_) -> Error([])
  }
}

@external(javascript, "./dom.ffi.mjs", "assigned_elements")
fn do_assigned_elements(element: Dynamic) -> Result(List(Dynamic), Nil)

/// Decode the `BoundingClientRect` of an element. This gives us its dimensions
/// and position relative to the viewport.
///
pub fn bounding_client_rect() -> Decoder(BoundingClientRect) {
  use element <- decode.new_primitive_decoder("Element.getBoundingClientRect()")

  case do_bounding_client_rect(element) {
    Ok(rect) -> Ok(rect)
    Error(_) -> Error(BoundingClientRect(0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
  }
}

@external(javascript, "./dom.ffi.mjs", "bounding_client_rect")
fn do_bounding_client_rect(element: Dynamic) -> Result(BoundingClientRect, Nil)

/// Decode an attribute of an element by its name.
///
/// ```gleam
/// import lustre/event
/// import lustre/ui/ffi/dom
///
/// fn handle_click() {
///   event.on("click", {
///     use id <- decode.field("target", dom.attribute("id"))
///     ...
///   })
/// }
/// ```
///
pub fn attribute(name: String) -> Decoder(String) {
  use element <- decode.new_primitive_decoder("Element.getAttribute()")

  case do_attribute(element, name) {
    Ok(value) -> Ok(value)
    Error(_) -> Error("")
  }
}

@external(javascript, "./dom.ffi.mjs", "attribute")
fn do_attribute(element: Dynamic, name: String) -> Result(String, Nil)

/// Decode the first descendant of an element that matches the given CSS query
/// selector. If no matching element is found, this decoder will fail and the
/// provided `zero` value will be passed
///
pub fn child(selector: String, zero: a, decoder: Decoder(a)) -> Decoder(a) {
  use element <- decode.new_primitive_decoder("Element.querySelector()")

  case do_find_element(selector, element) {
    Ok(child) -> decode.run(child, decoder) |> result.replace_error(zero)
    Error(_) -> Error(zero)
  }
}

// EFFECTS ---------------------------------------------------------------------

pub fn prevent_default(event: Dynamic) -> Effect(msg) {
  use _ <- effect.from

  do_prevent_default(event)
}

@external(javascript, "./dom.ffi.mjs", "prevent_default")
pub fn do_prevent_default(event: Dynamic) -> Nil

@external(javascript, "./dom.ffi.mjs", "find_element")
pub fn do_find_element(selector: String, root: Dynamic) -> Result(Dynamic, Nil)

pub fn focus(selector: String) -> Effect(msg) {
  use _, root <- effect.before_paint

  case do_find_element(selector, root) {
    Ok(element) -> do_focus(element)
    Error(_) -> Nil
  }
}

@external(javascript, "./dom.ffi.mjs", "focus")
pub fn do_focus(element: Dynamic) -> Nil
