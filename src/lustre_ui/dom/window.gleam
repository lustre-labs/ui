// IMPORTS ---------------------------------------------------------------------

import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

pub type TimeoutId

// EFFECTS ---------------------------------------------------------------------

pub fn set_timeout(
  after: Int,
  with_timeout_id: fn(TimeoutId) -> message,
  do: fn(fn(message) -> Nil) -> Nil,
) -> Effect(message) {
  use dispatch <- effect.from
  let timeout_id = do_set_timeout(after, fn() { do(dispatch) })

  dispatch(with_timeout_id(timeout_id))
}

@external(javascript, "./window.ffi.mjs", "setTimeout")
fn do_set_timeout(after: Int, do: fn() -> Nil) -> TimeoutId

pub fn cancel_timeout(timeout_id: TimeoutId) -> Effect(message) {
  use _ <- effect.from

  do_cancel_timeout(timeout_id)
}

@external(javascript, "./window.ffi.mjs", "cancelTimeout")
fn do_cancel_timeout(timeout_id: TimeoutId) -> Nil
