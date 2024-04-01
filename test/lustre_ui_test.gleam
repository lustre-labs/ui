import gleam/json
import gleeunit
import gleeunit/should
import lustre/ui.{Px, Rem, Size, Theme}
import lustre/ui/util/colour

pub fn main() {
  gleeunit.main()
}

pub fn json_identity_test() {
  let theme =
    Theme(
      space: Size(base: Rem(1.0), ratio: 1.618),
      text: Size(base: Rem(1.125), ratio: 1.215),
      radius: Px(4.0),
      primary: colour.iris(),
      greyscale: colour.slate(),
      error: colour.red(),
      success: colour.green(),
      warning: colour.yellow(),
      info: colour.blue(),
    )

  theme
  |> ui.encode_theme
  |> json.to_string
  |> json.decode(ui.theme_decoder)
  |> should.equal(Ok(theme))
}
