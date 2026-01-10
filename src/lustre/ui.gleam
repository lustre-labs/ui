// IMPORTS ---------------------------------------------------------------------

import gleam/result
import lustre
import lustre/ui/accordion

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(accordion.register())

  Ok(Nil)
}
