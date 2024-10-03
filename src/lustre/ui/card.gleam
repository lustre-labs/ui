// IMPORTS ---------------------------------------------------------------------

import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// CONSTANTS -------------------------------------------------------------------

const card_base_classes = "border border-w-accent-subtle bg-w-bg-subtle [&>*+*]:pt-0"

const card_header_classes = "flex flex-col space-y-w-xs p-w-xl"

const card_title_classes = "font-semibold leading-none tracking-tight"

const card_description_classes = "text-w-text-subtle"

const card_content_classes = "p-w-xl"

const card_footer_classes = "flex items-center p-w-xl"

// ELEMENTS --------------------------------------------------------------------

pub fn simple(
  attributes: List(Attribute(msg)),
  content content_children: List(Element(msg)),
) -> Element(msg) {
  custom(attributes, [content([], content_children)])
}

pub fn with_header(
  attributes: List(Attribute(msg)),
  header header_children: List(Element(msg)),
  content content_children: List(Element(msg)),
) -> Element(msg) {
  custom(attributes, [
    header([], header_children),
    content([], content_children),
  ])
}

pub fn with_footer(
  attributes: List(Attribute(msg)),
  content content_children: List(Element(msg)),
  footer footer_children: List(Element(msg)),
) -> Element(msg) {
  custom(attributes, [
    content([], content_children),
    footer([], footer_children),
  ])
}

pub fn custom(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.article([attribute.class(card_base_classes), ..attributes], children)
  // [
  //   case list.is_empty(header_children) {
  //     True -> html.text("")
  //     False -> header([], header_children)
  //   },
  //   content([], content_children),
  //   case list.is_empty(footer_children) {
  //     True -> html.text("")
  //     False -> footer([], footer_children)
  //   },
  // ])
}

pub fn header(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.header([attribute.class(card_header_classes), ..attributes], children)
}

pub fn title(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.h3([attribute.class(card_title_classes), ..attributes], children)
}

pub fn description(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.p([attribute.class(card_description_classes), ..attributes], children)
}

pub fn content(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.main([attribute.class(card_content_classes), ..attributes], children)
}

pub fn footer(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.footer([attribute.class(card_footer_classes), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------
// BORDER RADIUS

pub fn square() -> Attribute(msg) {
  attribute.class("rounded-none")
}

pub fn round() -> Attribute(msg) {
  attribute.class("rounded-w-sm")
}

// COLOURS

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
