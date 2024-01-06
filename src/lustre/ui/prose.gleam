// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

///
/// 
pub fn prose(
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
  element([attribute.class("lustre-ui-prose"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn narrow() -> Attribute(msg) {
  attribute.class("narrow")
}

pub fn wide() -> Attribute(msg) {
  attribute.class("wide")
}

pub fn full() -> Attribute(msg) {
  attribute.class("full")
}
