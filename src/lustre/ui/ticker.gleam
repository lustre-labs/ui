// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/float
import gleam/int
import gleam/result
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/tween.{tween}

//                                                                            //
// PUBLIC API ------------------------------------------------------------------
//                                                                            //

// ELEMENTS --------------------------------------------------------------------

// The name of the custom element as rendered in the DOM: "lustre-ui-collapse".
//
pub const name: String = "lustre-ui-ticker"

// Register the collapse component with the tag name "lustre-ui-collapse". You
// must do this before the component will properly render.
//
pub fn register() -> Result(Nil, lustre.Error) {
  case register_intersection_observer() {
    // We don't care if the intersection observer had already been registered,
    // we just want to make sure it's registered now.
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app = lustre.component(init, update, view, on_attribute_change())
      lustre.register(app, name)
    }
    error -> error
  }
}

@external(javascript, "../../dom.ffi.mjs", "register_intersection_observer")
fn register_intersection_observer() -> Result(Nil, lustre.Error)

//
// The `trigger` element should **not** contain interactive controls such as
// buttons or inputs.
//
// The size of the `content` element is measured whenever it changes (but not
// if its children change) and the collapse will adjust its height accordingly.
//
pub fn ticker(attributes: List(Attribute(msg))) -> Element(msg) {
  element(name, attributes, [])
}

// ATTRIBUTES ------------------------------------------------------------------

//
pub fn value(num: Int) -> Attribute(msg) {
  attribute("value", int.to_string(num))
}

//
pub fn duration(ms: Int) -> Attribute(msg) {
  attribute("duration", int.to_string(ms))
}

//                                                                            --
// INTERNALS -------------------------------------------------------------------
//                                                                            --

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    from: Float,
    value: Float,
    to: Float,
    duration: Float,
    now: Float,
    start: Float,
    target: Float,
    function: tween.Function,
    can_animate: Bool,
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      from: 0.0,
      value: 0.0,
      to: 0.0,
      duration: 0.0,
      now: 0.0,
      start: 0.0,
      target: 0.0,
      function: tween.Exponential(tween.InOut),
      can_animate: False,
    )
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ElementEnteredViewport
  ElementExitedViewport
  ParentSetDuration(Float)
  ParentSetFunction(tween.Function)
  ParentSetTarget(Int, Float)
  SchedulerNextTick(Float)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ElementEnteredViewport -> {
      let model = Model(..model, can_animate: True)
      let effect = after_paint()

      #(model, effect)
    }

    ElementExitedViewport -> {
      let model = Model(..model, can_animate: False)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetDuration(duration) -> {
      let model = Model(..model, duration: duration)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetFunction(function) -> {
      let model = Model(..model, function: function)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetTarget(to, start) if model.duration <. 1.0 -> {
      let to = int.to_float(to)
      let model =
        Model(..model, to:, value: to, start:, target: start, now: start)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetTarget(to, start) -> {
      let to = int.to_float(to)
      let model =
        Model(
          ..model,
          from: model.value,
          to: to,
          start: start,
          target: start +. model.duration,
          now: start,
        )

      let effect = case model.can_animate {
        True -> after_paint()
        False -> effect.none()
      }

      #(model, effect)
    }

    SchedulerNextTick(now) if model.start >. model.target -> {
      let model = Model(..model, now:)
      let effect = effect.none()

      #(model, effect)
    }

    SchedulerNextTick(now) -> {
      let t = { now -. model.start } /. { model.target -. model.start }
      let t = float.min(t, 1.0)
      let value = tween(t, model.from, model.to, model.function)

      let model = Model(..model, now: now, value: value)
      let effect = case t >=. 1.0 {
        True -> effect.none()
        False if model.can_animate -> after_paint()
        False -> effect.none()
      }

      #(model, effect)
    }
  }
}

fn after_paint() -> Effect(Msg) {
  use dispatch <- effect.from
  use timestamp <- do_after_paint

  dispatch(SchedulerNextTick(timestamp))
}

@external(javascript, "../../scheduler.ffi.mjs", "after_paint")
fn do_after_paint(k: fn(Float) -> Nil) -> Nil

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    //
    #("value", fn(value) {
      let now = animation_time()

      value
      |> dynamic.any([decipher.int_string, dynamic.int])
      |> result.map(ParentSetTarget(_, now))
    }),
    //
    #("duration", fn(duration) {
      duration
      |> dynamic.any([decipher.int_string, dynamic.int])
      |> result.map(int.to_float)
      |> result.map(ParentSetDuration)
    }),
    //
    #("easing-function", fn(function) {
      function
      |> dynamic.string
      |> result.then(fn(function) {
        case tween.from_string(function) {
          Ok(function) -> Ok(ParentSetFunction(function))
          Error(_) -> Error([])
        }
      })
    }),
  ])
}

@external(javascript, "../../dom.ffi.mjs", "animation_time")
fn animation_time() -> Float

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let target = float.round(model.target)
  let value = float.round(model.value)

  element(
    "lustre-ui-intersection-observer",
    [event.on("intersection", handle_intersection)],
    [
      value
      |> int.min(target)
      |> int.to_string
      |> html.text,
    ],
  )
}

fn handle_intersection(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use is_intersecting <- result.try(decipher.at(
    ["detail", "isIntersecting"],
    dynamic.bool,
  )(event))
  use ratio <- result.try(decipher.at(
    ["detail", "intersectionRatio"],
    dynamic.float,
  )(event))

  case is_intersecting {
    True if ratio >=. 0.8 -> Ok(ElementEnteredViewport)
    False -> Ok(ElementExitedViewport)
    _ -> Error([])
  }
}
