//// The [`button`](#button) element is a clickable control that receives keyboard
//// and pointer events that you would use to dispatch messages to your `update`
//// function when interacted with.
////
//// Common uses for buttons include:
////
//// - Submitting forms or triggering the submission of data.
////
//// - As navigation elements when using the stylised [`link`](#link) variant.
////
//// - Opening and closing dialogs, menus, and other interactive components.
////
//// ## Anatomy
////
//// <image src="/assets/diagram-button.svg" alt="" width="100%">
////
//// A button is made up of different parts:
////
//// - The main [`button`](#button) container used to control the button's styles
////   and layout. (**required**)
////
//// - One or more items of content like text or icons that provide visual and
////   semantic information about the button's purpose. (**required**)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `button` element.
////
//// ### A basic button with an icon and text:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/event
//// import lustre/ui/button.{button}
//// import lustre/ui/icon
////
//// pub fn save(handle_click) {
////   button([event.on_click(handle_click)], [
////     icon.save([]),
////     html.text("Save"),
////   ])
//// }
//// ```
////
//// ### A command palette button with a keyboard shortcut badge:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/event
//// import lustre/ui/button.{button}
////
//// pub fn command_palette(handle_click) {
////   button([button.solid(), event.on_click(handle_click)], [
////     html.text("Open"),
////     button.shortcut_badge([], ["⌘", "k"])
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// The style or look of a button can be controlled by using one of the following
//// attributes:
////
//// - [`clear`](#clear)
//// - [`outline`](#outline)
//// - [`soft`](#soft)
//// - [`solid`](#solid)
////
//// The size of a button can be controlled by using one of the following attributes:
////
//// - [`small`](#small)
//// - [`medium`](#medium)
//// - [`large`](#large)
//// - [`icon`](#icon)
////
//// The border radius of a button can be controlled while still using your theme's
//// configuration by using one of the following attributes:
////
//// - [`square`](#square)
//// - [`round`](#round)
//// - [`pill`](#pill)
////
//// It is possible to control some aspects of a button's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `button` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--background`](#background)
//// - [`--background-hover`](#background_hover)
//// - [`--border`](#border)
//// - [`--border-hover`](#border_hover)
//// - [`--border-width`](#border_width)
//// - [`--height`](#height)
//// - [`--min-height`](#min_height)
//// - [`--padding-x`](#padding_x)
//// - [`--radius`](#radius)
//// - [`--text`](#text)
////

// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/string
import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

/// The `button` element is a clickable control that receives keyboard and pointer
/// events that you would use to dispatch messages to your `update` function when
/// interacted with.
///
/// **Note**: in Safari, buttons aren't part of the tab order by default. To make
/// them focusable, buttons in Lustre UI have their `tabindex` attribute set to
/// `0` for consistent behaviour across browsers.
///
pub fn button(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.button, [attribute("tabindex", "0"), ..attributes], children)
}

/// Styles a HTML `<a>` element as a button. You should use this element when
/// you want to create a button that navigates to a different page or location.
///
pub fn link(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.a, attributes, children)
}

/// In the uncommon case that you need to render a button as a different HTML
/// element, you can use this function to supply the element you want to use.
/// This can be useful if you have an element that implements the _functionality_
/// of a button but and you to add Lustre UI's button styles to it.
///
/// **Note**: If you are styling a different element as a button, it's **crucial**
/// to ensure that the element is accessible and behaves correctly. In _most_ cases,
/// this means setting the `role` attribute to `"button"` and ensuring that the
/// element handles both click and keyboard events.
///
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(
    [
      attribute.class("lustre-ui-button"),
      attribute.role("button"),
      ..attributes
    ],
    children,
  )
}

// CHILDREN --------------------------------------------------------------------

/// Renders a small badge inside a button. Badges are used to display additional
/// information such as a [keyboard shortcut](#shortcut_badge) or a [count](#count)
/// of items.
///
pub fn badge(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.span([attribute.class("button-badge"), ..attributes], children)
}

/// Renders a small badge inside a button that represents a keyboard shortcut that
/// would trigger the button's action.
///
/// You can add a separator between keys by setting the `--separator` css variable:
///
/// ```gleam
/// import lustre/attribute
/// import lustre/ui/button
///
/// pub fn cmd_k_badge() {
///   let chord = ["⌘", "k"]
///   let styles = attribute.style([#("--separator", "'+'")])
///
///   button.shortcut_badge([styles], chord)
/// }
/// ```
///
pub fn shortcut_badge(
  attributes: List(Attribute(msg)),
  chord: List(String),
) -> Element(msg) {
  html.span(
    [
      attribute.class("button-badge"),
      attribute.title(string.join(chord, "+")),
      ..attributes
    ],
    list.map(chord, fn(key) {
      html.span([attribute.class("key")], [html.text(key)])
    }),
  )
}

/// Renders a small numerical count as a badge inside a button. This could be
/// used to represent the number of items in a list or the number of unread
/// notifications.
///
/// If the count is greater than 99, the badge will display `"99+"`.
///
pub fn count_badge(attributes: List(Attribute(msg)), count: Int) -> Element(msg) {
  html.span([attribute.class("button-badge"), ..attributes], [
    html.text(case count < 100 {
      True -> int.to_string(count)
      False -> "99+"
    }),
  ])
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn clear() -> Attribute(msg) {
  attribute.class("button-clear")
}

///
///
pub fn outline() -> Attribute(msg) {
  attribute.class("button-outline")
}

///
///
pub fn soft() -> Attribute(msg) {
  attribute.class("button-soft")
}

///
///
pub fn solid() -> Attribute(msg) {
  attribute.class("button-solid")
}

///
///
pub fn square() -> Attribute(msg) {
  radius("0")
}

///
///
pub fn round() -> Attribute(msg) {
  radius(theme.radius.md)
}

///
///
pub fn pill() -> Attribute(msg) {
  radius(theme.radius.xl)
}

///
///
pub fn icon() -> Attribute(msg) {
  attribute.class("button-icon")
}

///
///
pub fn small() -> Attribute(msg) {
  attribute.class("button-small")
}

///
///
pub fn medium() -> Attribute(msg) {
  attribute.class("button-medium")
}

///
///
pub fn large() -> Attribute(msg) {
  attribute.class("button-large")
}

// CSS VARIABLES ---------------------------------------------------------------

///
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

///
///
pub fn background_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--background-hover", value)])
}

///
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

///
///
pub fn border_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--border-hover", value)])
}

///
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

///
///
pub fn height(value: String) -> Attribute(msg) {
  attribute.style([#("--height", value)])
}

///
///
pub fn min_height(value: String) -> Attribute(msg) {
  attribute.style([#("--min-height", value)])
}

///
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

///
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style([#("--radius", value)])
}

///
///
pub fn text(value: String) -> Attribute(msg) {
  attribute.style([#("--text", value)])
}
