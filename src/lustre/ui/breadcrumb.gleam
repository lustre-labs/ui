// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/icon

// ELEMENTS --------------------------------------------------------------------

pub fn breadcrumb(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.nav([attribute("aria-label", "breadcrumb")], [
    html.ol([attribute.class("lustre-ui-breadcrumb"), ..attributes], children),
  ])
}

pub fn item(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.li([attribute.class("breadcrumb-item"), ..attributes], children)
}

pub fn current(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.span(
    [
      attribute.class("breadcrumb-item breadcrumb-current"),
      attribute.role("link"),
      attribute("aria-disabled", "true"),
      attribute("aria-current", "page"),
      ..attributes
    ],
    children,
  )
}

pub fn separator(attributes: List(Attribute(msg))) -> Element(msg) {
  html.li(
    [
      attribute.class("breadcrumb-separator"),
      attribute.role("presentation"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [icon.caret_right([])],
  )
}

pub fn ellipsis(attributes: List(Attribute(msg)), label: String) -> Element(msg) {
  html.span(
    [
      attribute.class("breadcrumb-ellipsis"),
      attribute.role("presentation"),
      ..attributes
    ],
    [icon.dots_horizontal([]), html.span([], [html.text(label)])],
  )
}
