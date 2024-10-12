// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

pub fn divider(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  case children {
    [] -> {
      html.hr([
        attribute.class("self-stretch border-solid border-0"),
        attribute.class("border-[var(--l-divider-colour)]"),
        attribute.style([
          #("border-top-width", "var(--l-divider-size-x)"),
          #("border-left-width", "var(--l-divider-size-y)"),
          #("margin", "var(--l-divider-margin) " <> "0"),
          ..css_variables_setup()
        ]),
        ..attributes
      ])
    }

    _ -> {
      html.div(
        [
          attribute.class("self-stretch"),
          attribute.class(
            "flex items-center justify-center gap-w-sm leading-none",
          ),
          attribute.class("text-sm"),
          attribute.class("before:content-[''] before:block before:grow"),
          attribute.class("after:content-[''] after:block after:grow"),
          attribute.class(
            "before:w-[var(--l-divider-size-y)] before:h-[var(--l-divider-size-x)]",
          ),
          attribute.class(
            "after:w-[var(--l-divider-size-y)] after:h-[var(--l-divider-size-x)]",
          ),
          attribute.class(
            "before:bg-[var(--l-divider-colour)] after:bg-[var(--l-divider-colour)]",
          ),
          attribute.style([
            #("margin", "var(--l-divider-margin) " <> "0"),
            ..css_variables_setup()
          ]),
          ..attributes
        ],
        children,
      )
    }
  }
}

fn css_variables_setup() {
  [
    #("--l-divider-colour", colour_tint),
    #("--l-divider-size", default_width),
    #("--l-divider-size-x", "var(--l-divider-size)"),
    #("--l-divider-size-y", "0"),
    #("--l-divider-margin", "0"),
  ]
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn vertical() -> Attribute(msg) {
  attribute.style([
    #("flex-direction", "column"),
    #("--l-divider-size-x", "0"),
    #("--l-divider-size-y", "var(--l-divider-size)"),
    #("margin", "0 var(--l-divider-margin)"),
  ])
}

// ATTRIBUTES ------------------------------------------------------------------
// COLOUR

pub fn subtle() -> Attribute(msg) {
  attribute.style([#("--l-divider-subtle", colour_tint_subtle)])
}

pub fn thin() -> Attribute(msg) {
  attribute.style([#("--l-divider-size", "1px")])
}

// ATTRIBUTES ------------------------------------------------------------------
// WIDTH

pub fn width(width: String) -> Attribute(msg) {
  attribute.style([#("--l-divider-size", width)])
}

pub fn colour(colour: String) -> Attribute(msg) {
  attribute.style([#("--l-divider-colour", colour)])
}

// ATTRIBUTES ------------------------------------------------------------------
// MARGIN

pub fn margin(margin: String) -> Attribute(msg) {
  attribute.style([#("--l-divider-margin", margin)])
}

// HELPERS & CONSTANTS ---------------------------------------------------------

const default_width = "2px"

const colour_tint = "rgb(var(--lustre-ui-tint))"

const colour_tint_subtle = "rgb(var(--lustre-ui-tint-subtle))"
