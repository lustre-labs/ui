// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A box is a generic container element with some padding applied to all sides.
/// Many of the other layouting elements use _margin_ to space themselves from
/// other elements, but a box uses _padding_ to space its children from itself.
/// 
pub fn box(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
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
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-box"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Packed spacing means there is no padding between the box edges and its
/// children.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.class("packed")
}

/// Tight spacing has a small amount of padding between the box edges and its
/// children.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.class("tight")
}

/// Relaxed spacing has a medium amount of padding between the box edges and its
/// children. This is the default amount of spacing but is provided as an attribute
/// in case you want to switch between different spacings dynamically.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.class("relaxed")
}

/// Loose spacing has a large amount of padding between the box edges and its
/// children.
/// 
pub fn loose() -> Attribute(msg) {
  attribute.class("loose")
}

/// Use this function to set a custom amount of padding between the box edges and
/// its children. You'll need to use this function if you want a larger gap than
/// `loose` or a smaller one than `tight`.
/// 
/// You can pass any valid CSS length value to this function such as `1rem` or
/// `10px`, or you can use CSS variables such as `var(--space-xs)` to use the
/// space scale from the theme.
/// 
pub fn space(gap: String) -> Attribute(msg) {
  attribute.style([#("--gap", gap)])
}
