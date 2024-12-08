// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn input(attributes: List(Attribute(msg))) -> Element(msg) {
  html.input([attribute.class("lustre-ui-input"), ..attributes])
}

pub fn container(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [attribute.class("lustre-ui-input-container"), ..attributes],
    children,
  )
}
