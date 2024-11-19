//// The [`badge`] element, sometimes called a "tag", is commonly used to attach
//// a small piece of information to some other element. You might use a badge to
//// indicate the type of a product in a grid, or to annotate something as "new"
//// or "updated".
////
//// ## Anatomy
////
//// <image src="/assets/diagram-badge.svg" alt="" width="100%">
////
//// A badge is made up of only one part:
////
//// - The main [`badge`](#badge) container used to apply the badge styles. Often
////   the only direct child of the container is the text used for the badges
////   label, but it may also be an icon.
////
////   When empty, the [`badge`](#badge) container becomes a circle and can be
////   used as a statis indicator.
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `badge` element.
////
//// ### An online avator indicator
////
//// _This example uses Tailwind CSS for some additional styling._
////
//// ```gleam
//// import lustre/attribute
//// import lustre/element/html
//// import lustre/ui/badge.{badge}
////
//// pub fn online_avatar(src) {
////   html.div([attribute.class("inline-block relative")], [
////     html.img([attribute.class("size-6 rounded-full"), attribute.src(src)]),
////     badge([
////       badge.background("green"),
////       badge.solid(),
////       attribute.class("absolute top-0 right-0"),
////       attribute.title("online")],
////       []
////     )
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// It is possible to control many aspects of a badge's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `badge` element to match
//// elements outside of this package, or to apply custom colours outside of your
//// theme.
////
//// The following CSS variables can be set in your own stylesheets or by using
//// the corresponding attribute functions in this module:
////
//// [`--background`](#--background)
//// [`--background-hover`](#--background_hover)
//// [`--border`](#--border)
//// [`--border-hover`](#--border_hover)
//// [`--padding-x`](#--padding_x)
//// [`--padding-y`](#--padding_y)
//// [`--radius`](#--radius)
//// [`--text`](#--text)
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

/// The [`badge`] element, sometimes called a "tag", is commonly used to attach
/// a small piece of information to some other element. You might use a badge to
/// indicate the type of a product in a grid, or to annotate something as "new"
/// or "updated".
///
/// <!-- @element -->
///
pub fn badge(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.small, attributes, children)
}

/// Render the given `element` function as a [`badge`](#badge). The default badge
/// element is `html.small`; this function can be used to render an alternative
/// element like `html.button` or `html.a`.
///
/// <!-- @element -->
///
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element([attribute.class("lustre-ui-badge"), ..attributes], children)
}

// VARIANTS --------------------------------------------------------------------

/// Render a badge with just an online.
///
/// <!-- @attribute -->
///
pub fn outline() -> Attribute(msg) {
  attribute.class("badge-outline")
}

/// Render a badge with a softer background colour.
///
/// <!-- @attribute -->
///
pub fn soft() -> Attribute(msg) {
  attribute.class("badge-soft")
}

/// Render a badge with a bold solid background colour.
///
/// <!-- @attribute -->
///
pub fn solid() -> Attribute(msg) {
  attribute.class("badge-solid")
}

/// Remove the badge's border radius, regardless of your theme configuration. This
/// is shorthand for `radius("0")`.
///
/// <!-- @attribute -->
///
pub fn square() -> Attribute(msg) {
  radius("0")
}

/// Set the badges's border radius to your theme's `md` radius value. This is
/// shorthand for `radius(theme.radius.md)`.
///
/// <!-- @attribute -->
///
pub fn round() -> Attribute(msg) {
  radius(theme.radius.md)
}

/// Set the badges's border radius to your theme's `xl` radius value. This is
/// shorthand for `radius(theme.radius.xl)`.
///
/// <!-- @attribute -->
///
pub fn pill() -> Attribute(msg) {
  radius(theme.radius.xl)
}

// COLOURS ---------------------------------------------------------------------

/// Adjust the badge's colour to match your theme's primary colour palette.
///
/// <!-- @attribute -->
///
pub fn primary() -> Attribute(msg) {
  attribute.class("primary")
}

/// Adjust the badge's colour to match your theme's secondary colour palette.
///
/// <!-- @attribute -->
///
pub fn secondary() -> Attribute(msg) {
  attribute.class("secondary")
}

/// Adjust the badge's colour to match your theme's warning colour palette.
///
/// <!-- @attribute -->
///
pub fn warning() -> Attribute(msg) {
  attribute.class("warning")
}

/// Adjust the badge's colour to match your theme's danger colour palette.
///
/// <!-- @attribute -->
///
pub fn danger() -> Attribute(msg) {
  attribute.class("danger")
}

/// Adjust the badge's colour to match your theme's success colour palette.
///
/// <!-- @attribute -->
///
pub fn success() -> Attribute(msg) {
  attribute.class("success")
}

// CSS VARIABLES ---------------------------------------------------------------

///
///
/// <!-- @css-variable -->
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn background_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--background-hover", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn border_hover(value: String) -> Attribute(msg) {
  attribute.style([#("--border-hover", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn padding(x: String, y: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", x), #("--padding-y", y)])
}

///
///
/// <!-- @css-variable -->
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-y", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style([#("--radius", value)])
}

///
///
/// <!-- @css-variable -->
///
pub fn text(value: String) -> Attribute(msg) {
  attribute.style([#("--text", value)])
}
