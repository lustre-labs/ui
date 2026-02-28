//// <script>
//// const docs = [
////   {
////     header: "Elements",
////     functions: [
////       "register",
////       "view",
////       "list",
////       "trigger",
////       "indicator",
////       "content",
////       "panel",
////     ]
////   },
////   {
////     header: "Attributes",
////     sort: true,
////     functions: [
////       "value",
////       "default_value",
////       "horizontal",
////       "vertical",
////       "automatic_activation",
////       "loop",
////     ]
////   },
////   {
////     header: "Events",
////     sort: true,
////     functions: [
////       "on_value_change",
////       "on_select",
////       "on_open",
////       "on_close",
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
//// Tabs are made up of one or more panels of content each with an associated
//// trigger. Only one panel is visible at a time, and can be changed by selecting
//// the associated trigger.
////
//// ```gleam
//// tabs.view([], [
////   tabs.list([], [
////     tabs.trigger("wibble", [], [html.text("...")]),
////     tabs.trigger("wobble", [], [html.text("...")]),
////     tabs.indicator([], []),
////   ]),
////   tabs.content([], [
////     tabs.panel("wibble", [], [html.text("...")]),
////     tabs.panel("wobble", [], [html.text("...")]),
////   ]),
//// ])
//// ```
////
//// - [`tabs.view`](#view) is the root container for the tab triggers and
////   panels. It controls the current active tab.
////
//// - The [`tabs.list`](#list) is a container for one or more tab triggers. It
////   manages keyboard interaction and focus between the triggers.
////
//// - Each [`tabs.trigger`](#trigger) is a button that activates its associated
////   panel. It must not contain any other interactive children.
////
//// - The [`tabs.indicator`](#indicator) can be styled to match the position of
////   the currently active tab. It is typically animated for smooth transitions.
////
//// - [`tabs.content`](#content) is a container for one or more tab panels.
////
//// - Each [`tabs.panel`](#panel) is a container for content that corresponds to
////   one trigger. When the associated trigger is active, that panel's content
////   will be visible.
////
//// ## Accessibility
////
//// The tabs component follows the WAI-ARIA Authoring Practices for the
//// [tabs pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/). This means
//// appropriate roles, ARIA attributes, and keyboard interactions are handled for
//// you, including:
////
//// - `role` "tablist" on the tabs list container with managed `aria-orientation`
////   for horizontal or vertical layouts.
////
//// - `role` "tab" on each tab trigger, with managed `aria-selected`, `aria-controls`,
////   and `tabindex` attributes.
////
//// - `role` "tabpanel" on each tab panel, with managed `aria-labelledby` and
////   content visibility.
////
//// - `role` "presentation" on the tabs indicator.
////
//// - Keyboard interactions for navigating between tab triggers using Arrow Up/Down,
////   Arrow Left/Right, Home, and End keys, as well as the ability to activate
////   tabs when focus moves (automatic activation) or when a tab is selected with
////   Enter or Space (manual activation).
////
//// - Retention of focus when the active panel changes.
////
//// ## Recipes
////
//// You can use these recipes as starting points for common tabs configurations.
//// Copy and paste them into your apps and adapt them as needed!
////
//// ### Basic use
////
//// The basic scaffold for using the tabs component. In this default configuration,
//// the state of the active tab is uncontrolled and managed internally by the
//// component.
////
//// ```gleam
//// tabs.view([], [
////   tabs.list([], [
////     tabs.trigger("wibble", [], [todo]),
////     tabs.trigger("wobble", [], [todo]),
////   ]),
////   tabs.content([], [
////     tabs.panel("wibble", [], [todo]),
////     tabs.panel("wobble", [], [todo]),
////   ]),
//// ])
//// ```
////

// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/set
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/element.{type Element}
import lustre/element/keyed
import lustre/ui/tabs/content
import lustre/ui/tabs/context.{Horizontal, Vertical}
import lustre/ui/tabs/indicator
import lustre/ui/tabs/list as tabslist
import lustre/ui/tabs/panel
import lustre/ui/tabs/root
import lustre/ui/tabs/trigger

