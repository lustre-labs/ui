// IMPORTS ---------------------------------------------------------------------

import gleam/result
import lustre
import lustre/ui/accordion
import lustre/ui/tabs
import lustre/ui/toggle
import lustre/ui/tooltip

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
  use _ <- result.try(toggle.register())
  use _ <- result.try(tooltip.register())

  Ok(Nil)
}
