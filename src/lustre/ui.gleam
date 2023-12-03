// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/ui/aside
import lustre/ui/box
import lustre/ui/breadcrumbs
import lustre/ui/button
import lustre/ui/centre
import lustre/ui/cluster
import lustre/ui/colour.{type Scale}
import lustre/ui/field
import lustre/ui/group
import lustre/ui/input
import lustre/ui/sequence
import lustre/ui/stack
import lustre/ui/tag

// TYPES -----------------------------------------------------------------------

/// A theme is a collection of colour scales that define the look and feel of
/// your application. You can consider the "primary" scale as your brand or 
/// accent colour. The "greyscale" scale can be used when you want suitable
/// shading without any particular colour or meaning. The "error", "warning",
/// "success", and "info" scales are semantic colours that can be used to communicate
/// meaning to the user.
/// 
pub type Theme {
  Theme(
    primary: Scale,
    greyscale: Scale,
    error: Scale,
    warning: Scale,
    success: Scale,
    info: Scale,
  )
}

/// This type enumerates the different colour scales that are available in a 
/// theme. It is mostly used to set the variant of an element using the
/// `variant` attribute, but you could also use it in your own custom elements.
/// 
pub type Variant {
  Primary
  Greyscale
  Error
  Warning
  Success
  Info
}

// ELEMENTS --------------------------------------------------------------------

pub const aside: fn(List(Attribute(msg)), Element(msg), Element(msg)) ->
  Element(msg) = aside.aside

pub const box: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = box.box

pub const breadcrumbs: fn(
  List(Attribute(msg)),
  Element(msg),
  List(Element(msg)),
) ->
  Element(msg) = breadcrumbs.breadcrumbs

pub const button: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = button.button

pub const centre: fn(List(Attribute(msg)), Element(msg)) -> Element(msg) = centre.centre

pub const cluster: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = cluster.cluster

pub const field: fn(
  List(Attribute(msg)),
  List(Element(msg)),
  Element(msg),
  List(Element(msg)),
) ->
  Element(msg) = field.field

pub const group: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = group.group

pub const input: fn(List(Attribute(msg))) -> Element(msg) = input.input

pub const sequence: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = sequence.sequence

pub const stack: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = stack.stack

pub const tag: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg) = tag.tag

// ATTRIBUTES ------------------------------------------------------------------

/// Use this attribute to set the colour scale of an element. Unless a child
/// element sets its own variant, it will inherit the variant of its parent. You
/// could, for example, set the variant on some custom alert element to be 
/// `Warning`. Then, any buttons or icons inside the alert will inherit the
/// warning palette and be coloured accordingly.
/// 
pub fn variant(variant: Variant) -> Attribute(a) {
  attribute(
    "data-variant",
    case variant {
      Primary -> "primary"
      Greyscale -> "greyscale"
      Error -> "error"
      Warning -> "warning"
      Success -> "success"
      Info -> "info"
    },
  )
}
