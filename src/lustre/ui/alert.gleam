//// The [`alert`](#alert) element, sometimes called a "callout", is used to direct
//// the user's attention away from the main content on the page and to some important
//// information or context.
////
//// Common uses for the `alert` element include:
////
//// - Toasts that render unobtrusely over the main content, often in the corner
////   of the page.
////
//// - Callouts in documentation to provide additional or crucial information.
////
//// ## Anatomy
////
//// <image src="/assets/diagram-alert.svg" alt="" width="100%">
////
//// An alert is made up of different parts:
////
//// - The main [`alert`](#alert) container used to control the alert's styles
////   and layout. (**required**)
////
//// - An [`indicator`](#indicator) used to provide users with a visual clue about
////   an alert's content. (_optional_)
////
//// - A [`title`](#title) used to summarise the alert's content or message in a
////  few words. (_optional_)
////
//// - A [`content`](#content) container for any additional content or information
////   to provide to the user. (_optional_)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `alert` element.
////
//// ### A title-only success alert:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/alert.{alert}
////
//// pub fn new_todo_added() {
////   alert([alert.success()], [
////     alert.title([], [html.text("New todo added to your list.")])
////   ])
//// }
//// ```
////
//// ### An error alert with indicator and content:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/alert.{alert}
////
//// pub fn delete_todo_failed() {
////   alert([alert.danger()], [
////     alert.indicator([], [icon.exclamation_triangle([])]),
////     alert.title([], [html.text("Could not delete todo")]),
////     alert.content([], [
////       html.p([], [html.text("Check your internet connection and try again.")])
////     ])
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// It is possible to control some aspects of an alert's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `alert` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--background`](#background)
//// - [`--border`](#border)
//// - [`--indicator-size`](#indicator_size)
//// - [`--padding-x`](#padding_x)
//// - [`--padding-y`](#padding_y)
//// - [`--radius`](#radius)
//// - [`--text`](#text)
//// - [`--title-margin`](#title_margin)
//// - [`--title-weight`](#title_weight)
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

// ELEMENTS --------------------------------------------------------------------

/// The `alert` element, sometimes called a "callout", is used to direct the
/// user's attention away from the main content on the page and to some important
/// information or context.
///
/// Common uses for the `alert` element include:
///
/// - Toasts that render unobtrusely over the main content, often in the corner
///   of the page.
///
/// - Callouts in documentation to provide additional or crucial information.
///
/// The colour or type of the alert can be changed by using one of the following
/// attributes: [`primary`](#primary), [`secondary`](#secondary), [`warning`](#warning),
/// [`danger`](#danger), or [`successs`](#success).
///
/// This will render an `<article>` tag in your markup. If you would like to
/// render a different element, use [`of`](#of) instead.
///
/// <!-- @element -->
///
pub fn alert(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  of(html.aside, attributes, children)
}

/// Render the given `element` function as an [`alert`](#alert). This applies
/// the `"alert"` role to the element, and gives it the class `"lustre-ui-alert`".
///
/// <!-- @element -->
///
pub fn of(
  element: fn(List(Attribute(msg)), List(Element(msg))) -> Element(msg),
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(
    [attribute.role("alert"), attribute.class("lustre-ui-alert"), ..attributes],
    children,
  )
}

/// An indicator that appears in the top-left of an alert. Indicators have a fixed
/// size that can be controlled by setting the [`indicator_size`](#indicator_size)
/// value.
///
/// Indicators are typically icons or other visual cues.
///
/// <!-- @element -->
///
pub fn indicator(icon: Element(msg)) -> Element(msg) {
  html.span([attribute.class("indicator")], [icon])
}

/// The `title` element is a concise summary of the alert's content or message.
/// The title's content is rendered with a medium font weight to distinguish it
/// from any additional content, but this can be overriden by setting the
/// [`title_weight`](#title_weight) value.
///
/// **Note**: A title's content _must_ fit on one line; any overflow is clipped
/// and ellipses are shown.
///
/// <!-- @element -->
///
pub fn title(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.header([attribute.class("title"), ..attributes], children)
}

