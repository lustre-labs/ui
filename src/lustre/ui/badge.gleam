// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// CONSTANTS -------------------------------------------------------------------

const base_classes = "inline-flex items-center px-w-sm py-w-xs text-xs font-semibold"

const focus_classes = "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"

const empty_classes = "[&:empty]:p-0 [&:empty]:rounded-full"

// ELEMENTS --------------------------------------------------------------------

fn badge(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [
      attribute.class(base_classes),
      attribute.class(focus_classes),
      attribute.class(empty_classes),
      ..attributes
    ],
    children,
  )
}

pub fn outline(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "border border-w-accent text-w-text"
  let hover_classes = "hover:border-w-accent-strong"

  badge(
    [
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      ..attributes
    ],
    children,
  )
}

pub fn soft(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "bg-w-tint text-w-text"
  let hover_classes = "hover:bg-w-tint-strong"

  badge(
    [
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      ..attributes
    ],
    children,
  )
}

pub fn solid(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "bg-w-solid text-w-solid-text"
  let hover_classes = "hover:bg-w-solid/80"

  badge(
    [
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      ..attributes
    ],
    children,
  )
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
