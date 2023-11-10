import lustre/effect.{type Effect}

pub fn focus(selector: String) -> Effect(msg) {
  use _ <- effect.from
  do_focus(selector)
}

@external(javascript, "../lustre_ui.ffi.mjs", "focus")
fn do_focus(_selector: String) -> Nil {
  Nil
}
