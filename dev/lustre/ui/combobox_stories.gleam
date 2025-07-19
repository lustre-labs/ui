// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/ui/combobox
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  let assert Ok(_) = combobox.register()

  fable.chapter("Combobox", [basic_story()])
}

fn basic_story() {
  use <- fable.story("Typeahead filter")
  use value <- fable.input("Value", "gleam")
  use controls <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  combobox.element(
    [
      combobox.value(fable.get(controls, value)),
      combobox.on_change(fable.set(value, _)),
    ],
    [
      combobox.option(value: "gleam", label: "Gleam"),
      combobox.option(value: "go", label: "Go"),
      combobox.option(value: "javascript", label: "JavaScript"),
      combobox.option(value: "kotlin", label: "Kotlin"),
      combobox.option(value: "rust", label: "Rust"),
      combobox.option(value: "typescript", label: "TypeScript"),
    ],
  )
}
