//// An accordion is made up of one or more collapsible sections with content.
//// Each accordion item is made up of a header and a trigger button, and the
//// panel that contains the collapsible content.
////
//// ```gleam
//// accordion.view([], [
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], {
////       accordion.trigger([], [html.span([], [html.text("...")])])
////     }),
////     panel: accordion.panel([], [
////       html.p([], [html.text("...")]),
////       accordion.close([], [html.text("...")])
////     ]),
////   ),
//// ])
//// ```
////
//// - [`accordion.view`](#view) is the container for all accordion items. It
////   manages keyboard interaction and open state for each item.
////
//// - Each [`accordion.item`](#item) represents a single collapsible section
////   within the accordion. It must have a unique name within the accordion to
////   identify it.
////
//// - An [`accordion.heading`](#heading) contains the trigger button for the
////   item as its only child.
////
//// - The [`accordion.trigger`](#trigger) is the button that toggles the open
////   state of an accordion item. It must not contain any other interactive
////   elements.
////
//// - The [`accordion.panel`](#panel) contains the collapsible content for the
////   item.
////
//// - The optional [`accordion.close`](#close) trigger can be placed within the
////   panel content to provide an additional way to close the accordion item.
////
//// ## Accessibility
////
//// The accordion component follows the WAI-ARIA Authoring Practices for the
//// [accordion pattern](https://www.w3.org/WAI/ARIA/apg/patterns/accordion/).
//// This means appropriate roles, ARIA attributes, and keyboard interactions are
//// handled for you, including:
////
//// - `role` "region" on the accordion root, with managed `aria-orientation`
////   for horizontal or vertical accordions.
////
//// - `role` "heading" on each accordion item heading, with a default `aria-level`
////    of 3.
////
//// - `role` "button" on each accordion item trigger, with managed `aria-expanded`,
////   and `aria-controls` attributes.
////
//// - `role` "region" on each accordion item panel, with managed `aria-labelledby`
////   attribute.
////
//// - Keyboard interactions for navigation between accordion item triggers using
////   Arrow Up/Down, Arrow Left/Right, Home, and End keys.
////
//// - Retention of focus when accordion items are closed.
////
//// ## Usage notes
////
//// Avoid accordions with only one item, as they do not provide any functionality
//// not already provided by the native `<details>` HTML element.
////
//// ## Recipes
////
//// You can use these recipes as starting points to build common types of
//// accordions. Copy and paste them into your apps and adapt them as needed!
////
//// ### Basic use
////
//// The basic scaffold for any accordion. In this default configuration, the state
//// of the accordion is uncontrolled and managed internally. Only one item can
//// open at a time and keyboard navigation does not loop when reaching the first
//// or last item.
////
//// ```gleam
//// accordion.view([], [
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
//// ])
//// ```
////
//// ### Multiple open items, looping navigation
////
//// This configuration allows multiple accordion items to be open at once, and
//// keyboard navigation will loop back to the first item after the last, and vice
//// versa.
////
//// ```gleam
//// accordion.view([accordion.multiple(), accordion.loop(True)], [
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
//// ])
//// ```
////
//// ### Force item open
////
//// By explicitly setting the `open` attribute on an accordion item, it becomes
//// controlled and will always be open unless the the `open` attribute is changed.
//// This lets you pin certain items open or closed regardless of user interaction.
////
//// ```gleam
//// accordion.view([], [
////   accordion.item(
////     name: "...",
////     attributes: [accordion.open(True)],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
////   accordion.item(
////     name: "...",
////     attributes: [],
////     heading: accordion.heading([], accordion.trigger([], [todo])),
////     panel: accordion.panel([], [todo]),
////   ),
//// ])
//// ```
////

// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import lustre
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/keyed
import lustre/ui/accordion/heading
import lustre/ui/accordion/item
import lustre/ui/accordion/panel
import lustre/ui/accordion/root
import lustre/ui/accordion/trigger

// TYPES -----------------------------------------------------------------------

///
///
pub opaque type Item(message) {
  Item(
    name: String,
    attributes: List(Attribute(message)),
    heading: Element(message),
    panel: Panel(message),
  )
}

///
///
pub opaque type Trigger(message) {
  Trigger(
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

///
///
pub opaque type Panel(message) {
  Panel(attributes: List(Attribute(message)), children: List(Element(message)))
}

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

/// Register the accordion component and its parts. This must be called before
/// using the component in your application, but you may prefer to call
/// [`ui.register`](../ui.html#register) instead, which registers all lustre/ui
/// components at once. Typically this is called just before starting your Lustre
/// application.
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(root.register())
  use _ <- result.try(item.register())
  use _ <- result.try(heading.register())
  use _ <- result.try(trigger.register())
  use _ <- result.try(panel.register())

  Ok(Nil)
}

/// The root accordion element is a container for multiple accordion items.
///
/// #### Attributes
///
/// [`default_value`](#default_value), [`horizontal`](#horizontal), [`label`](#label),
/// [`loop`](#loop), [`multiple`](#multiple), [`single`](#single), [`value`](#value),
/// [`vertical`](#vertical).
///
/// #### Events
///
/// [`on_value_change`](#on_value_change)
///
/// #### Accessibility notes
///
/// The accordion supports keyboard navigation between accordion item triggers
/// using the following keys _in addition_ to the standard tabbing behaviour:
///
/// - Home moves focus to the first accordion item trigger.
/// - End moves focus to the last accordion item trigger.
/// - When in a vertical accordion...
///   - Arrow Up moves focus to the previous accordion item trigger.
///   - Arrow Down moves focus to the next accordion item trigger.
/// - When in a horizontal accordion...
///   - Arrow Left moves focus to the previous accordion item trigger.
///   - Arrow Right moves focus to the next accordion item trigger.
///
/// Authors may provide an accessible [`label`](#label) for the accordion to
/// help assistive technologies identify it, but this is not required.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the accordion, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `role`
///
pub fn view(
  attributes: List(Attribute(message)),
  children: List(Item(message)),
) -> Element(message) {
  keyed.element(root.tag, attributes, {
    use Item(name:, attributes:, heading:, panel:) <- list.filter_map(children)
    use <- bool.guard(name == "", Error(Nil))

    let html =
      item.element([item.name(name), ..attributes], [
        heading,
        panel.element(panel.attributes, panel.children),
      ])

    Ok(#(name, html))
  })
}

/// Each accordion item represents a single collapsible section within the
/// accordion. It must have a unique name within the accordion to identify it.
///
/// #### Attributes
///
/// [`default_open`](#default_open), [`open`](#open).
///
/// #### Events
///
/// [`on_hide`](#on_hide), [`on_open_change`](#on_open_change), [`on_show`](#on_show).
///
/// #### CSS states
///
/// - `:state(open)` is applied when the accordion item is expanded.
///
pub fn item(
  name name: String,
  attributes attributes: List(Attribute(message)),
  heading heading: Element(message),
  panel panel: Panel(message),
) -> Item(message) {
  Item(name:, attributes:, heading:, panel:)
}

/// An accordion heading heading contains the trigger button for an accordion
/// item as its only child.
///
/// #### Attributes
///
/// [`level`](#level).
///
/// #### CSS states
///
/// - `:state(open)` is applied when the containing accordion item is expanded.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the heading, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `role`
///
pub fn heading(
  attributes: List(Attribute(message)),
  trigger: Trigger(message),
) -> Element(message) {
  heading.element(attributes, [
    trigger.element(trigger.attributes, trigger.children),
  ])
}

/// The accordion trigger is the button that toggles the open state of an
/// accordion item. It must not contain any other interactive elements.
///
/// #### Attributes
///
/// [`label`](#label).
///
/// #### CSS states
///
/// - `:state(open)` is applied when the containing accordion item is expanded.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the accordion, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-controls`
/// - `aria-expanded`
/// - `role`
///
pub fn trigger(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Trigger(message) {
  Trigger(attributes:, children:)
}

/// The accordion panel contains the collapsible content for the containing
/// accordion item.
///
/// #### CSS states
///
/// - `:state(open)` is applied when the containing accordion item is expanded.
///
/// #### CSS variables
///
/// - `--accordion-panel-width`
/// - `--accordion-panel-height`
///
/// #### Accessibility notes
///
/// When the panel is collapsed, any content within is made [inert](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/inert).
/// This prevents focus from moving into the hidden content and ensures screen
/// readers and other assistive technologies do not announce it. Because of this,
/// it's important to make sure that the accordion panel is made _visually hidden_
/// when collapsed so that sighted users do not try to interact with the panel's
/// content.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the accordion, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-labelledby`
///
pub fn panel(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Panel(message) {
  Panel(attributes:, children:)
}

/// The optional accordion close trigger can be placed within the panel content
/// to provide an additional way to collapse the containing accordion item without
/// navigating back to the item header.
///
/// #### Attributes
///
/// [`label`](#label).
///
/// #### CSS states
///
/// - `:state(open)` is applied when the containing accordion item is expanded.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the accordion, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-controls`
/// - `aria-expanded`
/// - `role`
///
pub fn close(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  trigger.element(attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Provides an accessible label to an [accordion](#view) or an [item trigger](#trigger).
/// When used on an accordion, it is announced by assistive technologies to help
/// identify the accordion.
///
/// It should be used on an accordion item trigger if the trigger's content does
/// not contain that can be used to automatically generate an accessible label.
///
/// In both cases, the label is used for assistive technolgies only and is not
/// visible to sighted users.
///
pub fn label(value: String) -> Attribute(message) {
  root.label(value)
}

/// Controls whether keyboard navigation in an [accordion](#view) loops from the
/// last item back to the first and vice versa.
///
pub fn loop(value: Bool) -> Attribute(message) {
  root.loop(value)
}

/// Set an [accordion's](#view) orientation to horizontal. This changes keyboard
/// navigation to use Arrow Left and Right keys instead of Up and Down.
///
pub fn horizontal() -> Attribute(message) {
  root.orientation("horizontal")
}

/// Set an [accordion's](#view) orientation to vertical. This is the default
/// behaviour for an accordion and uses Arrow Up and Down keys for keyboard
/// navigation.
///
pub fn vertical() -> Attribute(message) {
  root.orientation("vertical")
}

/// Set the default open items for an _uncontrolled_ accordion. This is a list
/// of item names that should be open when the accordion first renders.
///
/// > **Note**: an uncontrolled component is responsible for managing its own state
/// > and subsequent changes to the `default_value` will not be reflected in the
/// > component after the initial render.
/// >
/// > To control the accordion's state from your application, use the [`value`](#value)
/// > attribute instead.
///
pub fn default_value(open: List(String)) -> Attribute(message) {
  root.default_value(open)
}

/// Set the current open items for a _controlled_ accordion.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_value_change`](#on_value_change) or [`on_open_change`](#on_open_change)
/// > events.
/// >
/// > To let the component manage its own state, use the [`default_value`](#default_value)
/// > attribute to set the initial open items instead.
///
pub fn value(open: List(String)) -> Attribute(message) {
  root.value(open)
}

/// Set the open state of an individual [accordion item](#item), making it
/// controlled by your application and overriding any state managed by the
/// containing accordion.
///
/// Where possible, it is preferable to manage the open state of accordion items
/// centrally using the [`value`](#value) attribute on the containing accordion,
/// but this attribute can be useful when you need to pin certain items open or
/// closed regardless of user interaction.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_open_change`](#on_open_change) event.
/// >
/// > To set whether an accordion item is initially open when first rendered,
/// > consider using the [`default_open`](#default_open) attribute instead.
///
pub fn open(value: Bool) -> Attribute(message) {
  item.open(value)
}

/// Set whether an individual [accordion item](#item) is open by default when
/// first rendered in an _uncontrolled_ accordion. This value is only taken into
/// account if the containing accordion does not have its own [`default_value`](#default_value)
/// attribute.
///
pub fn default_open(value: Bool) -> Attribute(message) {
  item.default_open(value)
}

/// Constrain an accordion to only allow a single item to be open at a time.
///
pub fn single() -> Attribute(message) {
  root.type_("single")
}

/// Allow multiple accordion items to be open at the same time.
///
pub fn multiple() -> Attribute(message) {
  root.type_("multiple")
}

/// Set the heading level for an accordion item's [heading](#heading). This sets
/// the `aria-level` attribute on the heading element to help assistive technologies
/// understand the structure of the page. The value is clamped between 1 and 9.
///
pub fn level(value: Int) -> Attribute(message) {
  attribute.aria_level(int.clamp(value, 1, 9))
}

// EVENTS ----------------------------------------------------------------------

/// An event emitted by an [accordion](#view) when the open state of any of its
/// items changes. The handler is passed a list of the names of all currently
/// open items.
///
/// In a controlled accordion, this event should be used to update your application
/// state with the new open items. Your application may ignore this event to
/// prevent the open state of the accordion from changing.
///
/// In an uncontrolled accordion, this event can be used to respond to changes
/// in the accordion's open state, for example by load ingcontent dynamically when
/// an item is opened.
///
pub fn on_value_change(
  handler: fn(List(String)) -> message,
) -> Attribute(message) {
  root.on_value_change(handler)
}

/// An event emitted by an individual [accordion item](#item) when its open state
/// changes. The handler is passed the name of the item and its new open state.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_open_change(
  handler: fn(String, Bool) -> message,
) -> Attribute(message) {
  item.on_change(handler)
}

/// An event emitted by an individual [accordion item](#item) when it is expanded.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_show(handler: fn(String) -> message) -> Attribute(message) {
  item.on_show(handler)
}

/// An event emitted by an individual [accordion item](#item) when it is collapsed.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_hide(handler: fn(String) -> message) -> Attribute(message) {
  item.on_hide(handler)
}
