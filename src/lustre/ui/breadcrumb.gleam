//// The [`breadcrumb`](#breadcrumb) element helps users understand their current
//// location in a hierarchical navigation structure and provides an easy way to
//// navigate back up to parent pages.
////
//// Common uses for breadcrumbs include:
////
//// - Showing the user's current location within a nested folder structure.
////
//// - Enabling quick navigation between different levels of a website's hierarchy.
////
////
//// ## Anatomy
////
//// <image src="/assets/diagram-breadcrumb.svg" alt="" width="100%">
////
//// A breadcrumb is made up of different parts:
////
//// - The main [`breadcrumb`](#breadcrumb) container used to organize the navigation
////   items. (**required**)
////
//// - One or more [`item`](#item) elements representing pages in the navigation
////   hierarchy. (**required**)
////
//// - A presentational [`separator`](#separator) element typically plased between
////   each navigation item. (_optional_)
////
//// - An [`ellipsis`](#ellipsis) element to indicate where multiple navigation
////   items have been collapsed. (_optional_)
////
//// - A [`current`](#current) element indicating the current page or the user's
////   current location in the hierarchy. (_optional_)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `breadcrumb` element.
////
//// ### Basic breadcrumb navigation:
////
//// ```gleam
//// import lustre/attribute
//// import lustre/element/html
//// import lustre/ui/breadcrumb.{breadcrumb}
////
//// pub fn nav() {
////   breadcrumb([], [
////     breadcrumb.item([], [
////       html.a([attribute.href("/")], [html.text("Home")]),
////     ]),
////     breadcrumb.chevron([]),
////     breadcrumb.item([], [
////       html.a([attribute.href("/documents")], [html.text("Documents")]),
////     ]),
////     breadcrumb.chevron([]),
////     breadcrumb.current([], [html.text("My Document")])
////   ])
//// }
//// ```
////
//// ### Breadcrumb with collapsed items:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/breadcrumb.{breadcrumb}
////
//// pub fn nav() {
////   breadcrumb([], [
////     breadcrumb.item([], [
////       html.a([attribute.href("/")], [html.text("Home")]),
////     ]),
////     breadcrumb.slash([]),
////     breadcrumb.ellipsis([], "Collapsed navigation items"),
////     breadcrumb.slash([]),
////     breadcrumb.current([], [html.text("My Document")])
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// It is possible to control some aspects of a breadcrumb's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `breadcrumb` element to match
//// elements outside of this package.
////
//// The following CSS variables can be set in your own stylesheets:
////
//// - (`--gap`)[#gap]
//// - (`--text`)[#text]:
//// - (`--text-hover`)[#text_hover]
////

// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/icon

// ELEMENTS --------------------------------------------------------------------

/// The `breadcrumb` element is used to contain an ordered sequence of navigation
/// items that helps a user understand their current location in a hierarchical
/// navigation structure.
///
/// The `breadcrumb` container creates a semantic `<nav>` element with its
/// children wrapped in an ordered list (`<ol>`).
///
/// <!-- @element -->
///
pub fn breadcrumb(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.nav([attribute("aria-label", "breadcrumb")], [
    html.ol([attribute.class("lustre-ui-breadcrumb"), ..attributes], children),
  ])
}

/// Represents a single item in a breadcrumb navigation structure. Typically
/// you would render an `<a>` element inside an `item` to create a clickable
/// link.
///
/// <!-- @element -->
///
pub fn item(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.li([attribute.class("breadcrumb-item"), ..attributes], children)
}

/// Represents the current page or the user's current location in the hierarchy.
/// This element should never be a link, and instead would typically include just
/// a text label or icon.
///
/// For correct accessibility and semantics, yhis element has the following ARIA
/// attributes:
///
/// - `role="link"`
/// - `aria-disabled="true"`
/// - `aria-current="page"`
///
/// <!-- @element -->
///
pub fn current(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.span(
    [
      attribute.class("breadcrumb-item breadcrumb-current"),
      attribute.role("link"),
      attribute("aria-disabled", "true"),
      attribute("aria-current", "page"),
      ..attributes
    ],
    children,
  )
}

/// The `separator` element is used to visually separate navigation items in a
/// breadcrumb. It is typically a small icon or character like a [`chevron`](#chevron)
/// or [`forward slash`](#slash) that helps users visualise the hierarchy.
///
/// For correct accessibility and semantics, this element has the following ARIA
/// attributes:
///
/// - `role="presentation"`
/// - `aria-hidden="true"`
///
/// <!-- @element -->
///
pub fn separator(
  attributes: List(Attribute(msg)),
  content: Element(msg),
) -> Element(msg) {
  html.li(
    [
      attribute.class("breadcrumb-separator"),
      attribute.role("presentation"),
      attribute("aria-hidden", "true"),
      ..attributes
    ],
    [content],
  )
}

/// A [`separator](#separator) that renders a chevron icon.
///
/// <!-- @element -->
///
pub fn chevron(attributes: List(Attribute(msg))) -> Element(msg) {
  separator(attributes, icon.chevron_right([]))
}

/// A [`separator](#separator) that renders a forward slash icon.
///
/// <!-- @element -->
///
pub fn slash(attributes: List(Attribute(msg))) -> Element(msg) {
  separator(attributes, icon.slash([]))
}

/// A [`separator](#separator) that renders a filled dot icon.
///
/// <!-- @element -->
///
pub fn dot(attributes: List(Attribute(msg))) -> Element(msg) {
  separator(attributes, icon.dot_filled([]))
}

/// The `ellipsis` element is used to indicate where multiple navigation items
/// have been collapsed to preserve space.
///
/// The single child of the `ellipsis` element is a text label that is read out
/// by screen readers to indicate that the items have been collapsed.
///
/// For correct accessibility and semantics, this element has the following ARIA
/// attributes:
///
/// - `role="presentation"`
///
/// <!-- @element -->
///
pub fn ellipsis(attributes: List(Attribute(msg)), label: String) -> Element(msg) {
  html.span(
    [
      attribute.class("breadcrumb-ellipsis"),
      attribute.role("presentation"),
      ..attributes
    ],
    [icon.dots_horizontal([]), html.span([], [html.text(label)])],
  )
}
