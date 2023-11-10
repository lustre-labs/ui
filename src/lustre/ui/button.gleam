// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn button(attributes: List(Attribute(msg)), children: List(Element(msg))) {
  html.button([attribute.class("lustre-ui-button"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn primary() -> Attribute(msg) {
  attribute("data-variant", "primary")
}

pub fn greyscale() -> Attribute(msg) {
  attribute("data-variant", "greyscale")
}

pub fn error() -> Attribute(msg) {
  attribute("data-variant", "error")
}

pub fn warning() -> Attribute(msg) {
  attribute("data-variant", "warning")
}

pub fn success() -> Attribute(msg) {
  attribute("data-variant", "success")
}

pub fn info() -> Attribute(msg) {
  attribute("data-variant", "info")
}

pub fn solid() -> Attribute(msg) {
  attribute.class("solid")
}

pub fn soft() -> Attribute(msg) {
  attribute.class("soft")
}

pub fn outline() -> Attribute(msg) {
  attribute.class("outline")
}
