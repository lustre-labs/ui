// IMPORTS ---------------------------------------------------------------------

import gleam/int
import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html
import lustre/ui

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
/// 
/// 
pub fn aside(
  attributes: List(Attribute(msg)),
  side: Element(msg),
  main: Element(msg),
) -> Element(msg) {
  of(html.div, attributes, side, main)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  side: Element(msg),
  main: Element(msg),
) -> Element(msg) {
  element([attribute.class("lustre-ui-aside"), ..attributes], [side, main])
}

// ATTRIBUTES ------------------------------------------------------------------

/// 
/// 
pub fn content_first() -> Attribute(msg) {
  attribute.style([#("--dir", "row"), #("--wrap", "wrap")])
}

///
/// 
pub fn content_last() -> Attribute(msg) {
  attribute.style([#("--dir", "row-reverse"), #("--wrap", "wrap-reverse")])
}

///
/// 
pub fn anchor_start() -> Attribute(msg) {
  attribute.style([#("--align", "start")])
}

///
/// 
pub fn anchor_center() -> Attribute(msg) {
  attribute.style([#("--align", "center")])
}

///
/// 
pub fn anchor_end() -> Attribute(msg) {
  attribute.style([#("--align", "end")])
}

///
///
pub fn stretch() -> Attribute(msg) {
  attribute.style([#("--align", "stretch")])
}

/// Packed spacing has no gap between each child element.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.style([#("--gap", "0")])
}

/// Tight spacing has a small gap between each child element.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_xs <> ")")])
}

/// Relaxed spacing has a medium-sized gap between each child element. This is
/// the default gap but is provided as an attribute in case you want to toggle
/// between different spaces.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_md <> ")")])
}

/// Loose spacing has a large gap between each child element.
/// 
pub fn loose() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_lg <> ")")])
}

/// Use this function to set a custom gap between each child element. You'll need
/// to use this function if you want a larger gap than `loose` or a smaller one
/// than `tight`.
/// 
/// You can pass any valid CSS length value to this function such as `1rem` or
/// `10px`, but we recommend using one of the `ui.space_*` variables to maintain
/// consistency with the rest of your UI.
/// 
/// 🚨 When using one of the space constants, it's important you wrap them to be
///    CSS `var` function calls. For example, `ui.space_md` should be passed as
///   `"var(" <> ui.space_md <> ")"`.
/// 
pub fn space(gap: String) -> Attribute(msg) {
  attribute.style([#("--gap", gap)])
}

/// This attribute specifies the minimum width of the main content before forcing
/// the layout to stack. Values represent a percentage of the container width, and
/// are clamped between 1% and 99%.
/// 
pub fn min_width(width: Int) -> Attribute(msg) {
  case width < 1, width > 99 {
    True, _ -> attribute.style([#("--min", "1%")])
    False, False -> attribute.style([#("--min", int.to_string(width) <> "%")])
    _, True -> attribute.style([#("--min", "99%")])
  }
}
