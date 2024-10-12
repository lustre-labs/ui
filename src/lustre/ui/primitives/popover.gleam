// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic}
import gleam/json
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event

// PUBLIC API ------------------------------------------------------------------

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-popover"

pub fn register() -> Result(Nil, lustre.Error) {
  let app = lustre.component(init, update, view, on_attribute_change())

  lustre.register(app, name)
}

pub fn popover(
  attributes: List(Attribute(msg)),
  trigger trigger: Element(msg),
  content content: Element(msg),
) -> Element(msg) {
  element(name, attributes, [
    html.div([attribute("slot", "trigger")], [trigger]),
    html.div([attribute("slot", "popover")], [content]),
  ])
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn open(is_open: Bool) -> Attribute(msg) {
  attribute("aria-expanded", bool.to_string(is_open) |> string.lowercase)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Bool) -> msg) -> Attribute(msg) {
  use event <- event.on("change")
  use is_open <- result.try(decipher.at(["detail", "open"], dynamic.bool)(event))

  Ok(handler(is_open))
}

pub fn on_open(handler: msg) -> Attribute(msg) {
  use _ <- event.on("open")

  Ok(handler)
}

pub fn on_close(handler: msg) -> Attribute(msg) {
  use _ <- event.on("close")

  Ok(handler)
}

// INTERNALS -------------------------------------------------------------------

// MODEL -----------------------------------------------------------------------

type Model {
  WillExpand
  Expanded
  WillCollapse
  Collapsing
  Collapsed
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Collapsed
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentSetOpen(Bool)
  SchedulerDidTick
  TransitionDidEnd
  UserPressedTrigger
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg, model {
    ParentSetOpen(True), WillCollapse | ParentSetOpen(True), Collapsed -> #(
      WillExpand,
      tick(),
    )
    ParentSetOpen(True), _ -> #(model, effect.none())
    ParentSetOpen(False), WillExpand | ParentSetOpen(False), Expanded -> #(
      WillCollapse,
      tick(),
    )
    ParentSetOpen(False), _ -> #(model, effect.none())
    SchedulerDidTick, WillExpand -> #(Expanded, effect.none())
    SchedulerDidTick, WillCollapse -> #(Collapsing, effect.none())
    SchedulerDidTick, _ -> #(model, effect.none())
    TransitionDidEnd, Collapsing -> #(Collapsed, effect.none())
    TransitionDidEnd, _ -> #(model, effect.none())
    UserPressedTrigger, WillExpand | UserPressedTrigger, Expanded -> #(
      WillCollapse,
      effect.batch([
        tick(),
        event.emit("close", json.null()),
        event.emit("change", json.object([#("open", json.bool(False))])),
      ]),
    )
    UserPressedTrigger, WillCollapse
    | UserPressedTrigger, Collapsing
    | UserPressedTrigger, Collapsed
    -> #(
      WillExpand,
      effect.batch([
        tick(),
        event.emit("open", json.null()),
        event.emit("change", json.object([#("open", json.bool(True))])),
      ]),
    )
  }
}

fn tick() -> Effect(Msg) {
  use dispatch <- effect.from
  use <- after_paint

  dispatch(SchedulerDidTick)
}

@external(javascript, "../../../scheduler.ffi.mjs", "after_paint")
fn after_paint(k: fn() -> Nil) -> Nil

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("aria-expanded", fn(value) {
      value
      |> decipher.bool_string
      |> result.map(ParentSetOpen)
    }),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.class("relative")], [view_trigger(), view_popover(model)])
}

fn view_trigger() -> Element(Msg) {
  html.slot([
    attribute.class("block cursor-pointer"),
    attribute.name("trigger"),
    attribute("tabindex", "0"),
    event.on_click(UserPressedTrigger),
    event.on("keydown", handle_keydown),
  ])
}

fn handle_keydown(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))

  case key {
    "Enter" | " " -> Ok(UserPressedTrigger)
    _ -> Error([])
  }
}

fn view_popover(model: Model) -> Element(Msg) {
  use <- bool.guard(model == Collapsed, html.text(""))

  html.div(
    [
      event.on("transitionend", handle_transitionend),
      attribute.class("absolute left-0 right-0 transition"),
      attribute.class(case model {
        WillExpand -> "block opacity-0 -translate-y-4"
        Expanded -> "block opacity-100 translate-y-0"
        WillCollapse -> "block opacity-100 translate-y-0"
        Collapsing -> "block opacity-0 -translate-y-4"
        Collapsed -> "hidden"
      }),
    ],
    [html.slot([attribute.name("popover")])],
  )
}

fn handle_transitionend(_: Dynamic) -> Result(Msg, List(DecodeError)) {
  Ok(TransitionDidEnd)
}
