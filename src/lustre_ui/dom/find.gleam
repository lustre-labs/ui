// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/result
import gleam/string
import lustre_ui/dom/element.{type HtmlElement}

// TYPES -----------------------------------------------------------------------

pub type Filter {
  Accept
  Skip
  Reject
}

// CONSTANTS -------------------------------------------------------------------

const not_inert = ":not([inert]):not([inert] *)"

const not_neg_tabindex = ":not([tabindex^=\"-\"])"

const not_disabled = ":not(:disabled)"

const tabbable = [
  "a[href]"
    <> not_inert
    <> not_neg_tabindex,
  "area[href]"
    <> not_inert
    <> not_neg_tabindex,
  "input:not([type=\"hidden\"]):not([type=\"radio\"])"
    <> not_inert
    <> not_neg_tabindex
    <> not_disabled,
  "input[type=\"radio\"]"
    <> not_inert
    <> not_neg_tabindex
    <> not_disabled,
  "select"
    <> not_inert
    <> not_neg_tabindex
    <> not_disabled,
  "textarea"
    <> not_inert
    <> not_neg_tabindex
    <> not_disabled,
  "button"
    <> not_inert
    <> not_neg_tabindex
    <> not_disabled,
  "details"
    <> not_inert
    <> " > summary:first-of-type"
    <> not_neg_tabindex,
  "details:not(:has(> summary))"
    <> not_inert
    <> not_neg_tabindex,
  "iframe"
    <> not_inert
    <> not_neg_tabindex,
  "audio[controls]"
    <> not_inert
    <> not_neg_tabindex,
  "video[controls]"
    <> not_inert
    <> not_neg_tabindex,
  "[contenteditable]"
    <> not_inert
    <> not_neg_tabindex,
  "[tabindex]"
    <> not_inert
    <> not_neg_tabindex,
]

// QUERIES ---------------------------------------------------------------------

///
///
pub fn is_tabbable(element: HtmlElement) -> Bool {
  element.matches(element, string.join(tabbable, ", "))
}

///
///
@external(javascript, "./find.ffi.mjs", "findFirstDescendant")
pub fn first_descendant(
  of root: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil)

///
///
pub fn previous_descendant(
  of root: HtmlElement,
  before target: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  wrap wrap: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil) {
  let previous =
    do_previous_descendant(
      of: root,
      before: target,
      pierce: pierce_shadow_roots,
      matching: filter,
    )

  use <- bool.guard(!wrap, previous)
  use <- result.lazy_or(previous)

  last_descendant(of: root, pierce: pierce_shadow_roots, matching: filter)
}

@external(javascript, "./find.ffi.mjs", "findPreviousDescendant")
fn do_previous_descendant(
  of root: HtmlElement,
  before target: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil)

pub fn next_descendant(
  of root: HtmlElement,
  after target: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  wrap wrap: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil) {
  let next =
    do_next_descendant(
      of: root,
      after: target,
      pierce: pierce_shadow_roots,
      matching: filter,
    )

  use <- bool.guard(!wrap, next)
  use <- result.lazy_or(next)

  first_descendant(of: root, pierce: pierce_shadow_roots, matching: filter)
}

///
///
@external(javascript, "./find.ffi.mjs", "findNextDescendant")
fn do_next_descendant(
  of root: HtmlElement,
  after target: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil)

///
///
@external(javascript, "./find.ffi.mjs", "findLastDescendant")
pub fn last_descendant(
  of root: HtmlElement,
  pierce pierce_shadow_roots: Bool,
  matching filter: fn(HtmlElement) -> Filter,
) -> Result(HtmlElement, Nil)
