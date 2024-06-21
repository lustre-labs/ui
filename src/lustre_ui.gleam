// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/element/html

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.element(html.h1([], [html.text("Some demo app, hi there!")]))
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
