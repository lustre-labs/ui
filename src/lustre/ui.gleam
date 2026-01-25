// IMPORTS ---------------------------------------------------------------------

import gleam/result
import lustre
import lustre/ui/accordion
import lustre/ui/tabs

// ELEMENTS --------------------------------------------------------------------

@internal
pub fn main() -> Result(Nil, lustre.Error) {
  register()
}

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(accordion.register())
  use _ <- result.try(tabs.register())

  Ok(Nil)
}
