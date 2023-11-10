// IMPORTS ---------------------------------------------------------------------

import gleam/int
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui

// ELEMENTS --------------------------------------------------------------------

/// A sequence lays elements out along the inline axis (horizontally for left-to-right
/// languages) unless the container is too narrow, in which case it lays them
/// out along the block axis (vertically for left-to-right languages) instead.
/// 
/// Media queries are often used to change the direction of a sequence based on
/// the width of the viewport, but the sequence element itself instead uses its
/// own width to determine the direction. To configure when the break happens,
/// you can use the `breakpoint` attribute: the default value is `30rem`.
/// 
/// While the sequence will break if the container gets too narrow, it will allow
/// its children to shrink to fit into the container. If you want to force the
/// container to break after a certain number of children regardless of the
/// container's width, you can use the `split` attribute. 
/// 
/// 🚨 If the number of children to split on is greater than `10`, you must add
///    the following CSS to your own stylesheet for things to work properly,
///    replacing `X` with the number of children to split on:
/// 
/// ```css
/// .lustre-ui-sequence[data-split-at="X"] > :nth-last-child(n + X),
/// .lustre-ui-sequence[data-split-at="X"] > :nth-last-child(n + X) ~ * {
///    flex-basis: 100%;
/// }
/// ```
/// 
pub fn sequence(
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
  element([attribute.class("lustre-ui-sequence"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// This attribute determines the minimum width of the container before the
/// sequence breaks. The default value is `30rem` and any CSS length value is
/// valid.
///
pub fn breakpoint(break: String) -> Attribute(msg) {
  attribute.style([#("--break", break)])
}

/// This attribute forces the sequence to break once a certain number of children
/// are added.
/// 
/// 🚨 If the number of children to split on is greater than `10`, you must add
///    the following CSS to your own stylesheet for things to work properly,
///    replacing `X` with the number of children to split on:
/// 
/// ```css
/// .lustre-ui-sequence[data-split-at="X"] > :nth-last-child(n + X),
/// .lustre-ui-sequence[data-split-at="X"] > :nth-last-child(n + X) ~ * {
///    flex-basis: 100%;
/// }
/// ```
/// 
/// 💡 A value less than `3` is ignored because it wouldn't make much sense. The
///    sequence would always break!
/// 
pub fn split(n: Int) -> Attribute(msg) {
  case n < 3 {
    True -> attribute.class("")
    False -> attribute("data-split-at", int.to_string(n))
  }
}

/// A packed sequence has no gap between each child element.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.style([#("--gap", "0")])
}

/// A tight sequence has a small gap between each child element.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_xs <> ")")])
}

/// A relaxed sequence has a medium-sized gap between each child element. This is
/// the default gap but is provided as an attribute in case you want to toggle
/// between different spaces.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_md <> ")")])
}

/// A loose sequence has a large gap between each child element.
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
