// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A styled native HTML button. You can use the `solid`, `soft`, and `outline`
/// attributes to configure the button's appearance.
/// 
pub fn button(attributes: List(Attribute(msg)), children: List(Element(msg))) {
  html.button(
    [
      attribute.class("lustre-ui-button"),
      attribute.type_("button"),
      ..attributes
    ],
    children,
  )
}

/// Use this function if you want to render something other than a `<button />`
/// element. It will automatically have the `role` and `tabindex` attributes
/// set.
/// 
/// 🚨 To make your non-standard buttons accessible, it is important that you
///    handle click events as well as key events for the `Enter` and `Space`.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(
    [
      attribute.class("lustre-ui-button"),
      attribute("role", "button"),
      attribute("tabindex", "0"),
      ..attributes
    ],
    children,
  )
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn solid() -> Attribute(msg) {
  attribute.class("solid")
}

pub fn soft() -> Attribute(msg) {
  attribute.class("soft")
}

pub fn outline() -> Attribute(msg) {
  attribute.class("outline")
}

pub fn clear() -> Attribute(msg) {
  attribute.class("clear")
}

pub fn small() -> Attribute(msg) {
  attribute.class("small")
}

pub fn primary() -> Attribute(msg) {
  attribute("data-variant", "primary")
}

pub fn greyscale() -> Attribute(msg) {
  attribute("data-variant", "greyscale")
}

pub fn error() -> Attribute(msg) {
  attribute("data-variant", "error")
}

pub fn warning() -> Attribute(msg) {
  attribute("data-variant", "warning")
}

pub fn success() -> Attribute(msg) {
  attribute("data-variant", "success")
}

pub fn info() -> Attribute(msg) {
  attribute("data-variant", "info")
}
