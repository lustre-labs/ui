import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/icon

// CONSTANTS -------------------------------------------------------------------

const base_list_classes = "flex flex-wrap items-center gap-w-xs break-words text-sm text-w-text-subtle sm:gap-w-sm"

const base_item_classes = "inline-flex items-center gap-1.5"

const base_link_classes = "hover:text-w-text"

const base_page_classes = "font-normal text-w-text"

const base_separator_classes = "[&>svg]:size-3.5"

const base_ellipsis_classes = "flex size-9 items-center justify-center"

// ELEMENTS --------------------------------------------------------------------

pub fn breadcrumb(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.nav([attribute("aria-label", "breadcrumb")], [
    html.ol([attribute.class(base_list_classes), ..attributes], children),
  ])
}

pub fn item(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.li([attribute.class(base_item_classes), ..attributes], children)
}

pub fn link(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.a([attribute.class(base_link_classes), ..attributes], children)
}

pub fn page(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.span(
    [
      attribute.class(base_page_classes),
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
      attribute.class(base_separator_classes),
      attribute.role("presentation"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [chevron_right_icon()],
  )
}

pub fn ellipsis(attributes: List(Attribute(msg))) -> Element(msg) {
  html.span(
    [
      attribute.class(base_ellipsis_classes),
      attribute.role("presentation"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [
      dots_horizontal_icon(),
      html.span([attribute.class("sr-only")], [element.text("More")]),
    ],
  )
}

// HELPER FUNCTIONS ------------------------------------------------------------

fn chevron_right_icon() -> Element(msg) {
  icon.caret_right([attribute.class("size-3")])
}

fn dots_horizontal_icon() -> Element(msg) {
  icon.dots_horizontal([attribute.class("size-3")])
}
