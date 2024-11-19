// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

pub fn card(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.article, attributes, children)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-card"), ..attributes], children)
}

pub fn header(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.header([attribute.class("card-header"), ..attributes], children)
}

pub fn content(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.main([attribute.class("card-content"), ..attributes], children)
}

pub fn footer(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.footer([attribute.class("card-footer"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn square() -> Attribute(msg) {
  radius("0")
}

///
///
pub fn round() -> Attribute(msg) {
  radius(theme.radius.md)
}

// CSS VARIABLES ---------------------------------------------------------------

///
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

///
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

///
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

///
///
pub fn padding(x: String, y: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", x), #("--padding-y", y)])
}

///
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

///
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-y", value)])
}

///
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style([#("--radius", value)])
}
