// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/float
import gleam/result
import gleam_community/maths/elementary.{cos, pi, sin}

// TYPES -----------------------------------------------------------------------

/// The type of easing function to use.
///
pub type Function {
  Linear
  Sine(Kind)
  Quadratic(Kind)
  Cubic(Kind)
  Quartic(Kind)
  Quintic(Kind)
  Exponential(Kind)
  Circular(Kind)
  Elastic(Kind)
  Back(Kind)
  Bounce(Kind)
}

pub type Kind {
  In
  Out
  InOut
}

pub fn tween(at: Float, from: Float, to: Float, using: Function) -> Float {
  case using {
    Linear -> linear(at, from, to)
    Sine(kind) -> sine(at, from, to, kind)
    Quadratic(kind) -> quadratic(at, from, to, kind)
    Cubic(kind) -> cubic(at, from, to, kind)
    Quartic(kind) -> quartic(at, from, to, kind)
    Quintic(kind) -> quintic(at, from, to, kind)
    Exponential(kind) -> exponential(at, from, to, kind)
    Circular(kind) -> circular(at, from, to, kind)
    Elastic(kind) -> elastic(at, from, to, kind)
    Back(kind) -> back(at, from, to, kind)
    Bounce(kind) -> bounce(at, from, to, kind)
  }
}

// LINEAR TWEENING -------------------------------------------------------------

pub fn linear(at: Float, from: Float, to: Float) -> Float {
  from +. { to -. from } *. at
}

// SINE TWEENING ---------------------------------------------------------------

pub fn sine(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> sine_in(t, b, c, d)
    Out -> sine_out(t, b, c, d)
    InOut -> sine_in_out(t, b, c, d)
  }
}

fn sine_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. -1.0 *. cos(t /. d *. { pi() /. 2.0 }) +. c +. b
}

fn sine_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. sin(t /. d *. { pi() /. 2.0 }) +. b
}

fn sine_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. -1.0 /. 2.0 *. { cos(pi() *. t /. d) -. 1.0 } +. b
}

// QUADRATIC TWEENING ---------------------------------------------------------

pub fn quadratic(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> quadratic_in(t, b, c, d)
    Out -> quadratic_out(t, b, c, d)
    InOut -> quadratic_in_out(t, b, c, d)
  }
}

fn quadratic_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. { t /. d } *. { t /. d } +. b
}

fn quadratic_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. { -1.0 *. t /. d *. { t /. d -. 2.0 } } +. b
}

fn quadratic_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. t *. t +. b
    False -> {
      let t = t -. 1.0

      c /. -2.0 *. { t *. { t -. 2.0 } -. 1.0 } +. b
    }
  }
}

// CUBIC TWEENING -------------------------------------------------------------

pub fn cubic(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> cubic_in(t, b, c, d)
    Out -> cubic_out(t, b, c, d)
    InOut -> cubic_in_out(t, b, c, d)
  }
}

fn cubic_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. { t /. d } *. { t /. d } *. { t /. d } +. b
}

fn cubic_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d -. 1.0

  c *. { t *. t *. t +. 1.0 } +. b
}

fn cubic_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. t *. t *. t +. b
    False -> {
      let t = t -. 2.0

      c /. 2.0 *. { t *. t *. t +. 2.0 } +. b
    }
  }
}

// QUARTIC TWEENING ------------------------------------------------------------

pub fn quartic(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> quartic_in(t, b, c, d)
    Out -> quartic_out(t, b, c, d)
    InOut -> quartic_in_out(t, b, c, d)
  }
}

fn quartic_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. pow(t /. d, 4.0) +. b
}

fn quartic_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d -. 1.0

  c *. { 1.0 -. pow(t, 4.0) } +. b
}

fn quartic_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. pow(t, 4.0) +. b

    False -> {
      let t = t -. 2.0

      c /. -2.0 *. { pow(t, 4.0) -. 2.0 } +. b
    }
  }
}

// QUINTIC TWEENING ------------------------------------------------------------

pub fn quintic(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> quintic_in(t, b, c, d)
    Out -> quintic_out(t, b, c, d)
    InOut -> quintic_in_out(t, b, c, d)
  }
}

fn quintic_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c *. pow(t /. d, 5.0) +. b
}

fn quintic_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d -. 1.0

  c *. { pow(t, 5.0) +. 1.0 } +. b
}

fn quintic_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. pow(t, 5.0) +. b

    False -> {
      let t = t -. 2.0

      c /. 2.0 *. { pow(t, 5.0) +. 2.0 } +. b
    }
  }
}

// EXPONENTIAL TWEENING --------------------------------------------------------

pub fn exponential(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> exponential_in(t, b, c, d)
    Out -> exponential_out(t, b, c, d)
    InOut -> exponential_in_out(t, b, c, d)
  }
}