// TYPES -----------------------------------------------------------------------

pub opaque type TabsList(message) {
  List(
    attributes: List(Attribute(message)),
    children: List(TabsListItem(message)),
  )
}

pub opaque type TabsListItem(message) {
  Trigger(
    name: String,
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )

  Indicator(
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

pub opaque type TabsContent(message) {
  Content(
    attributes: List(Attribute(message)),
    children: List(TabsPanel(message)),
  )
}

pub opaque type TabsPanel(message) {
  Panel(
    name: String,
    attributes: List(Attribute(message)),
    children: List(Element(message)),
  )
}

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

/// Register the tabs component and its parts. This must be called before using
/// the component in your application, but you may prefer to call [`ui.register`](../ui.html#register)
/// instead, which registers all lustre/ui components at once. Typically this is
/// called just before starting your Lustre application.
///
/// The following custom elements will be registered:
///
/// - `<lustre-tabs>`
/// - `<lustre-tabs-list>`
/// - `<lustre-tabs-trigger>`
/// - `<lustre-tabs-indicator>`
/// - `<lustre-tabs-content>`
/// - `<lustre-tabs-panel>`
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(root.register())
  use _ <- result.try(tabslist.register())
  use _ <- result.try(trigger.register())
  use _ <- result.try(indicator.register())
  use _ <- result.try(content.register())
  use _ <- result.try(panel.register())

  Ok(Nil)
}

/// The root tabs element is a container for both the list of triggers and the
/// main tabs content.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs>
/// ```
///
/// #### Attributes
///
/// [`automatic_activation`](#automatic_activation), [`default_value`](#default_value),
/// [`horizontal`](#horizontal), [`loop`](#loop, [`value`](#value),
/// [`vertical`](#vertical).
///
/// #### Events
///
/// [`on_value_change`](#on_value_change), [`on_select`](#on_select),
/// [`on_open`](#on_open), [`on_close`](#on_close).
///
/// #### Styling
///
/// This element has a default display of `block`.
///
pub fn view(
  attributes attributes: List(Attribute(message)),
  list list: TabsList(message),
  content content: TabsContent(message),
) -> Element(message) {
  let #(triggers, seen, _) =
    list.fold_right(list.children, #([], set.new(), 0), fn(acc, item) {
      case item {
        Trigger(name:, attributes:, children:) -> {
          // Triggers with no name are invalid and ignored.
          use <- bool.guard(name == "", acc)
          // Duplicate trigger names are ignored.
          use <- bool.guard(set.contains(acc.1, name), acc)
          let html =
            trigger.element([trigger.name(name), ..attributes], children)

          #([#(name, html), ..acc.0], set.insert(acc.1, name), acc.2)
        }

        Indicator(attributes:, children:) -> {
          let key = "indicator-" <> int.to_string(acc.2)
          let html = indicator.element(attributes, children)

          #([#(key, html), ..acc.0], acc.1, acc.2 + 1)
        }
      }
    })

  let #(panels, _) =
    list.fold_right(content.children, #([], seen), fn(acc, panel) {
      // Panels with no name are invalid and ignored.
      use <- bool.guard(panel.name == "", acc)
      // Duplicate panel names or panel names without an associated trigger are
      // ignored.
      use <- bool.guard(!set.contains(acc.1, panel.name), acc)
      let html =
        panel.element(
          [component.slot(panel.name), ..panel.attributes],
          panel.children,
        )

      #([#(panel.name, html), ..acc.0], set.delete(acc.1, panel.name))
    })

  root.element(attributes, [
    keyed.element(tabslist.tag, list.attributes, triggers),
    keyed.element(content.tag, content.attributes, panels),
  ])
}

