//// <script>
//// const docs = [
////   {
////     header: "Elements",
////     functions: [
////     ]
////   },
////   {
////     header: "Attributes",
////     sort: true,
////     functions: [
////     ]
////   },
////   {
////     header: "Events",
////     sort: true,
////     functions: [
////     ]
////   },
//// ]
////
//// const callback = () => {
////   const list = document.querySelector(".sidebar > ul:last-of-type")
////   const sortedLists = document.createDocumentFragment()
////   const sortedMembers = document.createDocumentFragment()
////
////   for (const section of docs) {
////     sortedLists.append((() => {
////       const node = document.createElement("h3")
////       node.append(section.header)
////       return node
////     })())
////
////     sortedMembers.append((() => {
////       const node = document.createElement("h2")
////       node.append(section.header)
////       return node
////     })())
////
////     const sortedList = document.createElement("ul")
////     sortedLists.append(sortedList)
////
////     if (section.sort) {
////       section.functions.sort()
////     }
////
////     for (const funcName of section.functions) {
////       const href = `#${funcName}`
////       const member = document.querySelector(
////         `.member:has(h2 > a[href="${href}"])`
////       )
////       const sidebar = list.querySelector(`li:has(a[href="${href}"])`)
////       sortedList.append(sidebar)
////       sortedMembers.append(member)
////     }
////   }
////
////   document.querySelector(".sidebar").insertBefore(sortedLists, list)
////   document
////     .querySelector(".module-members:has(#module-values)")
////     .insertBefore(
////       sortedMembers,
////       document.querySelector("#module-values").nextSibling
////     )
//// }
////
//// document.readyState !== "loading"
////   ? callback()
////   : document.addEventListener("DOMContentLoaded", callback, { once: true })
//// </script>
////
//// <!--- ----------------------------------------------------------------- -->
////
//// A tooltip is a hint for sighted users that appears when an element is hovered
//// or receives keyboard focus. Tooltips are helpful in visually dense interfaces
//// to provide additional context or information about an action or element.
////
//// ```gleam
//// tooltip.view(
////   [],
////   popover: tooltip.popover([], [todo]),
////   trigger: tooltip.trigger([], [todo]),
//// )
//// ```
////
//// - [`tooltip.view`](#view) is the root container for both the trigger element
////   and its popopver.
////
//// - The [`tooltip.popover`](#popover) contains the content that should be
////   revealed on hover.
////
//// ## Accessibility
////
//// Tooltips are supplementary aides for sighted users, and have some important
//// accessibility concerns that must be accounted for. For non-sighted users,
//// **tooltips are never a substitute for accessible labels** as the popover
//// content is not accessible to screen readers. Additionally, users of touch
//// devices may not be able to reliably trigger the tooltip.
////

// IMPORTS ---------------------------------------------------------------------

import gleam/result
import lustre
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/ui/tooltip/popover
import lustre/ui/tooltip/root
import lustre/ui/tooltip/trigger

// TYPES -----------------------------------------------------------------------

pub opaque type Popover(message) {
  Popover(
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

pub opaque type Trigger(message) {
  Trigger(
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

pub type Side {
  Top
  Right
  Bottom
  Left
}

pub type Alignment {
  Start
  Centre
  End
}

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(root.register())
  use _ <- result.try(trigger.register())
  use _ <- result.try(popover.register())

  Ok(Nil)
}

///
///
pub fn view(
  attributes: List(Attribute(message)),
  popover popover: Popover(message),
  trigger trigger: Trigger(message),
) -> Element(message) {
  root.element(attributes, [
    trigger.element(trigger.attributes, trigger.children),
    popover.element(popover.attributes, popover.children),
  ])
}

///
///
pub fn popover(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Popover(message) {
  Popover(attributes:, children:)
}

///
///
pub fn trigger(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Trigger(message) {
  Trigger(attributes:, children:)
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn delay(amount: Int) -> Attribute(message) {
  trigger.delay(amount)
}

///
///
pub fn offset(value: Float) -> Attribute(message) {
  popover.offset(value)
}

///
///
pub fn side(value: Side) -> Attribute(message) {
  popover.side(case value {
    Top -> "top"
    Right -> "right"
    Bottom -> "bottom"
    Left -> "left"
  })
}

///
///
pub fn align(value: Alignment) -> Attribute(message) {
  case value {
    Start -> popover.align("start")
    Centre -> attribute.none()
    End -> popover.align("end")
  }
}

///
///
pub fn open(value: Bool) -> Attribute(message) {
  popover.open(value)
}

///
///
pub fn default_open(value: Bool) -> Attribute(message) {
  popover.default_open(value)
}
