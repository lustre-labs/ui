//// The [`divider`](#element) element is a visual separator between sections of
//// content that can be presented in one of two ways:
////
//// 1. As a horizontal rule with no content (similar to the HTML `<hr>` element).
////
//// 2. As a horizontal rule that can contain content positioned in its center.
////
//// A common alternative term for this element is a separator.
////
//// Common uses for dividers include:
////
//// - Separating blocks of related content to make them easier to scan.
////
//// - Adding labels to group related links or menu items.
////
//// ## Anatomy
////
//// <image src="/assets/diagram-divider.svg" alt="" width="100%">
////
//// A divider has a very simple anatomy:
////
//// - The main [`element`](#element) container used to control the divider's
////   styles and layout. If no content is provided, this is rendered as an `<hr>`,
////   otherwise it is rendered as a `<div>`. (**required**)
////
//// - An optional container for content that serves as a label or title for the
////   content that follows, for example "OR" or "Section 3". (_optional_)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `divider` element.
////
//// ### A basic divider with no content:
////
//// ```gleam
//// import lustre/ui/divider
////
//// pub fn hr() {
////   divider.element([], [])
//// }
//// ```
////
//// ### A divider with a text label:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/divider
////
//// pub fn or() {
////   divider.element([], [html.text("OR")])
//// }
//// ```
////
//// ## Customisation
////
//// It is possible to control some aspects of a divider's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `divider` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--colour`](#colour)
//// - [`--gap`](#gap)
//// - [`--margin`](#margin)
//// - [`--size-x`](#size_x)
//// - [`--size-y`](#size_y)
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  case children {
    [] -> {
      html.hr([attribute.class("lustre-ui-divider"), ..attributes])
    }

    _ -> {
      html.div([attribute.class("lustre-ui-divider"), ..attributes], children)
    }
  }
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-divider"), ..attributes], children)
}

// VARIABLES -------------------------------------------------------------------

pub fn colour(value: String) -> Attribute(msg) {
  attribute.style("--colour", value)
}

pub fn gap(value: String) -> Attribute(msg) {
  attribute.style("--gap", value)
}

pub fn margin(value: String) -> Attribute(msg) {
  attribute.style("--margin", value)
}

pub fn size_x(value: String) -> Attribute(msg) {
  attribute.style("--size-x", value)
}

pub fn size_y(value: String) -> Attribute(msg) {
  attribute.style("--size-y", value)
}
