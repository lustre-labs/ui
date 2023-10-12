// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html
import lustre/ui

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

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-stack"), ..attributes], children)
}

/// A split is a special kind of stack that divides itself into two parts. The
/// first child is anchored to the top of the split and the second child is
/// anchored to the bottom of the split. 
/// 
/// If one (or both) of the children are too large, or if the height of the split
/// is too small, the children will still be separated by a gap as in the normal
/// `stack`.
/// 
pub fn split(
  attributes: List(Attribute(msg)),
  top: Element(msg),
  bottom: Element(msg),
) -> Element(msg) {
  html.div(
    [attribute.class("lustre-ui-stack split"), ..attributes],
    [top, bottom],
  )
}

// ATTRIBUTES ------------------------------------------------------------------

/// A packed stack has no gap between each child element.
/// 
pub fn packed() -> Attribute(msg) {
  attribute.style([#("--gap", "0")])
}

/// A tight stack has a small gap between each child element.
/// 
pub fn tight() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_xs <> ")")])
}

/// A relaxed stack has a medium-sized gap between each child element. This is
/// the default gap but is provided as an attribute in case you want to toggle
/// between different spaces.
/// 
pub fn relaxed() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_md <> ")")])
}

/// A loose stack has a large gap between each child element.
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