/// The tabs list is a container for one or more tab triggers. It manages keyboard
/// interaction and focus between the triggers.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs-list>
/// ```
///
/// #### Attributes
///
/// [`automatic_activation`](#automatic_activation), [`horizontal`](#horizontal),
/// [`loop`](#loop), [`vertical`](#vertical).
///
/// On attributes that are valid for both this element and the [root tabs](#view)
/// element, attributes set directly on this element will take precedence.
///
/// #### Events
///
/// [`on_select`](#on_select).
///
/// #### Styling
///
/// This element has a default display of `block`.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-orientation`
/// - `role`
///
pub fn list(
  attributes: List(Attribute(message)),
  children: List(TabsListItem(message)),
) -> TabsList(message) {
  List(attributes:, children:)
}

/// A tabs trigger is a button that activates its associated panel. It must not
/// contain any other interactive children.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs-trigger>
/// ```
///
/// #### Events
///
/// > **Note**: only the parent [tabs list](#list) will emit the [`on_select`](#on_select)
/// > event. To listen for activation of an individual trigger, you can listen for
/// > standard events like `click` or `keydown`.
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(active)` is applied when the active tab matches this trigger's name.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-controls`
/// - `aria-selected`
/// - `role`
/// - `tabindex`
///
pub fn trigger(
  name name: String,
  attributes attributes: List(Attribute(message)),
  children children: List(Element(message)),
) -> TabsListItem(message) {
  Trigger(name:, attributes:, children:)
}

