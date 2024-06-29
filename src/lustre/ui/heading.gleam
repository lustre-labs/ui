// IMPORTS ---------------------------------------------------------------------

import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/internals/attr
import lustre/ui/theme

// ATTRIBUTES ------------------------------------------------------------------

type Attribute(msg) =
  attr.Attribute(Heading, msg)

pub opaque type Heading {
  Options(size: String, line_height: String, colour: String)
}

fn default_options() {
  Options(size: "1.25rem", line_height: "1.75rem", colour: theme.base.text)
}

// ATTRIBUTES - SIZES ---------------------------------------------------------

/// Useful for smaller headings, normally as part of components.
///
pub fn extra_small() -> Attribute(msg) {
  attr.Attr(fn(options) {
    Options(..options, size: "0.875rem", line_height: "1.25rem")
  })
}

/// Useful for secondary headings.
///
pub fn small() -> Attribute(msg) {
  attr.Attr(fn(options) {
    Options(..options, size: "1.0rem", line_height: "1.5rem")
  })
}

/// Useful for main headings like page titles.
///
pub fn large() -> Attribute(msg) {
  attr.Attr(fn(options) {
    Options(..options, size: "1.5rem", line_height: "2rem")
  })
}

/// Useful for marketing websites with big banners.
///
pub fn extra_large() -> Attribute(msg) {
  attr.Attr(fn(options) {
    Options(..options, size: "2.25rem", line_height: "2.5rem")
  })
}

// ATTRIBUTES - COLOURS --------------------------------------------------------

/// Colors your heading with the primary theme color.
///
pub fn subtle() -> Attribute(msg) {
  attr.Attr(fn(options) { Options(..options, colour: theme.base.text_subtle) })
}

/// Colors your heading with the primary theme color.
///
pub fn primary() -> Attribute(msg) {
  attr.Attr(fn(options) { Options(..options, colour: theme.primary.text) })
}

/// Colors your heading with the secondary theme color.
///
pub fn secondary() -> Attribute(msg) {
  attr.Attr(fn(options) { Options(..options, colour: theme.secondary.text) })
}

// VIEWS -----------------------------------------------------------------------

pub fn view(
  attributes attributes: List(Attribute(msg)),
  children children: List(Element(msg)),
) {
  let options = attr.to_options(attributes, default_options())

  html.h1(
    [
      attribute.style([
        #("font-size", options.size),
        #("line-height", options.line_height),
        #("color", options.colour),
      ]),
    ],
    children,
  )
}
