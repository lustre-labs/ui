// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

///
/// 
pub fn alert(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.div, attributes, children)
}

///
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-alert"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

///
pub fn clear() -> Attribute(msg) {
  attribute.class("clear")
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