fn exponential_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  case t == 0.0 {
    True -> b
    False -> c *. pow(2.0, 10.0 *. { t /. d -. 1.0 }) +. b
  }
}

fn exponential_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  case t == d {
    True -> b +. c
    False -> c *. { -1.0 *. pow(2.0, -10.0 *. t /. d) +. 1.0 } +. b
  }
}

fn exponential_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  use <- bool.guard(t == 0.0, b)
  use <- bool.guard(t == d, b +. c)

  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. pow(2.0, 10.0 *. { t -. 1.0 }) +. b

    False -> {
      let t = t -. 1.0

      c /. 2.0 *. { -1.0 *. pow(2.0, -10.0 *. t) +. 2.0 } +. b
    }
  }
}

// CIRCULAR TWEENING -----------------------------------------------------------

pub fn circular(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> circular_in(t, b, c, d)
    Out -> circular_out(t, b, c, d)
    InOut -> circular_in_out(t, b, c, d)
  }
}

fn circular_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d

  c *. { -1.0 *. { sqrt(1.0 -. t *. t) -. 1.0 } } +. b
}

fn circular_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d -. 1.0

  c *. sqrt(1.0 -. t *. t) +. b
}

fn circular_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. -2.0 *. { sqrt(1.0 -. t *. t) -. 1.0 } +. b

    False -> {
      let t = t -. 2.0

      c /. 2.0 *. { sqrt(1.0 -. t *. t) +. 1.0 } +. b
    }
  }
}

// ELASTIC TWEENING ------------------------------------------------------------

pub fn elastic(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> elastic_in(t, b, c, d)
    Out -> elastic_out(t, b, c, d)
    InOut -> elastic_in_out(t, b, c, d)
  }
}

fn elastic_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  use <- bool.guard(t == 0.0, b)
  use <- bool.guard(t /. d == 1.0, b +. c)

  let p = d *. 0.3
  let s = p /. 4.0
  let t = t /. d -. 1.0

  c
  *. -1.0
  *. pow(2.0, 10.0 *. t)
  *. sin({ t *. d -. s } *. { 2.0 *. pi() } /. p)
  +. b
}

fn elastic_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  use <- bool.guard(t == 0.0, b)
  use <- bool.guard(t /. d == 1.0, b +. c)

  let p = d *. 0.3
  let s = p /. 4.0

  c
  *. pow(2.0, -10.0 *. t /. d)
  *. sin({ t *. d -. s } *. { 2.0 *. pi() } /. p)
  +. c
  +. b
}

fn elastic_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  use <- bool.guard(t == 0.0, b)
  use <- bool.guard(t /. d == 1.0, b +. c)

  let p = d *. { 0.3 *. 1.5 }
  let s = p /. 4.0
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> {
      let t = t -. 1.0

      c
      /. -2.0
      *. pow(2.0, 10.0 *. t)
      *. sin({ t *. d -. s } *. { 2.0 *. pi() } /. p)
      +. b
    }

    False -> {
      let t = t -. 1.0

      c
      /. 2.0
      *. pow(2.0, -10.0 *. t)
      *. sin({ t *. d -. s } *. { 2.0 *. pi() } /. p)
      +. c
      +. b
    }
  }
}

// BACK TWEENING ---------------------------------------------------------------

pub fn back(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> back_in(t, b, c, d)
    Out -> back_out(t, b, c, d)
    InOut -> back_in_out(t, b, c, d)
  }
}

fn back_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  let s = 1.70158
  let t = t /. d

  c *. t *. t *. { { s +. 1.0 } *. t -. s } +. b
}

fn back_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let s = 1.70158
  let t = t /. d -. 1.0

  c *. { t *. t *. { { s +. 1.0 } *. t +. s } +. 1.0 } +. b
}

fn back_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let s = 1.70158 *. 1.525
  let t = t /. { d /. 2.0 }

  case t <. 1.0 {
    True -> c /. 2.0 *. { t *. t *. { { s +. 1.0 } *. t -. s } } +. b

    False -> {
      let t = t -. 2.0

      c /. 2.0 *. { t *. t *. { { s +. 1.0 } *. t +. s } +. 2.0 } +. b
    }
  }
}

// BOUNCE TWEENING -------------------------------------------------------------

pub fn bounce(at: Float, from: Float, to: Float, kind: Kind) -> Float {
  let t = at
  let b = from
  let c = to -. from
  let d = 1.0

  case kind {
    In -> bounce_in(t, b, c, d)
    Out -> bounce_out(t, b, c, d)
    InOut -> bounce_in_out(t, b, c, d)
  }
}

fn bounce_in(t: Float, b: Float, c: Float, d: Float) -> Float {
  c -. bounce_out(d -. t, 0.0, c, d) +. b
}

