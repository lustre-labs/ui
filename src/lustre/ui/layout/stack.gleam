// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A stack is a list of elements perpendicular to the current writing direction
/// with a uniform gap between each child. For a horizontal writing mode such as
/// English, the stack will be vertical.
/// 
/// By default a medium-sized gap is used, based on Lustre UI's spacing scale.
/// You can use the `packged`, `tight`, or `loose` attributes to change the gap.
/// 
pub fn stack(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.div, attributes, children)
}

/// By default the stack element uses a `<div />` as its container. You can use
/// this function to use a different element such as a `<nav />` or `<ul />`.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-stack"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Packed spacing has no gap between each child element.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.class("packed")
}

/// Tight spacing has a small gap between each child element.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.class("tight")
}

/// Relaxed spacing has a medium-sized gap between each child element. This is
/// the default gap but is provided as an attribute in case you want to toggle
/// between different spaces.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.class("relaxed")
}

/// Loose spacing has a large gap between each child element.
/// 
pub fn loose() -> Attribute(msg) {
  attribute.class("loose")
}

/// Use this function to set a custom gap between each child element. You'll need
/// to use this function if you want a larger gap than `loose` or a smaller one
/// than `tight`.
/// 
/// You can pass any valid CSS length value to this function such as `1rem` or
/// `10px`, or you can use CSS variables such as `var(--space-xs)` to use the
/// space scale from the theme.
/// 
pub fn space(gap: String) -> Attribute(msg) {
  attribute.style([#("--gap", gap)])
}
