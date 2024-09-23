// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// CONSTANTS -------------------------------------------------------------------

const base_classes = "px-lui-sm py-lui-xs translate-y-0"

const active_classes = "active:translate-y-px"

const disabled_classes = "disabled:opacity-50"

// ELEMENTS --------------------------------------------------------------------

pub fn clear(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = " bg-transparent"
  let hover_classes = "hover:bg-lui-tint-subtle"

  html.button(
    [
      attribute.class(base_classes),
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      attribute.class(active_classes),
      attribute.class(disabled_classes),
      ..attributes
    ],
    children,
  )
}

pub fn soft(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "bg-lui-tint"
  let hover_classes = "hover:bg-lui-tint-strong"

  html.button(
    [
      attribute.class(base_classes),
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      attribute.class(active_classes),
      attribute.class(disabled_classes),
      ..attributes
    ],
    children,
  )
}

pub fn solid(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "bg-lui-solid text-lui-solid-text"
  let hover_classes = "hover:bg-lui-solid-subtle"

  html.button(
    [
      attribute.class(base_classes),
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      attribute.class(active_classes),
      attribute.class(disabled_classes),
      ..attributes
    ],
    children,
  )
}

pub fn outline(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  let colour_classes = "bg-transparent border border-lui-solid"
  let hover_classes = "hover:bg-lui-tint-subtle"

  html.button(
    [
      attribute.class(base_classes),
      attribute.class(colour_classes),
      attribute.class(hover_classes),
      attribute.class(active_classes),
      attribute.class(disabled_classes),
      ..attributes
    ],
    children,
  )
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn rounded() -> Attribute(msg) {
  attribute.class("rounded-lui-sm")
}

pub fn pill() -> Attribute(msg) {
  attribute.class("rounded-lui-xl")
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

// INTERNALS -------------------------------------------------------------------

@internal
pub fn demo() -> Element(msg) {
  html.div([attribute.class("flex flex-col gap-lui-sm p-lui-sm")], [
    demo_group("clear"),
    demo_group("outline"),
    demo_group("soft"),
    demo_group("solid"),
  ])
}

fn demo_group(kind: String) -> Element(msg) {
  html.div([attribute.class("flex gap-lui-sm")], [
    demo_button(kind, base()),
    demo_button(kind, primary()),
    demo_button(kind, secondary()),
    demo_button(kind, success()),
    demo_button(kind, warning()),
    demo_button(kind, danger()),
  ])
}

fn demo_button(kind: String, classes: Attribute(msg)) -> Element(msg) {
  case kind {
    "clear" -> clear([classes], [html.text("button")])
    "outline" -> outline([classes], [html.text("button")])
    "soft" -> soft([classes, rounded()], [html.text("button")])
    "solid" -> solid([classes, pill()], [html.text("button")])
    _ -> soft([classes], [html.text("button")])
  }
}
