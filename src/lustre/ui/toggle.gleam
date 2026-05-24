//// <script>
//// const docs = [
////   {
////     header: "Elements",
////     functions: [
////       "register",
////       "view",
////       "group",
////       "item",
////     ]
////   },
////   {
////     header: "Attributes",
////     sort: true,
////     functions: [
////       "disabled",
////       "default_pressed",
////       "pressed",
////       "value",
////       "default_selected",
////       "selected",
////       "loop",
////     ]
////   },
////   {
////     header: "Events",
////     sort: true,
////     functions: [
////       "on_press",
////       "on_selected_change",
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
//// A toggle is a special kind of two-state button that can either on or off.
//// Unlike the native checkbox element, a toggle must be styled appropriately to
//// communicate on/off status to sighted users.
////
//// ```gleam
//// toggle.view([], [todo])
////
//// toggle.group([], [
////   toggle.item("wibble", [], [todo]),
////   toggle.item("wobble", [], [todo])
//// ])
//// ```
////
//// - [`toggle.view`](#view) is an individual toggle button. When activated it
////   toggles between pressed and unpressed states.
////
//// - [`toggle.group`](#group) is a container for one or more toggle items. It
////   manages selection state among its children - similar to a radio group -
////   and handles keyboard navigation between them.
////
//// - Each [`toggle.item`](#item) in a group is an individual toggle button with
////   a unique value that identifies it within the group.
////
//// ## Accessibility
////
//// The toggle component follows the WAI-ARIA Authoring Practices for the
//// [toggle button pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/).
//// This means appropriate roles and ARIA attributes are handled for you,
//// including:
////
//// - `role` "button" on the toggle element, as well as managed `aria-pressed`
////   and `aria-disabled` attributes.
////
//// - `role` "group" on the toggle group element, as well as managed `aria-orientation`.
////
//// ## Usage notes
////
//// Because a toggle has no innate indicator of its pressed state, it's essential
//// that any toggle has appropriate visual styling to communicate its state to
//// sighted users.
////
//// Toggles and toggle groups can participate in HTML form submission the same
//// as native form controls by giving the control a [`name`](https://hexdocs.pm/lustre/lustre/attribute.html#name).
////
//// ## Recipes
////
//// You can use these recipes as starting points for common uses of toggled inputs
//// and toggle groups. Copy and paste them into your apps and adapt them as needed!
////
//// ### Basic use
////
//// ```gleam
//// ```
////
//// ### Grouping toggle items
////
//// ```gleam
//// ```
////
//// ### Using a toggle in a form
////
//// ```gleam
//// ```
////

// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/set
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/keyed
import lustre/ui/toggle/group
import lustre/ui/toggle/root

// TYPES -----------------------------------------------------------------------

