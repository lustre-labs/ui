// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A box is a generic container element with some padding applied to all sides.
/// Many of the other layouting elements use _margin_ to space themselves from
/// other elements, but a box uses _padding_ to space its children from itself.
/// 
pub fn centre(
  attributes: List(Attribute(msg)),
  children: Element(msg),
) -> Element(msg) {
  of(html.div, attributes, children)
}

/// By default, the box element uses a `<div />` as the underlying container. You
/// can use this function to create a box using a different element such as a
/// `<section />` or a `<p />`.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: Element(msg),
) -> Element(msg) {
  element([attribute.class("lustre-ui-centre"), ..attributes], [children])
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn inline() -> Attribute(msg) {
  attribute.class("inline")
}
