import lustre
import lustre/attribute.{attribute}
import lustre/element/html
import lustre/ui/accordion.{accordion}
import lustre/ui/card.{card}
import lustre/ui/colour
import lustre/ui/combobox.{combobox}

import lustre/ui/reveal.{reveal}
import lustre/ui/theme
import lustre/ui/ticker.{ticker}

pub fn main() {
  let assert Ok(_) = accordion.register()
  let assert Ok(_) = combobox.register()
  let assert Ok(_) = ticker.register()
  let assert Ok(_) = reveal.register()

  let theme =
    theme.default()
    |> theme.with_base_scale(colour.sand())
    |> theme.with_primary_scale(colour.green())
    |> theme.with_radius(theme.perfect_fifth(1.0))

  let app =
    lustre.element({
      use <- theme.inject(theme)
      html.div(
        [
          attribute.style([
            #("width", "100vw"),
            #("height", "100vh"),
            #("display", "flex"),
            #("flex-direction", "column"),
            #("align-items", "center"),
            #("justify-content", "center"),
            #("margin", "0 auto"),
          ]),
        ],
        [
          card([attribute.style([#("width", "24rem")])], [
            card.content([], [
              combobox([attribute.style([#("width", "100%")])], [
                combobox.option("a", "wibble"),
                combobox.option("b", "wobble"),
              ]),
            ]),
          ]),
        ],
      )
    })

  let assert Ok(_) = lustre.start(app, "#app", Nil)
}