///
///
/// <!-- @element -->
///
pub fn content(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.section([attribute.class("content"), ..attributes], children)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Adjust the alert's colour to match your theme's primary colour palette. The
/// primary palette is typically used for alerts that provide additional information
/// or context to an action.
///
/// <!-- @attribute -->
///
pub fn primary() -> Attribute(msg) {
  attribute.class("primary")
}

/// Adjust the alert's colour to match your theme's secondary colour palette. The
/// secondary palette is typically used for alerts that provide additional information
/// or context to an action.
///
/// <!-- @attribute -->
///
pub fn secondary() -> Attribute(msg) {
  attribute.class("secondary")
}

/// Adjust the alert's colour to match your theme's warning colour palette. The
/// warning palette is typically used to draw the user's attention to additional
/// information before they perform an action or to alert the user of a non-fatal
/// error.
///
/// <!-- @attribute -->
///
pub fn warning() -> Attribute(msg) {
  attribute.class("warning")
}

/// Adjust the alert's colour to match your theme's danger colour palette. The
/// danger palette is typically used to highlight critical information before a
/// user performs an action or to alert the user of an important error.
///
/// <!-- @attribute -->
///
pub fn danger() -> Attribute(msg) {
  attribute.class("danger")
}

/// Adjust the alert's colour to match your theme's success colour palette. The
/// success palette is typically used to inform the user that an action was
/// successfully completed.
///
/// <!-- @attribute -->
///
pub fn success() -> Attribute(msg) {
  attribute.class("success")
}

/// Remove the alert's border radius, regardless of your theme's configuration.
///
/// <!-- @attribute -->
///
pub fn square() -> Attribute(msg) {
  radius("0")
}

/// Set the alert's border radius to your theme's `md` radius value. This is
/// shorthand for `radius(theme.radius.md)`.
///
/// <!-- @attribute -->
///
pub fn round() -> Attribute(msg) {
  radius(theme.radius.md)
}

/// Set the alert's border radius to your theme's `xl` radius value. This is
/// shorthand for `radius(theme.radius.xl)`.
///
/// <!-- @attribute -->
///
pub fn pill() -> Attribute(msg) {
  radius(theme.radius.xl)
}

// CSS VARIABLES ---------------------------------------------------------------

/// By default, the `alert` element uses an appropriate background colour based
/// on your theme configuration and chosen colour palette. You can use this
/// function in conjunction with the other attributes in this module to manually
/// override this colour.
///
/// This can be any CSS value that can be used in place of a colour, for example:
///
/// - `background("red")`
/// - `background("#ffaff3")`
/// - `background("var(--lustre-ui-primary-solid)")`
///
/// <!-- @css-variable -->
///
pub fn background(value: String) -> Attribute(msg) {
  attribute.style([#("--background", value)])
}

/// By default, the `alert` element uses an appropriate border colour based on
/// your theme configuration and chosen colour palette. You can use this function
/// in conjunction with the other attributes in this module to manually override
/// this colour.
///
/// This can be any CSS value that can be used in place of a colour, for example:
///
/// - `border(blue)`
/// - `border(#ffaff3)`
/// - `border("var(--lustre-ui-accent-strong)")
///
/// <!-- @css-variable -->
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

/// By default, the `alert` element sets the size of the [`indicator`](#indicator)
/// to `16px`. You can use this function in conjunction with the other attributes
/// in this module to manually override this size.
///
/// This can be any CSS value that can be used in place of a size, for example:
///
/// - `indicator_size("12px")`
/// - `indicator_size("2rem")`
/// - `indicator_size("var(--lustre-ui-size-lg)")
///
/// **Note**: indicators are _always_ square.
///
/// <!-- @css-variable -->
///
pub fn indicator_size(value: String) -> Attribute(msg) {
  attribute.style([#("--indicator-size", value)])
}

/// By default, the `alert` element sets appropriate horizontal and vertical
/// padding based on your theme configuration. You can use this function in
/// conjunction with the other attributes in this module to manually override this
/// padding.
///
/// This can be any CSS value that can be used in place of a size, for example:
///
/// - `padding("16px", "12px")`
/// - `padding("1rem", "1rem")`
/// - `padding("var(--lustre-ui-space-md)", "var(--lustre-ui-space-sm)")`
///
/// This function is a shorthand for setting both [`padding_x`](#padding_x) and
/// [`padding_y`](#padding_y).
///
/// <!-- @css-variable -->
///
pub fn padding(x x: String, y y: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", x), #("--padding-y", y)])
}

/// <!-- @css-variable -->
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

/// <!-- @css-variable -->
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-y", value)])
}

/// <!-- @css-variable -->
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style([#("--radius", value)])
}

/// <!-- @css-variable -->
///
pub fn text(value: String) -> Attribute(msg) {
  attribute.style([#("--text", value)])
}

/// <!-- @css-variable -->
///
pub fn title_margin(value: String) -> Attribute(msg) {
  attribute.style([#("--title-margin", value)])
}

/// <!-- @css-variable -->
///
pub fn title_weight(value: String) -> Attribute(msg) {
  attribute.style([#("--title-weight", value)])
}
