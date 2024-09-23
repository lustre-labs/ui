import lustre
import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html
import lustre/ui/button
import lustre/ui/theme

pub fn main() {
  let theme = theme.default()
  let app =
    lustre.element(
      element.fragment([
        theme.to_style(theme),
        html.div([attribute.class("flex flex-col gap-lui-sm")], [
          swatches("base"),
          swatches("primary"),
          swatches("secondary"),
          swatches("success"),
          swatches("warning"),
          swatches("danger"),
          button.demo(),
        ]),
      ]),
    )

  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn swatches(palette) {
  let swatch = fn(colour) {
    html.div(
      [
        attribute.class("w-10 h-10 rounded"),
        attribute.style([#("background-color", "rgb(" <> colour <> ")")]),
      ],
      [],
    )
  }

  html.div(
    [attribute.class("flex gap-lui-sm base"), attribute("data-scale", palette)],
    [
      swatch(theme.colour.bg),
      swatch(theme.colour.bg_subtle),
      swatch(theme.colour.tint),
      swatch(theme.colour.tint_subtle),
      swatch(theme.colour.tint_strong),
      swatch(theme.colour.accent),
      swatch(theme.colour.accent_subtle),
      swatch(theme.colour.accent_strong),
      swatch(theme.colour.solid),
      swatch(theme.colour.solid_subtle),
      swatch(theme.colour.solid_strong),
      swatch(theme.colour.solid_text),
      swatch(theme.colour.text),
      swatch(theme.colour.text_subtle),
    ],
  )
}
