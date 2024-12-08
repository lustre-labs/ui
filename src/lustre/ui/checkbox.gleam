// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn checkbox(attributes: List(Attribute(msg))) -> Element(msg) {
  html.input([
    attribute.class("lustre-ui-checkbox"),
    attribute.type_("checkbox"),
    ..attributes
  ])
}

// CSS VARIABLES ---------------------------------------------------------------

pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

pub fn background_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--background-hover", value)])
}

pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

pub fn border_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--border-hover", value)])
}

pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

pub fn size(value: String) -> Attribute(msg) {
  attribute.style([#("--size", value)])
}

pub fn padding(value: String) -> Attribute(msg) {
  attribute.style([#("--padding", value)])
}

pub fn check_color(value: String) -> Attribute(msg) {
  attribute.style([#("--check-color", value)])
}
