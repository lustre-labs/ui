import gleam/option.{None}
import lustre
import lustre/attribute.{attribute}
import lustre/element/html
import lustre/ui/listbox.{listbox}

pub fn main() {
  let app =
    lustre.element(html.div(
      [attribute.style([#("padding", "var(--space-sm) var(--space-lg)")])],
      [listbox_demo()],
    ))
  let assert Ok(_) = lustre.start(app, "[data-lustre-app]", Nil)
}

fn listbox_demo() {
  let label = "Best person"
  let options = ["Hayleigh", "Louis", "McKayla", "Danielle"]
  let default = None
  let on_change = fn(_) { Nil }

  html.div(
    [attribute.style([#("display", "flex"), #("gap", "var(--space-base)")])],
    [
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "primary"),
        ],
        [listbox(label <> " (primary)", options, default, on_change)],
      ),
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "greyscale"),
        ],
        [listbox(label <> " (greyscale)", options, default, on_change)],
      ),
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "error"),
        ],
        [listbox(label <> " (error)", options, default, on_change)],
      ),
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "warning"),
        ],
        [listbox(label <> " (warning)", options, default, on_change)],
      ),
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "info"),
        ],
        [listbox(label <> " (info)", options, default, on_change)],
      ),
      html.div(
        [
          attribute.style([#("width", "200px")]),
          attribute("data-variant", "success"),
        ],
        [listbox(label <> " (success)", options, default, on_change)],
      ),
    ],
  )
}
