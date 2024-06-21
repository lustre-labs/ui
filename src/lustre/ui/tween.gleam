// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/float
import gleam_community/maths/elementary

// TYPES -----------------------------------------------------------------------

pub type Algorithm {
  Sine
  Quad
  Cubic
  Quart
  Expo
  Circ
  Back
}

// EASE IN ---------------------------------------------------------------------

pub fn ease_in(
  using algorithm: Algorithm,
  from x: Float,
  to y: Float,
  at t: Float,
) -> Float {
  case algorithm {
    Sine -> ease_in_sine(x, y, t)
    Quad -> ease_in_quad(x, y, t)
    Cubic -> ease_in_cubic(x, y, t)
    Quart -> ease_in_quart(x, y, t)
    Expo -> ease_in_expo(x, y, t)
    Circ -> ease_in_circ(x, y, t)
    Back -> ease_in_back(x, y, t)
  }
}

pub fn ease_in_sine(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInSine
  let diff = y -. x
  let t = t /. y
  let n = 1.0 -. elementary.cos({ t *. elementary.pi() } /. 2.0)

  n *. diff +. x
}

pub fn ease_in_quad(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInQuad
  let diff = y -. x
  let t = t /. y
  let n = t *. t

  n *. diff +. x
}

pub fn ease_in_cubic(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInCubic
  let diff = y -. x
  let t = t /. y
  let n = t *. t *. t

  n *. diff +. x
}

pub fn ease_in_quart(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInQuart
  let diff = y -. x
  let t = t /. y
  let n = t *. t *. t *. t

  n *. diff +. x
}

pub fn ease_in_expo(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInExpo
  let diff = y -. x
  let t = t /. y
  use <- bool.guard(t == 0.0, x)

  case float.power(2.0, 10.0 *. { t -. 10.0 }) {
    Ok(n) -> n *. diff +. x
    Error(_) -> x
  }
}

pub fn ease_in_circ(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInCirc
  let diff = y -. x
  let t = t /. y

  case elementary.square_root(1.0 -. { t *. t }) {
    Ok(n) -> { 1.0 -. n } *. diff +. x
    Error(_) -> x
  }
}

pub fn ease_in_back(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeInBack
  let c1 = 1.70158
  let c3 = c1 +. 1.0

  let diff = y -. x
  let t = t /. y
  let n = c3 *. t *. t *. t -. c1 *. t *. t

  n *. diff +. x
}

// EASE OUT --------------------------------------------------------------------

pub fn ease_out(
  using algorithm: Algorithm,
  from x: Float,
  to y: Float,
  at t: Float,
) -> Float {
  case algorithm {
    Sine -> ease_out_sine(x, y, t)
    Quad -> ease_out_quad(x, y, t)
    Cubic -> ease_out_cubic(x, y, t)
    Quart -> ease_out_quart(x, y, t)
    Expo -> ease_out_expo(x, y, t)
    Circ -> ease_out_circ(x, y, t)
    Back -> ease_out_back(x, y, t)
  }
}

pub fn ease_out_sine(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutSine
  let diff = y -. x
  let t = t /. y
  let n = elementary.sin({ t *. elementary.pi() } /. 2.0)

  n *. diff +. x
}

pub fn ease_out_quad(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutQuad
  let diff = y -. x
  let t = t /. y
  let n = 1.0 -. { 1.0 -. t } *. { 1.0 -. t }

  n *. diff +. x
}

pub fn ease_out_cubic(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutCubic
  let diff = y -. x
  let t = t /. y

  case float.power(1.0 -. t, 3.0) {
    Ok(n) -> { 1.0 -. n } *. diff +. x
    Error(_) -> x
  }
}

pub fn ease_out_quart(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutQuart
  let diff = y -. x
  let t = t /. y

  case float.power(1.0 -. t, 3.0) {
    Ok(n) -> { 1.0 -. n } *. diff +. x
    Error(_) -> x
  }
}

pub fn ease_out_expo(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutExpo
  let diff = y -. x
  let t = t /. y
  use <- bool.guard(t == 1.0, y)

  case float.power(2.0, -10.0 *. t) {
    Ok(n) -> { 1.0 -. n } *. diff +. x
    Error(_) -> x
  }
}

