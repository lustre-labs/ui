// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn cluster(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.div, attributes, children)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-cluster"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// A packed cluster has no gap between each child element.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.class("packed")
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
/// `10px`, but we recommend using the `ui.space` function for consistent spacing
/// across your application.
/// 
pub fn space(gap: String) -> Attribute(msg) {
  attribute.style([#("--gap", gap)])
}

///
/// 
pub fn from_start() -> Attribute(msg) {
  attribute.class("from-start")
}

///
/// 
pub fn from_end() -> Attribute(msg) {
  attribute.class("from-end")
}
