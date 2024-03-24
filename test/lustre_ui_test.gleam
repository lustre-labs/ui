import gleam/json
import gleeunit
import gleeunit/should
import lustre/ui.{Theme}
import lustre/ui/colour

pub fn main() {
  gleeunit.main()
}

pub fn json_identity_test() {
  let theme =
    Theme(
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
