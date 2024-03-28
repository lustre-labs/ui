// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A cluster is a group of non-uniformly sized elements arranged along the
/// inline axis. Where a cluster's children are too wide or too many, the elements
/// overflow in the same way that text typically does.
/// 
/// Clusters are useful for grouping things like tags or controls.
/// 
pub fn cluster(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.div, attributes, children)
}

/// By default the cluster uses a `<div />` as the underlying container. You can
/// use this function to use a different element, like a `<ul />` instead.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-cluster"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

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

///
pub fn stretch() -> Attribute(msg) {
  attribute.class("stretch")
}

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
/// `10px`, or you can use CSS variables such as `var(--space-xs)` to use the
/// space scale from the theme.
/// 
pub fn space(gap: String) -> Attribute(msg) {
  attribute.style([#("--gap", gap)])
}
