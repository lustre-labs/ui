// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/layout/stack.{stack}

// ELEMENTS --------------------------------------------------------------------

pub fn field(
  attributes: List(Attribute(msg)),
  label: List(Element(msg)),
  input: Element(msg),
  message: List(Element(msg)),
) -> Element(msg) {
  of(html.label, attributes, label, input, message)
}

pub fn with_label(
  attributes: List(Attribute(msg)),
  label: List(Element(msg)),
  input: Element(msg),
) -> Element(msg) {
  of(html.label, attributes, label, input, [])
}

pub fn with_message(
  attributes: List(Attribute(msg)),
  input: Element(msg),
  message: List(Element(msg)),
) -> Element(msg) {
  of(html.div, attributes, [], input, message)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  label: List(Element(msg)),
  input: Element(msg),
  message: List(Element(msg)),
) -> Element(msg) {
  stack.of(
    element,
    [attribute.class("lustre-ui-field"), stack.packed(), ..attributes],
    [
      html.span([attribute.class("label")], label),
      input,
      html.span([attribute.class("message")], message),
    ],
  )
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn label_start() -> Attribute(msg) {
  attribute.class("label-start")
}

pub fn label_end() -> Attribute(msg) {
  attribute.class("label-end")
}

pub fn label_centre() -> Attribute(msg) {
  attribute.class("label-centre")
}

pub fn message_start() -> Attribute(msg) {
  attribute.class("message-start")
}

pub fn message_end() -> Attribute(msg) {
  attribute.class("message-end")
}

pub fn message_centre() -> Attribute(msg) {
  attribute.class("message-centre")
}

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
