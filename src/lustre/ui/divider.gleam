// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn divider(
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
  attribute.style([#("--colour", value)])
}

pub fn gap(value: String) -> Attribute(msg) {
  attribute.style([#("--gap", value)])
}

pub fn margin(value: String) -> Attribute(msg) {
  attribute.style([#("--margin", value)])
}

pub fn size_x(value: String) -> Attribute(msg) {
  attribute.style([#("--size-x", value)])
}

pub fn size_y(value: String) -> Attribute(msg) {
  attribute.style([#("--size-y", value)])
}