pub opaque type Item(message) {
  Item(
    value: String,
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

/// Register the toggle and toggle group components. This must be called before
/// using the component in your application, but you may prefer to call
/// [`ui.register`](../ui.html#register) instead, which registers all lustre/ui
/// components at once. Typically this is called just before starting your Lustre
/// application.
///
/// The following custom elements will be registered:
///
/// - `<lustre-toggle>`
/// - `<lustre-toggle-group>`
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(root.register())
  use _ <- result.try(group.register())

  Ok(Nil)
}

/// An individual toggle button. When activated it toggles between pressed and
/// unpressed states.
///
/// #### Tag
///
/// ```html
/// <lustre-toggle>
/// ```
///
/// #### Attributes
///
/// [`default_pressed`](#default_pressed), [`disabled`](#disabled), [`pressed`](#pressed),
/// [`value`](#value).
///
/// #### Events
///
/// [`on_press`](#on_press).
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(pressed)` is applied when the toggle is pressed.
/// - `:state(disabled)` is applied when the toggle is disabled.
///
/// #### Accessibility notes
///
/// A toggle can receive focus and be activated using the keyboard by pressing
/// either the Enter or Space keys.
///
/// The toggle must have an accessible text label for non-sighted uses. This can
/// be text content inside the toggle element itself, an associated `<label>` for
/// toggles used in forms, or an `aria-label` attribute.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-disabled`
/// - `aria-pressed`
/// - `role`
///
pub fn view(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  root.element(attributes, children)
}

/// A group of toggle buttons. Only one toggle may be pressed at a time.
///
/// #### Tag
///
/// ```html
/// <lustre-toggle>
/// ```
///
/// #### Attributes
///
/// [`default_pressed`](#default_pressed), [`disabled`](#disabled), [`loop`](#loop),
/// [`pressed`](#pressed), [`value`](#value).
///
/// #### Events
///
/// [`on_selected_change`](#on_selected_change).
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(disabled)` is applied when the entire group is disabled.
///
/// #### Accessibility notes
///
/// The toggle group supports keyboard navigation between individual toggles
/// using the following keys _instead of_ to the standard tabbing behaviour:
///
/// - When in a vertical group...
///   - Arrow Up moves focus to the previous toggle.
///   - Arrow Down moves focus to the next toggle.
/// - When in a horizontal group...
///   - Arrow Left moves focus to the previous toggle.
///   - Arrow Right moves focus to the next toggle.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-orientation`
/// - `role`
///
pub fn group(
  attributes: List(Attribute(message)),
  children: List(Item(message)),
) -> Element(message) {
  let #(items, _) =
    list.fold_right(children, #([], set.new()), fn(acc, item) {
      use <- bool.guard(item.value == "", acc)
      use <- bool.guard(set.contains(acc.1, item.value), acc)
      let html = view([value(item.value), ..item.attributes], item.children)
      let items = [#(item.value, html), ..acc.0]
      let seen = set.insert(acc.1, item.value)

      #(items, seen)
    })

  keyed.element(group.tag, attributes, items)
}

/// An individual toggle as part of a [`group`](#group). Each item should have a
/// unique value in the group: empty or duplicate values will be ignored.
///
/// For more detailed documentation, refer to the [`toggle.view`](#view) element.
///
pub fn item(
  value: String,
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Item(message) {
  Item(value:, attributes:, children:)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Disable a [toggle](#root) or [toggle group](#group). Disabled toggles cannot
/// be interacted with and should be styled appropriately to communicate this to
/// sighted users. When a group is disabled, the user will still be able to navigate
/// to each item using the keyboard, but they will not be able to activate any of
/// the items.
///
pub fn disabled(value: Bool) -> Attribute(message) {
  root.disabled(value)
}

/// Set whether an individual [toggle](#root) is pressed when it is first rendered.
/// This is only useful for uncontrolled toggles or for server-side rendering. To
/// control the pressed state of a toggle in your app, use the [`pressed`](#pressed)
/// attribute instead.
///
/// > **Note**: an uncontrolled component is responsible for managing its own state
/// > and subsequent changes to `default_pressed` will not be reflected in the
/// > component after the initial render.
/// >
/// > To control the toggle component's state from your application, use the
/// > [`pressed`](#pressed) attribute instead.
///
pub fn default_pressed(value: Bool) -> Attribute(message) {
  root.default_pressed(value)
}

/// Sets the pressed state for a _controlled_ toggle.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_press`](#on_press) event.
/// >
/// > To let the component manage its own state, use the [`default_pressed`](#default_pressed)
/// > attribute to set the initial pressed state of a toggle instead.
///
pub fn pressed(value: Bool) -> Attribute(message) {
  root.pressed(value)
}

/// Sets the value to be included in form submission for a pressed [toggle](#view).
/// If this attribute is not set, a toggle behaves like a HTML checkbox input and
/// sends the value `"on"` when pressed.
///
pub fn value(value: String) -> Attribute(message) {
  attribute("value", value)
}

/// Set the default selected item in a [toggle group](#group) by value. This is
/// only useful for uncontrolled groups or for server-side rendering. To control
/// the selected item in your app, use the [`selected`](#selected) attribute instead.
///
pub fn default_selected(value: Option(String)) -> Attribute(message) {
  group.default_value(value)
}

/// Set the selected item in a _controlled_ [toggle group](#group) by its value,
/// or `None` to clear any selection.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_selected_change`](#on_selected_change) event.
///
pub fn selected(value: Option(String)) -> Attribute(message) {
  group.value(value)
}

/// When `True`, the loop attribute allows users to cycle through the toggle
/// items in a group by navigating past the first or last item using the keyboard.
///
/// > **Note**: be mindful of the accessibility implications of this attribute.
/// > If the toggle group exists inside another container that also relies on
/// > keyboard navigation, like a menu or toolbar, you may trap users inside
/// > the toggle group by enabling looping.
///
pub fn loop(value: Bool) -> Attribute(message) {
  group.loop(value)
}

// EVENTS ----------------------------------------------------------------------

/// An event emitted by individual [toggles](#view) when they are pressed.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on a parent [toggle group](#group).
///
pub fn on_press(handler: fn(Bool) -> message) -> Attribute(message) {
  root.on_press(handler)
}

/// This event is emitted by a [toggle group](#group) when any of its child items
/// are pressed. The provided handler is called with either the value of the
/// pressed item, or `None` if an already-selected item is deselected.
///
pub fn on_selected_change(
  handler: fn(Option(String)) -> message,
) -> Attribute(message) {
  group.on_change(handler)
}
