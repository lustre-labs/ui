// IMPORTS ---------------------------------------------------------------------

import birdie
import gleam/float
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import lustre/ui/tween

// TESTS -----------------------------------------------------------------------

pub fn linear_tween_test() {
  use at, from, to <- plot("Tween linear")
  tween.linear(at, from, to)
}

pub fn sine_in_tween_test() {
  use at, from, to <- plot("Tween in sine")
  tween.sine(at, from, to, tween.In)
}

pub fn sine_out_tween_test() {
  use at, from, to <- plot("Tween out sine")
  tween.sine(at, from, to, tween.Out)
}

pub fn sine_in_out_tween_test() {
  use at, from, to <- plot("Tween in out sine")
  tween.sine(at, from, to, tween.InOut)
}

pub fn quad_in_tween_test() {
  use at, from, to <- plot("Tween in quadratic")
  tween.quadratic(at, from, to, tween.In)
}

pub fn quad_out_tween_test() {
  use at, from, to <- plot("Tween out quadratic")
  tween.quadratic(at, from, to, tween.Out)
}

pub fn quad_in_out_tween_test() {
  use at, from, to <- plot("Tween in out quadratic")
  tween.quadratic(at, from, to, tween.InOut)
}

pub fn cubic_in_tween_test() {
  use at, from, to <- plot("Tween in cubic")
  tween.cubic(at, from, to, tween.In)
}

pub fn cubic_out_tween_test() {
  use at, from, to <- plot("Tween out cubic")
  tween.cubic(at, from, to, tween.Out)
}

pub fn cubic_in_out_tween_test() {
  use at, from, to <- plot("Tween in out cubic")
  tween.cubic(at, from, to, tween.InOut)
}

pub fn quart_in_tween_test() {
  use at, from, to <- plot("Tween in quartic")
  tween.quartic(at, from, to, tween.In)
}

pub fn quart_out_tween_test() {
  use at, from, to <- plot("Tween out quartic")
  tween.quartic(at, from, to, tween.Out)
}

pub fn quart_in_out_tween_test() {
  use at, from, to <- plot("Tween in out quartic")
  tween.quartic(at, from, to, tween.InOut)
}

pub fn quint_in_tween_test() {
  use at, from, to <- plot("Tween in Quint")
  tween.quintic(at, from, to, tween.In)
}

pub fn quint_out_tween_test() {
  use at, from, to <- plot("Tween out Quint")
  tween.quintic(at, from, to, tween.Out)
}

pub fn quint_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Quint")
  tween.quintic(at, from, to, tween.InOut)
}

pub fn expo_in_tween_test() {
  use at, from, to <- plot("Tween in Expo")
  tween.exponential(at, from, to, tween.In)
}

pub fn expo_out_tween_test() {
  use at, from, to <- plot("Tween out Expo")
  tween.exponential(at, from, to, tween.Out)
}

pub fn expo_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Expo")
  tween.exponential(at, from, to, tween.InOut)
}

pub fn circ_in_tween_test() {
  use at, from, to <- plot("Tween in Circ")
  tween.circular(at, from, to, tween.In)
}

pub fn circ_out_tween_test() {
  use at, from, to <- plot("Tween out Circ")
  tween.circular(at, from, to, tween.Out)
}

pub fn circ_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Circ")
  tween.circular(at, from, to, tween.InOut)
}

pub fn back_in_tween_test() {
  use at, from, to <- plot("Tween in Back")
  tween.back(at, from, to, tween.In)
}

pub fn back_out_tween_test() {
  use at, from, to <- plot("Tween out Back")
  tween.back(at, from, to, tween.Out)
}

pub fn back_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Back")
  tween.back(at, from, to, tween.InOut)
}

pub fn elastic_in_tween_test() {
  use at, from, to <- plot("Tween in Elastic")
  tween.elastic(at, from, to, tween.In)
}

pub fn elastic_out_tween_test() {
  use at, from, to <- plot("Tween out Elastic")
  tween.elastic(at, from, to, tween.Out)
}

pub fn elastic_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Elastic")
  tween.elastic(at, from, to, tween.InOut)
}

pub fn bounce_in_tween_test() {
  use at, from, to <- plot("Tween in Bounce")
  tween.bounce(at, from, to, tween.In)
}

pub fn bounce_out_tween_test() {
  use at, from, to <- plot("Tween out Bounce")
  tween.bounce(at, from, to, tween.Out)
}

pub fn bounce_in_out_tween_test() {
  use at, from, to <- plot("Tween in out Bounce")
  tween.bounce(at, from, to, tween.InOut)
}

// HELPERS ---------------------------------------------------------------------

const steps = 35

/// Plots a function and then take a snapshot using birdie.
fn plot(title: String, function: fn(Float, Float, Float) -> Float) -> Nil {
  function
  |> make_plot
  |> show_plot
  |> birdie.snap(title)
}

fn make_plot(function: fn(Float, Float, Float) -> Float) -> Set(#(Int, Int)) {
  use plot, x <- list.fold(list.range(0, steps), set.new())
  let at = int.to_float(x) /. int.to_float(steps)
  let y = function(at, 0.0, int.to_float(steps))

  set.insert(plot, #(x, float.round(y)))
}

fn show_plot(points: Set(#(Int, Int))) -> String {
  let lines = {
    use y <- list.map(list.range(steps, 0))
    use line, x <- list.fold(list.range(0, steps), "")

    case set.contains(points, #(x, y)) {
      True -> line <> "◍"
      False -> line <> " "
    }
  }

  string.join(lines, "\n")
}
