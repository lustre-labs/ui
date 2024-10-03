// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// CONSTANTS -------------------------------------------------------------------

const base_classes = "relative w-full border px-w-lg py-w-md"

const colours_classes = "border-w-accent/50 text-w-text bg-w-bg dark:border-w-accent"

const svg_classes = "[&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-w-md [&>svg]:top-w-lg [&>svg~*]:pl-w-xl [&>svg]:text-w-text"

// ELEMENTS --------------------------------------------------------------------

pub fn alert(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [
      attribute.role("alert"),
      attribute.class(base_classes),
      attribute.class(svg_classes),
      attribute.class(colours_classes),
      ..attributes
    ],
    children,
  )
}

pub fn title(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.h5(
    [
      attribute.class("mb-w-xs font-medium leading-none tracking-tight"),
      ..attributes
    ],
    children,
  )
}

pub fn description(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div([attribute.class("[&_p]:leading-relaxed"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn square() -> Attribute(msg) {
  attribute.class("rounded-none")
}

pub fn round() -> Attribute(msg) {
  attribute.class("rounded-w-sm")
}

pub fn pill() -> Attribute(msg) {
  attribute.class("rounded-w-xl")
}

pub fn base() -> Attribute(msg) {
  attribute.class("base")
}

pub fn primary() -> Attribute(msg) {
  attribute.class("primary")
}

pub fn secondary() -> Attribute(msg) {
  attribute.class("secondary")
}

pub fn success() -> Attribute(msg) {
  attribute.class("success")
}

pub fn warning() -> Attribute(msg) {
  attribute.class("warning")
}

pub fn danger() -> Attribute(msg) {
  attribute.class("danger")
}
