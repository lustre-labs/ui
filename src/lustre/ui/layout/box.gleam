// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html
import lustre/ui

// ELEMENTS --------------------------------------------------------------------

/// 
/// 
pub fn box(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div([attribute.class("lustre-ui-box"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

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
  attribute.style([#("--gap", "var(" <> ui.space_sm <> ")")])
}

/// Loose spacing has a large gap between each child element.
/// 
pub fn loose() -> Attribute(msg) {
  attribute.style([#("--gap", "var(" <> ui.space_md <> ")")])
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