pub fn ease_out_circ(from x: Float, to y: Float, at t: Float) -> Float {
  // https://easings.net/#easeOutCirc
  let diff = y -. x
  let t = t /. y

  case elementary.square_root(1.0 -. { t -. 1.0 } *. { t -. 1.0 }) {
    Ok(n) -> n *. diff +. x
    Error(_) -> y
  }
}

pub fn ease_out_back(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let c1 = 1.70158
  let c3 = c1 +. 1.0
  let t = t /. y
  let n =
    c3
    *. { t -. 1.0 }
    *. { t -. 1.0 }
    *. { t -. 1.0 }
    +. c1
    *. { t -. 1.0 }
    *. { t -. 1.0 }
    +. 1.0

  n *. diff +. x
}

// EASE IN OUT -----------------------------------------------------------------

pub fn ease_in_out(
  using algorithm: Algorithm,
  from x: Float,
  to y: Float,
  at t: Float,
) -> Float {
  case algorithm {
    Sine -> ease_in_out_sine(x, y, t)
    Quad -> ease_in_out_quad(x, y, t)
    Cubic -> ease_in_out_cubic(x, y, t)
    Quart -> ease_in_out_quart(x, y, t)
    Expo -> ease_in_out_expo(x, y, t)
    Circ -> ease_in_out_circ(x, y, t)
    Back -> ease_in_out_back(x, y, t)
  }
}

pub fn ease_in_out_sine(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  let n = { -1.0 *. elementary.cos({ elementary.pi() *. t }) +. 1.0 } /. 2.0

  n *. diff +. x
}

pub fn ease_in_out_quad(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  let n = case t <. 0.5 {
    True -> { 2.0 *. t } *. { 2.0 *. t }
    False -> 1.0 -. { -2.0 *. t +. 2.0 } *. { -2.0 *. t +. 2.0 }
  }

  n *. diff +. x
}

pub fn ease_in_out_cubic(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  let n = case t <. 0.5 {
    True -> { 4.0 *. t } *. { 4.0 *. t } *. { 4.0 *. t }
    False -> { t -. 1.0 } *. { 2.0 *. t -. 2.0 } *. { 2.0 *. t -. 2.0 } +. 1.0
  }

  n *. diff +. x
}

pub fn ease_in_out_quart(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  let n = case t <. 0.5 {
    True -> { 8.0 *. t } *. { 8.0 *. t } *. { 8.0 *. t } *. { 8.0 *. t }
    False ->
      { t -. 1.0 }
      *. { 2.0 *. t -. 2.0 }
      *. { 2.0 *. t -. 2.0 }
      *. { 2.0 *. t -. 2.0 }
      +. 1.0
  }

  n *. diff +. x
}

pub fn ease_in_out_expo(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  use <- bool.guard(t == 1.0, y)

  case float.power(2.0, 20.0 *. t -. 10.0) {
    Ok(n) ->
      case t <. 0.5 {
        True -> n *. 0.5 *. diff +. x
        False -> { n -. 0.5 } *. diff +. x
      }
    Error(_) -> x
  }
}

pub fn ease_in_out_circ(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let t = t /. y
  let n = case t <. 0.5 {
    True ->
      case elementary.square_root(1.0 -. { 2.0 *. t } *. { 2.0 *. t }) {
        Ok(n) -> { -1.0 *. n +. 1.0 } /. 2.0
        Error(_) -> x
      }

    False ->
      case
        elementary.square_root(
          1.0 -. { -2.0 *. t +. 2.0 } *. { -2.0 *. t +. 2.0 },
        )
      {
        Ok(n) -> { n +. 1.0 } /. 2.0
        Error(_) -> y
      }
  }

  n *. diff +. x
}

pub fn ease_in_out_back(from x: Float, to y: Float, at t: Float) -> Float {
  let diff = y -. x
  let c1 = 1.70158
  let c2 = c1 *. 1.525
  let t = t /. y
  let n = case t <. 0.5 {
    True -> 2.0 *. { t *. t } *. { { c2 +. 1.0 } *. t -. c2 }
    False ->
      2.0
      *. { t -. 1.0 }
      *. { t -. 1.0 }
      *. { { c2 +. 1.0 } *. { t -. 1.0 } +. c2 }
  }

  n *. diff +. x
}
