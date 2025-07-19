//// The [`checkbox`](#element) element is an interactive control that lets users
//// select a value that has two possible states - checked and unchecked.
////
//// Common uses for checkboxes include:
////
//// - Toggling a boolean value in a form or setting.
////
//// - Selecting multiple items from a list.
////
//// - Toggling visibility or state of other elements.
////
//// ## Customisation
////
//// It is possible to control some aspects of a checkbox's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `checkbox` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--background`](#background)
//// - [`--background-hover`](#background_hover)
//// - [`--border`](#border)
//// - [`--border-hover`](#border_hover)
//// - [`--border-width`](#border_width)
//// - [`--check-color`](#check_color)
//// - [`--padding`](#padding)
//// - [`--size`](#size)
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn element(attributes: List(Attribute(msg))) -> Element(msg) {
  html.input([
    attribute.class("lustre-ui-checkbox"),
    attribute.type_("checkbox"),
    ..attributes
  ])
}

// CSS VARIABLES ---------------------------------------------------------------

pub fn background(value: String) -> Attribute(msg) {
  attribute.style("--background", value)
}

pub fn background_hover(value: String) -> Attribute(msg) {
  attribute.style("--background-hover", value)
}

pub fn border(value: String) -> Attribute(msg) {
  attribute.style("--border", value)
}

pub fn border_hover(value: String) -> Attribute(msg) {
  attribute.style("--border-hover", value)
}

pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style("--border-width", value)
}

pub fn size(value: String) -> Attribute(msg) {
  attribute.style("--size", value)
}

pub fn padding(value: String) -> Attribute(msg) {
  attribute.style("--padding", value)
}

pub fn check_color(value: String) -> Attribute(msg) {
  attribute.style("--check-color", value)
}
