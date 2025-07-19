// IMPORTS ---------------------------------------------------------------------

import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/breadcrumb
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Breadcrumb", [
    basic_breadcrumb_story(),
    breadcrumb_with_collapsed_items_story(),
  ])
}

fn basic_breadcrumb_story() {
  use <- fable.story("Basic Breadcrumb Navigation")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  breadcrumb.element([], [
    breadcrumb.item([], [html.a([attribute.href("/")], [html.text("Home")])]),
    breadcrumb.chevron([]),
    breadcrumb.item([], [
      html.a([attribute.href("/documents")], [html.text("Documents")]),
    ]),
    breadcrumb.chevron([]),
    breadcrumb.current([], [html.text("My Document")]),
  ])
}

fn breadcrumb_with_collapsed_items_story() {
  use <- fable.story("Breadcrumb with Collapsed Items")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  breadcrumb.element([], [
    breadcrumb.item([], [html.a([attribute.href("/")], [html.text("Home")])]),
    breadcrumb.slash([]),
    breadcrumb.ellipsis([], "Collapsed navigation items"),
    breadcrumb.slash([]),
    breadcrumb.current([], [html.text("My Document")]),
  ])
}