fn bounce_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  let t = t /. d

  case t <. 1.0 /. 2.75 {
    True -> c *. { 7.5625 *. t *. t } +. b

    False if t <. 2.0 /. 2.75 -> {
      let t = t -. { 1.5 /. 2.75 }

      c *. { 7.5625 *. t *. t +. 0.75 } +. b
    }

    False if t <. 2.5 /. 2.75 -> {
      let t = t -. { 2.25 /. 2.75 }

      c *. { 7.5625 *. t *. t +. 0.9375 } +. b
    }

    False -> {
      let t = t -. { 2.625 /. 2.75 }

      c *. { 7.5625 *. t *. t +. 0.984375 } +. b
    }
  }
}

fn bounce_in_out(t: Float, b: Float, c: Float, d: Float) -> Float {
  case t <. d /. 2.0 {
    True -> bounce_in(t *. 2.0, 0.0, c, d) *. 0.5 +. b
    False -> bounce_out(t *. 2.0 -. d, 0.0, c, d) *. 0.5 +. c *. 0.5 +. b
  }
}

// CONVERSIONS -----------------------------------------------------------------

pub fn to_string(function: Function) -> String {
  case function {
    Linear -> "linear"
    Sine(In) -> "sine-in"
    Sine(Out) -> "sine-out"
    Sine(InOut) -> "sine-in-out"
    Quadratic(In) -> "quadratic-in"
    Quadratic(Out) -> "quadratic-out"
    Quadratic(InOut) -> "quadratic-in-out"
    Cubic(In) -> "cubic-in"
    Cubic(Out) -> "cubic-out"
    Cubic(InOut) -> "cubic-in-out"
    Quartic(In) -> "quartic-in"
    Quartic(Out) -> "quartic-out"
    Quartic(InOut) -> "quartic-in-out"
    Quintic(In) -> "quintic-in"
    Quintic(Out) -> "quintic-out"
    Quintic(InOut) -> "quintic-in-out"
    Exponential(In) -> "exponential-in"
    Exponential(Out) -> "exponential-out"
    Exponential(InOut) -> "exponential-in-out"
    Circular(In) -> "circular-in"
    Circular(Out) -> "circular-out"
    Circular(InOut) -> "circular-in-out"
    Elastic(In) -> "elastic-in"
    Elastic(Out) -> "elastic-out"
    Elastic(InOut) -> "elastic-in-out"
    Back(In) -> "back-in"
    Back(Out) -> "back-out"
    Back(InOut) -> "back-in-out"
    Bounce(In) -> "bounce-in"
    Bounce(Out) -> "bounce-out"
    Bounce(InOut) -> "bounce-in-out"
  }
}

pub fn from_string(function: String) -> Result(Function, Nil) {
  case function {
    "linear" -> Ok(Linear)
    "sine-in" -> Ok(Sine(In))
    "sine-out" -> Ok(Sine(Out))
    "sine-in-out" -> Ok(Sine(InOut))
    "quadratic-in" -> Ok(Quadratic(In))
    "quadratic-out" -> Ok(Quadratic(Out))
    "quadratic-in-out" -> Ok(Quadratic(InOut))
    "cubic-in" -> Ok(Cubic(In))
    "cubic-out" -> Ok(Cubic(Out))
    "cubic-in-out" -> Ok(Cubic(InOut))
    "quartic-in" -> Ok(Quartic(In))
    "quartic-out" -> Ok(Quartic(Out))
    "quartic-in-out" -> Ok(Quartic(InOut))
    "quintic-in" -> Ok(Quintic(In))
    "quintic-out" -> Ok(Quintic(Out))
    "quintic-in-out" -> Ok(Quintic(InOut))
    "exponential-in" -> Ok(Exponential(In))
    "exponential-out" -> Ok(Exponential(Out))
    "exponential-in-out" -> Ok(Exponential(InOut))
    "circular-in" -> Ok(Circular(In))
    "circular-out" -> Ok(Circular(Out))
    "circular-in-out" -> Ok(Circular(InOut))
    "elastic-in" -> Ok(Elastic(In))
    "elastic-out" -> Ok(Elastic(Out))
    "elastic-in-out" -> Ok(Elastic(InOut))
    "back-in" -> Ok(Back(In))
    "back-out" -> Ok(Back(Out))
    "back-in-out" -> Ok(Back(InOut))
    "bounce-in" -> Ok(Bounce(In))
    "bounce-out" -> Ok(Bounce(Out))
    "bounce-in-out" -> Ok(Bounce(InOut))
    _ -> Error(Nil)
  }
}

// UTILS -----------------------------------------------------------------------

fn pow(base: Float, exponent: Float) -> Float {
  float.power(base, exponent) |> result.unwrap(0.0)
}

fn sqrt(value: Float) -> Float {
  float.square_root(value) |> result.unwrap(0.0)
}