/// A visual indicator that can be styled to match the size and position of the
/// currently active tab.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs-indicator>
/// ```
///
/// #### Styling
///
/// This element has a default display of `inline`.
///
/// The following CSS custom properties can be used to style this element or
/// its children:
///
/// - `--indicator-x`
/// - `--indicator-y`
/// - `--indicator-width`
/// - `--indicator-height`
///
/// #### Accessibility notes
///
/// The indicator should only be used as a visual aid for sighted users. It should
/// not contain any meaningful content or interactive elements as it will be
/// ignored by assistive technologies and unavigable via keyboard.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `role`
///
pub fn indicator(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> TabsListItem(message) {
  Indicator(attributes:, children:)
}

/// The content element contains one or more [panels](#panels) and manages which
/// is visible based on the currently active tab.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs-content>
/// ```
///
/// #### Events
///
/// [`on_open`](#on_open), [`on_close`](#on_close).
///
/// #### Styling
///
/// This element has a default display of `block`.
///
pub fn content(
  attributes: List(Attribute(message)),
  children: List(TabsPanel(message)),
) -> TabsContent(message) {
  Content(attributes:, children:)
}

/// A panel is a container for content that corresponds to one trigger. When the
/// associated trigger is active, that panel's content will be visible.
///
/// Each panel inside the [`tabs.content`](#content) container must have a unique
/// name that matches one of the triggers inside the [`tabs.list`](#list) container.
/// Duplicate names, names without an associated trigger, or empty names will be
/// ignored.
///
/// #### Tag
///
/// ```html
/// <lustre-tabs-panel>
/// ```
///
/// #### Events
///
/// [`on_open`](#on_open), [`on_close`](#on_close).
///
/// #### Styling
///
/// This element has a default display of `block`.
///
/// The following CSS custom states can be used to style this element:
///
/// - `:state(active)` is applied when the panel is active and visible.
///
/// #### Accessibility notes
///
/// When a panel is active it is automatically assigned a tabindex of `0` if it
/// has no interactive children. This is important to make sure the panel itself
/// is included in the tab sequence of the page.
///
/// If a panel does not have an explicit `id` attribute set, it will be assigned
/// one automatically. This is necessary to establish the `aria-controls` relationship
/// on the trigger.
///
/// #### Managed attributes
///
/// The following attributes **must not** be set manually on the element, as
/// these are managed by the component and are necessary for accessibility:
///
/// - `aria-labelledby`
/// - `role`
/// - `tabindex`
///
pub fn panel(
  name name: String,
  attributes attributes: List(Attribute(message)),
  children children: List(Element(message)),
) -> TabsPanel(message) {
  Panel(name:, attributes:, children:)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Set the current active tab for _controlled_ tabs.
///
/// > **Note**: in a controlled component, the state is managed by your application
/// > and must be updated in response to user interaction by handling the
/// > [`on_value_change`](#on_value_change) or [`on_select`](#on_select) events.
/// >
/// > To let the component manage its own state, use the [`default_value`](#default_value)
/// > attribute to set the initial active tab instead.
///
pub fn value(name: String) -> Attribute(message) {
  root.value(name)
}

/// Set the default active tab for _uncontrolled_ tabs. This should correspond to
/// the name of one of the [tab triggers](#trigger) present in the [tabs list](#list).
///
/// > **Note**: an uncontrolled component is responsible for managing its own state
/// > and subsequent changes to the `default_value` will not be reflected in the
/// > component after the initial render.
/// >
/// > To control the tabs component's state from your application, use the [`value`](#value)
/// > attribute instead.
///
pub fn default_value(name: String) -> Attribute(message) {
  root.default_value(name)
}

/// Set a [tabs list's](#list) orientation to horizontal. This changes how keyboard
/// navigation between tab triggers works, using Left/Right arrow keys instead of
/// Up/Down arrow keys. This is the default orientation for tabs lists.
///
pub fn horizontal() -> Attribute(message) {
  tabslist.orientation(Horizontal)
}

/// Set a [tabs list's](#list) orientation to vertical. This changes how keyboard
/// navigation between tab triggers works, using Up/Down arrow keys instead of
/// Left/Right arrow keys.
///
pub fn vertical() -> Attribute(message) {
  tabslist.orientation(Vertical)
}

/// It is possible to configure how tabs are activated when using the keyboard
/// to navigate between tab triggers. By default, tabs use automatic activation,
/// meaning that when a tab trigger receives focus, it is automatically activated.
///
/// This behaviour can be disabled by setting this attribute to `False`. Manual
/// activation requires the user to press Enter or Space (or use a pointer device
/// to click) to activate the focused tab trigger.
///
/// > **Note**: it is important to consider the accessibility implications of
/// > enabling or disabling automatic activation. The Web Accessibility Initiative
/// > (WAI) have [some guidelines](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/#kbd_selection_follows_focus)
/// > on which option to prefer and when.
///
pub fn automatic_activation(enabled: Bool) -> Attribute(message) {
  tabslist.mode(case enabled {
    True -> tabslist.Automatic
    False -> tabslist.Manual
  })
}

/// Controls whether keyboard navigation in a [tabs list](#list) loops from the
/// last tab back to the first and vice versa.
///
pub fn loop(enabled: Bool) -> Attribute(message) {
  tabslist.loop(enabled)
}

// EVENTS ----------------------------------------------------------------------

/// An event emitted by the root [tabs](#view) element when the active tab changes.
/// This will only be emitted when the active tab actually changes, not when the
/// same tab is re-selected.
///
/// In a controlled tabs, this event should be used to update your application
/// state with the new active tab. Your application may ignore this event to
/// prevent the open state of the tabs from changing.
///
/// In an uncontrolled tabs, this event can be used to respond to changes
/// in the tabs' open state, for example by loading content dynamically when
/// a trigger is activated.
///
pub fn on_value_change(handler: fn(String) -> message) -> Attribute(message) {
  root.on_value_change(handler)
}

/// An event emitted by the [tabs list](#list) when a tab trigger is activated.
/// This does not account for the current active tab, so multiple select events
/// may be emitted without the active tab changing.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_select(handler: fn(String) -> message) -> Attribute(message) {
  tabslist.on_select(handler)
}

/// An event emitted by an individual [panel](#panel) when it is first made
/// visible.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_open(handler: fn(String) -> message) -> Attribute(message) {
  panel.on_open(handler)
}

/// An event emitted by an individual [panel](#panel) when it is hidden.
///
/// > **Note**: like other DOM events, this event bubbles and can be listened for
/// > on the containing accordion.
///
pub fn on_close(handler: fn(String) -> message) -> Attribute(message) {
  panel.on_close(handler)
}
