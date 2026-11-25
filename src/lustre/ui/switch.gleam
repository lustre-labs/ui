//// <script>
//// const docs = [
////   {
////     header: "Elements",
////     functions: [
////       "register",
////       "view",
////     ]
////   },
////   {
////     header: "Attributes",
////     sort: true,
////     functions: [
////       "disabled",
////       "default_checked",
////       "checked",
////       "value",
////     ]
////   },
////   {
////     header: "Events",
////     sort: true,
////     functions: [
////       "on_checked_change",
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
//// A switch is a two-state control that can be either on or off. Unlike a
//// [toggle](./toggle.html), which represents a pressed or unpressed button, a
//// switch represents a setting that takes effect immediately - like the native
//// checkbox element it is said to be _checked_ when it is on.
////
//// ```gleam
//// switch.view([], [todo])
//// ```
////
//// - [`switch.view`](#view) is the switch itself. When activated it toggles
////   between checked and unchecked states. Any children - typically a single
////   element styled as the switch's thumb - are rendered inside the switch.
////
//// ## Accessibility
////
//// The switch component follows the WAI-ARIA Authoring Practices for the
//// [switch pattern](https://www.w3.org/WAI/ARIA/apg/patterns/switch/). This
//// means appropriate roles, ARIA attributes, and keyboard interactions are
//// handled for you, including:
////
//// - `role` "switch" on the switch element, as well as managed `aria-checked`
////   and `aria-disabled` attributes.
////
//// - Keyboard interactions for toggling the switch using the Enter or Space keys.
////
//// ## Usage notes
////
//// Because a switch has no innate indicator of its checked state, it's essential
//// that any switch has appropriate visual styling to communicate its state to
//// sighted users. The label of a switch should not change when its state changes.
////
//// There is no separate element for a switch's thumb. Render any element as a
//// child of the switch and style it based on the custom states of the parent
//// switch instead.
////
//// Switches can participate in HTML form submission the same as native form
//// controls by giving the control a [`name`](https://hexdocs.pm/lustre/lustre/attribute.html#name).
////
//// ## Recipes
////
//// You can use these recipes as starting points for common uses of switches.
//// Copy and paste them into your apps and adapt them as needed!
////
//// ### Basic use
////
//// The basic scaffold for using the switch component. In this default
//// configuration, the checked state is uncontrolled and managed internally by
//// the component.
////
//// ```gleam
//// html.label([], [
////   switch.view([], [html.span([], [])]),
////   html.text("Wibble"),
//// ])
//// ```
////
//// ```css
//// lustre-switch > span {
////   transition: translate 150ms;
//// }
////
//// lustre-switch:state(checked) > span {
////   translate: 100% 0;
//// }
//// ```
////
//// ### Using a switch in a form
////
//// ```gleam
//// html.form([event.on_submit(handle_submit)], [
////   html.label([], [
////     switch.view([attribute.name("wibble"), switch.value("wobble")], [
////       html.span([], []),
////     ]),
////     html.text("Wibble"),
////   ]),
////   html.button([attribute.type_("submit")], [html.text("Submit")]),
//// ])
//// ```
////

// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/ui/switch/root

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

/// Register the switch component. This must be called before using the component
/// in your application, but you may prefer to call [`ui.register`](../ui.html#register)
/// instead, which registers all lustre/ui components at once. Typically this is
/// called just before starting your Lustre application.
///
/// The following custom elements will be registered:
///
/// - `<lustre-switch>`
///
pub fn register() -> Result(Nil, lustre.Error) {
  root.register()
}

/// An individual switch. When activated it toggles between checked and unchecked
/// states.
///
/// #### Tag
///
/// ```html
/// <lustre-switch>
/// ```
///
/// #### Attributes
///
/// [`checked`](#checked), [`default_checked`](#default_checked),
/// [`disabled`](#disabled), [`value`](#value).
///
/// #### Events
///
/// [`on_checked_change`](#on_checked_change).
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(checked)` is applied when the switch is checked.
/// - `:state(disabled)` is applied when the switch is disabled.
///
/// #### Accessibility notes
///
/// A switch can receive focus and be activated using the keyboard by pressing
/// either the Enter or Space keys.
///
/// The switch must have an accessible text label for non-sighted uses. This can
/// be text content inside the switch element itself, an associated `<label>`,
/// or an `aria-label` attribute.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-checked`
/// - `aria-disabled`
/// - `role`
///
pub fn view(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  root.element(attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Disable a [switch](#view). Disabled switches cannot be interacted with and
/// should be styled appropriately to communicate this to sighted users. The user
/// will still be able to focus a disabled switch using the keyboard, but they
/// will not be able to activate it.
///
pub fn disabled(value: Bool) -> Attribute(message) {
  root.disabled(value)
}

/// Set whether a [switch](#view) is checked when it is first rendered. This is
/// only useful for uncontrolled switches or for server-side rendering. To control
/// the checked state of a switch in your app, use the [`checked`](#checked)
/// attribute instead.
///
/// > **Note**: an uncontrolled component is responsible for managing its own state
/// > and subsequent changes to `default_checked` will not be reflected in the
/// > component after the initial render.
/// >
/// > To control the switch component's state from your application, use the
/// > [`checked`](#checked) attribute instead.
///
pub fn default_checked(value: Bool) -> Attribute(message) {
  root.default_checked(value)
}

/// Sets the checked state for a _controlled_ switch.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_checked_change`](#on_checked_change) event.
/// >
/// > To let the component manage its own state, use the [`default_checked`](#default_checked)
/// > attribute to set the initial checked state of a switch instead.
///
pub fn checked(value: Bool) -> Attribute(message) {
  root.checked(value)
}

/// Sets the value to be included in form submission for a checked [switch](#view).
/// If this attribute is not set, a switch behaves like a HTML checkbox input and
/// sends the value `"on"` when checked.
///
pub fn value(value: String) -> Attribute(message) {
  root.value(value)
}

// EVENTS ----------------------------------------------------------------------

/// An event emitted by a [switch](#view) when the user toggles it. The provided
/// handler is called with the new checked state of the switch.
///
pub fn on_checked_change(handler: fn(Bool) -> message) -> Attribute(message) {
  root.on_change(handler)
}
