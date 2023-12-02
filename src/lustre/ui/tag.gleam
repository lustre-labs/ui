// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A simple tag. This shares styles with lustre_ui's buttons, but are much
/// smaller and uninteractive by default. They are useful for displaying small
/// amounts of information, such as category tags or labels.
/// 
/// If you want a tag to be interactive, you should either use the `of` function
/// below to construct a tag with `html.button` *or* you should set the tabindex
/// attribute and handle both click and key events for `Enter` and `Space`.
/// 
pub fn tag(attributes: List(Attribute(msg)), children: List(Element(msg))) {
  of(html.span, attributes, children)
}

/// Use this function if you want to render something other than a `<span />`
/// element.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-tag"), ..attributes], children)
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
