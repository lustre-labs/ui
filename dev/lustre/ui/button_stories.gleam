// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/element/html
import lustre/ui/button
import lustre/ui/primitives/icon
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Button", [basic_button_story(), command_palette_button_story()])
}

fn basic_button_story() {
  use <- fable.story("Basic Button with Icon and Text")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  button.element([], [icon.bookmark([]), html.text(" Save")])
}

fn command_palette_button_story() {
  use <- fable.story("Command Palette Button with Keyboard Shortcut")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  button.element([button.solid()], [
    html.text("Open"),
    button.shortcut_badge([], ["⌘", "k"]),
  ])
}
