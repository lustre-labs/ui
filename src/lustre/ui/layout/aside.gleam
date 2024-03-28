// IMPORTS ---------------------------------------------------------------------

import gleam/int
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

/// A two-column layout with a side column and a main column. When laid out 
/// side-by-side, the main column always occupies at least 60% of the width of
/// the container by default. When the width of the side column makes this 
/// impossible, the layout switches to a stack with the side column displayed
/// first.
/// 
/// It is possible to flip the layout so that the main column is displayed first
/// by using the `content_first` attribute. You can switch back to the default
/// behaviour with the `content_last` attribute.
/// 
pub fn aside(
  attributes: List(Attribute(msg)),
  side: Element(msg),
  main: Element(msg),
) -> Element(msg) {
  of(html.div, attributes, side, main)
}

/// The default `aside` element uses a `<div />` as the underling container. You
/// can use this function if you want to use a different container such as a
/// `<section />` or `<article />`.
/// 
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  side: Element(msg),
  main: Element(msg),
) -> Element(msg) {
  element([attribute.class("lustre-ui-aside"), ..attributes], [side, main])
}

// ATTRIBUTES ------------------------------------------------------------------

/// Visually places the main content first in the layout. Note that this doesn't
/// change the markup: the side content is always the first child of the aside
/// container.
/// 
pub fn content_first() -> Attribute(msg) {
  attribute.class("content-first")
}

/// Visually places the main content last in the layout. Note that this doesn't
/// change the markup: the side content is always the first child of the aside
/// container.
/// 
pub fn content_last() -> Attribute(msg) {
  attribute.class("content-last")
}

/// When the main content is taller than the side content, the align_start
/// attribute tells the side content to align itself to the top of the container.
/// 
pub fn align_start() -> Attribute(msg) {
  attribute.class("align-start")
}

/// When the main content is taller than the side content, the align_centre
/// attribute tells the side content to align itself to the middle of the
/// container.
/// 
pub fn align_centre() -> Attribute(msg) {
  attribute.class("align-centre")
}

/// When the main content is taller than the side content, the align_end attribute
/// tells the side content to align itself to the bottom of the container.
/// 
pub fn align_end() -> Attribute(msg) {
  attribute.class("align-end")
}

/// The stretch attribute tells the side content to grow to match the height of
/// the main content. This is useful if you have a side column with a background
/// you want to fill or an image you want to stretch to the full height of the
/// container.
///
pub fn stretch() -> Attribute(msg) {
  attribute.class("stretch")
}

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

/// This attribute specifies the minimum width of the main content before forcing
/// the layout to stack. Values represent a percentage of the container width, and
/// are clamped between 10% and 90%.
/// 
pub fn min_width(width: Int) -> Attribute(msg) {
  case width < 10, width > 90 {
    True, _ -> attribute.style([#("--min", "10%")])
    False, False -> attribute.style([#("--min", int.to_string(width) <> "%")])
    _, True -> attribute.style([#("--min", "90%")])
  }
}
