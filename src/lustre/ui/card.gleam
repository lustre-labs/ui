//// The [`card`](#element) element is used to create a small, self-contained
//// content container that groups related elements and information.
////
//// Common uses for the `card` element include:
////
//// - Displaying snippets of content or information that stand apart from surrounding
////   content but with a clear link between them, such as blog posts on a blog's
////   archive page or event details in a calendar view.
////
//// - Previews or summary information that can be clicked to navigate to more
////   detailed views.
////
//// - Containers for interactive elements that work as a cohesive unit like forms,
////   profile editors, or contact dialogs.
////
//// ## Anatomy
////
//// <image src="/assets/diagram-card.svg" alt="" width="100%">
////
//// A card is made up of different parts:
////
//// - The main [`element`](#element) container used to control the card's styles
////   and layout. (**required**)
////
//// - A [`header`](#header) element that may contain a title or other information
////   about the card's purpose or content. (_optional_)
////
//// - One or more pieces of [`content`](#content) displayed in the card's main body.
////   (_optional_)
////
//// - A [`footer`](#footer) that can contain supplementary content, metadata, or
////   actions related to the card's content. (_optional_)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `card` element.
////
//// ### A basic content card with header and content:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/card
////
//// pub fn recipe_preview(title: String, preview: String) {
////   card.element([], [
////     card.header([], [html.h2([], [html.text(title)])]),
////     card.content([], [html.p([], [html.text(preview)])])
////   ])
//// }
//// ```
////
//// ### A dialog-style card with footer actions:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/event
//// import lustre/ui/button
//// import lustre/ui/card
////
//// pub fn delete_dialog() {
////   card.element([], [
////     card.header([], [html.text("Delete recipe?")]),
////     card.content([], [
////       html.text("Are you sure that you want to delete this recipe?")
////     ]),
////     card.footer([], [
////       button.element([button.clear(), event.on_click(Cancel)], [html.text("Cancel")]),
////       button.element([button.solid(), button.danger(), event.on_click(Delete)], [
////         html.text("Delete"),
////       ])
////     ])
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// The border radius of a card can be controlled while still using your theme's
//// configuration by using one of the following attributes:
////
//// - [`square`](#square)
//// - [`round`](#round)
////
//// It is possible to control some aspects of a card's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `card` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--background`](#background)
//// - [`--border`](#border)
//// - [`--border-width`](#border_width)
//// - [`--padding-x`](#padding_x)
//// - [`--padding-y`](#padding_y)
//// - [`--radius`](#radius)
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.article, attributes, children)
}

pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-card"), ..attributes], children)
}

pub fn header(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.header([attribute.class("card-header"), ..attributes], children)
}

pub fn content(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.main([attribute.class("card-content"), ..attributes], children)
}

pub fn footer(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.footer([attribute.class("card-footer"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

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

// CSS VARIABLES ---------------------------------------------------------------

///
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style("--background", value)
}

///
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style("--border", value)
}

///
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style("--border-width", value)
}

///
///
pub fn padding(x: String, y: String) -> Attribute(msg) {
  attribute.styles([#("--padding-x", x), #("--padding-y", y)])
}

///
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style("--padding-x", value)
}

///
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style("--padding-y", value)
}

///
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style("--radius", value)
}
