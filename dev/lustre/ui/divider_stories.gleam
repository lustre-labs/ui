// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/element/html
import lustre/ui/divider
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Divider", [basic_divider_story(), text_label_divider_story()])
}

fn basic_divider_story() {
  use <- fable.story("Basic Divider with No Content")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  html.div([], [
    html.p([], [
      html.text(
        "This is some content before the divider. The divider below has no content and serves as a simple horizontal rule.",
      ),
    ]),
    divider.element([], []),
    html.p([], [
      html.text(
        "This is some content after the divider. Notice how the divider creates a clear separation between content sections.",
      ),
    ]),
  ])
}

fn text_label_divider_story() {
  use <- fable.story("Divider with Text Label")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  html.div([], [
    html.p([], [html.text("Sign in with your email and password")]),
    html.div([], [
      // Form fields would go here in a real implementation
      html.p([], [html.text("(Form fields placeholder)")]),
    ]),
    divider.element([], [html.text("OR")]),
    html.p([], [html.text("Continue with social login")]),
    html.div([], [
      // Social login buttons would go here
      html.p([], [html.text("(Social login buttons placeholder)")]),
    ]),
  ])
}
