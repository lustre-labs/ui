// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/string
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

pub fn button(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.button, [attribute("tabindex", "0"), ..attributes], children)
}

pub fn link(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.a, attributes, children)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-button"), ..attributes], children)
}

// CHILDREN --------------------------------------------------------------------

pub fn shortcut_badge(
  attributes: List(Attribute(msg)),
  chord: List(String),
) -> Element(msg) {
  html.span(
    [
      attribute.class("button-badge"),
      attribute.title(string.join(chord, "+")),
      ..attributes
    ],
    {
      use key <- list.map(chord)

      html.span([attribute.class("key")], [html.text(key)])
    },
  )
}

pub fn count_badge(attributes: List(Attribute(msg)), count: Int) -> Element(msg) {
  html.span([attribute.class("button-badge"), ..attributes], [
    html.text(case count < 100 {
      True -> int.to_string(count)
      False -> "99+"
    }),
  ])
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn clear() -> Attribute(msg) {
  attribute.class("button-clear")
}

///
///
pub fn outline() -> Attribute(msg) {
  attribute.class("button-outline")
}

///
///
pub fn soft() -> Attribute(msg) {
  attribute.class("button-soft")
}

///
///
pub fn solid() -> Attribute(msg) {
  attribute.class("button-solid")
}

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

///
///
pub fn pill() -> Attribute(msg) {
  radius(theme.radius.xl)
}

///
///
pub fn icon() -> Attribute(msg) {
  attribute.class("button-icon")
}

///
///
pub fn small() -> Attribute(msg) {
  attribute.class("button-small")
}

///
///
pub fn medium() -> Attribute(msg) {
  attribute.class("button-medium")
}

///
///
pub fn large() -> Attribute(msg) {
  attribute.class("button-large")
}

// CSS VARIABLES ---------------------------------------------------------------

///
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

///
///
pub fn background_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--background-hover", value)])
}

///
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

///
///
pub fn border_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--border-hover", value)])
}

///
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

///
///
pub fn height(value: String) -> Attribute(msg) {
  attribute.style([#("--height", value)])
}

///
///
pub fn min_height(value: String) -> Attribute(msg) {
  attribute.style([#("--min-height", value)])
}

///
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

///
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style([#("--radius", value)])
}

///
///
pub fn text(value: String) -> Attribute(msg) {
  attribute.style([#("--text", value)])
}
