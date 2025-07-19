// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/element/html
import lustre/ui/accordion
import lustre/ui/alert
import lustre/ui/primitives/icon
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  let assert Ok(_) = accordion.register()

  fable.chapter("Alert", [
    title_only_success_alert_story(),
    title_indicator_content_error_alert_story(),
  ])
}

fn title_only_success_alert_story() {
  use <- fable.story("Title only, success")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  alert.element([alert.success()], [
    alert.title([], [html.text("New todo added to your list.")]),
  ])
}

fn title_indicator_content_error_alert_story() {
  use <- fable.story("Title + indicator + content, error")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  alert.element([alert.danger()], [
    alert.indicator(icon.exclamation_triangle([])),
    alert.title([], [html.text("Could not delete todo")]),
    alert.content([], [
      html.p([], [html.text("Check your internet connection and try again.")]),
    ]),
  ])
}
