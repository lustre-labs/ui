// IMPORTS ---------------------------------------------------------------------

import gleam/list
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A box is a generic container element with some padding applied to all sides.
/// Many of the other layouting elements use _margin_ to space themselves from
/// other elements, but a box uses _padding_ to space its children from itself.
/// 
pub fn breadcrumbs(
  attributes: List(Attribute(msg)),
  separator: Element(msg),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.ol, attributes, separator, children)
}

/// By default, the box element uses a `<div />` as the underlying container. You
/// can use this function to create a box using a different element such as a
/// `<section />` or a `<p />`.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  separator: Element(msg),
  children: List(Element(msg)),
) -> Element(msg) {
  element(
    [attribute.class("lustre-ui-breadcrumbs"), ..attributes],
    list.intersperse(children, separator),
  )
}

// ATTRIBUTES ------------------------------------------------------------------

///
/// 
pub fn active() -> Attribute(msg) {
  attribute.class("active")
}

/// 
pub fn align_start() -> Attribute(msg) {
  attribute.class("align-start")
}

/// 
pub fn align_centre() -> Attribute(msg) {
  attribute.class("align-centre")
}

/// 
pub fn align_end() -> Attribute(msg) {
  attribute.class("align-end")
}

/// A tight cluster has a small gap between each child element.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.class("tight")
}

/// A relaxed cluster has a medium-sized gap between each child element. This is
/// the default gap but is provided as an attribute because nested clusters will
/// inherit the gap from their parent cluster unless explicitly told otherwise.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.class("relaxed")
}

/// A loose cluster has a large gap between each child element.
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
