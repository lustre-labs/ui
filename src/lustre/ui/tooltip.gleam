//// <script>
//// const docs = [
////   {
////     header: "Elements",
////     functions: [
////       "register",
////       "view",
////       "popover",
////       "trigger",
////     ]
////   },
////   {
////     header: "Attributes",
////     sort: true,
////     functions: [
////       "align",
////       "default_open",
////       "delay",
////       "offset",
////       "open",
////       "side",
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
//// - The [`tooltip.trigger`](#trigger) contains the element that will trigger
////   the popover when hovered or focused.
////
//// ## Accessibility
////
//// Tooltips are supplementary aides for sighted users, and have some important
//// accessibility concerns that must be accounted for. For non-sighted users,
//// **tooltips are never a substitute for accessible labels** as the popover
//// content is not accessible to screen readers. Additionally, users of touch
//// devices may not be able to reliably trigger the tooltip. Because of this,
//// the content rendered inside a tooltip's popover is considered inert and must
//// not be interactive.
////
//// ## Usage notes
//// 
//// The content inside the tooltip's popover is marked as inert and should not
//// contain interactive elements like links or buttons.
//// 
//// ## Recipes
//// 
//// You can use these recipes as starting points for tooltips. Copy and paste
//// them into your apps and adapt them as needed!
//// 
//// ### Basic use
////
//// ```gleam
//// tooltip.view(
////   [],
////   popover: tooltip.popover([], [
////     text("Tooltip content")
////   ]),
////   trigger: tooltip.trigger([], [
////     text("Hover me")
////   ]),
//// )
//// ```
////
//// ### No delay
////
//// ```gleam
//// tooltip.view(
////   [tooltip.delay(0)],
////   popover: tooltip.popover([], [
////     text("Tooltip content")
////   ]),
////   trigger: tooltip.trigger([], [
////     text("Hover me")
////   ]),
//// )
//// ```
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

/// The side of the trigger element that the tooltip popover should appear on.
/// Used with the [`side`](#side) attribute.
///
pub type Side {
  Top
  Right
  Bottom
  Left
}

/// The alignment of the tooltip popover relative to the trigger element.
/// Used with the [`align`](#align) attribute.
///
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

/// Register the tooltip component and its parts. This must be called before using
/// the component(s) in your application, but you may prefer to call
/// [`ui.register`](../ui.html#register) instead to register all lustre/ui components
/// at once. Typically this is called just before starting your Lustre application.
/// 
/// The following custom elements will be registered:
/// 
/// - `<lustre-tooltip>`
/// - `<lustre-tooltip-popover>`
/// - `<lustre-tooltip-trigger>`
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(root.register())
  use _ <- result.try(trigger.register())
  use _ <- result.try(popover.register())

  Ok(Nil)
}

/// The root tooltip element is a container for both the trigger and popover
/// content.
///
/// #### Tag
///
/// ```html
/// <lustre-tooltip>
/// ```
///
/// #### Attributes
///
/// [`default_open`](#default_open), [`delay`](#delay), [`open`](#open).
///
/// #### Styling
///
/// This element has a default display of `contents` and does not affect layout
/// on its own. Prefer styling the trigger and popover elements directly where
/// possible.
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

/// The tooltip popover contains the content that is revealed when the
/// associated trigger is hovered or receives keyboard focus.
///
/// #### Tag
///
/// ```html
/// <lustre-tooltip-popover>
/// ```
///
/// #### Attributes
///
/// [`align`](#align), [`default_open`](#default_open), [`offset`](#offset),
/// [`open`](#open), [`side`](#side).
///
/// #### Styling
///
/// This element has a default display of `inline` when open and `none` when
/// closed.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(open)` is applied when the popover is visible.
/// - `:state(top)`, `:state(right)`, `:state(bottom)`, `:state(left)` reflect
///   the current placement side.
/// - `:state(start)` and `:state(end)` reflect the current alignment.
///
/// The following CSS custom properties are set on this element and can be
/// used to position the popover or style its children:
///
/// - `--tooltip-popover-x`
/// - `--tooltip-popover-y`
///
/// #### Accessibility notes
///
/// The content inside the tooltip popover is marked as
/// [inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert)
/// and must not contain any interactive elements such as links or buttons.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the popover, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `popover`
/// - `role`
///
pub fn popover(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Popover(message) {
  Popover(attributes:, children:)
}

/// The tooltip trigger wraps the element that will show and hide the popover
/// when hovered or focused.
///
/// #### Tag
///
/// ```html
/// <lustre-tooltip-trigger>
/// ```
///
/// #### Attributes
///
/// [`delay`](#delay).
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(open)` is applied when the associated tooltip popover is visible.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the trigger, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-describedby`
///
pub fn trigger(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Trigger(message) {
  Trigger(attributes:, children:)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Sets the delay in milliseconds before the tooltip popover is shown after the
/// trigger is hovered. Defaults to `50`. Set to `0` to show the tooltip
/// immediately on hover.
///
pub fn delay(amount: Int) -> Attribute(message) {
  trigger.delay(amount)
}

/// Sets the distance in pixels between the trigger element and the tooltip
/// popover. The offset is applied along the placement side, so if the popover is
/// placed on the [`Left`](#Left) of the trigger, an offset of `10` will move the
/// popover 10 pixels to the left of the trigger element. 
///
pub fn offset(value: Float) -> Attribute(message) {
  popover.offset(value)
}

/// Sets which side of the trigger element the tooltip popover should appear on.
/// Defaults to [`Top`](#Top).
///
pub fn side(value: Side) -> Attribute(message) {
  popover.side(case value {
    Top -> "top"
    Right -> "right"
    Bottom -> "bottom"
    Left -> "left"
  })
}

/// Sets the alignment of the tooltip popover relative to the trigger element
/// along the axis perpendicular to the placement side. Defaults to
/// [`Centre`](#Centre).
///
pub fn align(value: Alignment) -> Attribute(message) {
  case value {
    Start -> popover.align("start")
    Centre -> attribute.none()
    End -> popover.align("end")
  }
}

/// Set the open state of the tooltip popover, making it controlled by your
/// application.
///
/// > **Note**: in a controlled component, the state is managed by your
/// > application. Set this to `True` to force the popover to remain visible
/// > regardless of user interaction.
/// >
/// > To set whether the tooltip is initially open when first rendered, consider
/// > using the [`default_open`](#default_open) attribute instead.
///
pub fn open(value: Bool) -> Attribute(message) {
  popover.open(value)
}

/// Set whether the tooltip popover is open by default when first rendered in
/// an _uncontrolled_ tooltip.
///
/// > **Note**: an uncontrolled component is responsible for managing its own
/// > state and subsequent changes to `default_open` will not be reflected in
/// > the component after the initial render.
/// >
/// > To control the tooltip's open state from your application, use the
/// > [`open`](#open) attribute instead.
///
pub fn default_open(value: Bool) -> Attribute(message) {
  popover.default_open(value)
}
