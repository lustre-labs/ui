// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/float
import gleam/json
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event

// COMPONENT API ---------------------------------------------------------------

pub const name: String = "lustre-ui-collapse"

pub fn register() -> Result(Nil, lustre.Error) {
  let app = lustre.component(init, update, view, on_attribute_change())

  lustre.register(app, name)
}

pub fn collapse(
  attributes: List(Attribute(msg)),
  trigger trigger: Element(msg),
  content content: Element(msg),
) -> Element(msg) {
  element(name, attributes, [
    html.div([attribute("slot", "trigger")], [trigger]),
    html.div([attribute("slot", "content")], [content]),
  ])
}

pub fn open(is_open: Bool) -> Attribute(msg) {
  attribute("aria-expanded", bool.to_string(is_open) |> string.lowercase)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(height: Float, open: Bool)
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(height: 0.0, open: False)
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentChangedContent(Float)
  ParentSetOpen(Bool)
  UserPressedTrigger(Float)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedContent(height) -> #(Model(..model, height:), effect.none())
    ParentSetOpen(open) -> #(Model(..model, open:), effect.none())
    UserPressedTrigger(height) -> {
      let open = !model.open
      let model = Model(height:, open:)
      let effect =
        effect.batch([
          event.emit("change", json.object([#("open", json.bool(open))])),
          case open {
            True -> event.emit("open", json.null())
            False -> event.emit("close", json.null())
          },
        ])

      #(model, effect)
    }
  }
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("aria-expanded", fn(value) {
      value
      |> dynamic.any([dynamic.bool, decipher.bool_string])
      |> result.map(ParentSetOpen)
    }),
    #("ariaExpanded", fn(value) {
      value
      |> dynamic.any([dynamic.bool, decipher.bool_string])
      |> result.map(ParentSetOpen)
    }),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let height = case model.open {
    True -> float.to_string(model.height) <> "px"
    False -> "0px"
  }

  element.fragment([
    html.slot([attribute.name("trigger"), event.on("click", handle_click)]),
    html.div(
      [
        attribute.class("transition-height overflow-y-hidden"),
        attribute.style([
          #("transition-duration", "inherit"),
          #("height", height),
        ]),
      ],
      [
        html.slot([
          attribute.name("content"),
          event.on("slotchange", handle_slot_change),
        ]),
      ],
    ),
  ])
}

fn handle_click(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  let path = ["currentTarget", "nextElementSibling", "firstElementChild"]
  use slot <- result.try(decipher.at(path, dynamic)(event))
  use content <- result.try(assigned_elements(slot))
  use height <- result.try(decipher.at(["0", "clientHeight"], dynamic.float)(
    content,
  ))

  Ok(UserPressedTrigger(height))
}

fn handle_slot_change(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use slot <- result.try(dynamic.field("target", dynamic)(event))
  use content <- result.try(assigned_elements(slot))
  use height <- result.try(decipher.at(["0", "clientHeight"], dynamic.float)(
    content,
  ))

  Ok(ParentChangedContent(height))
}

@external(javascript, "../../lustre_ui.ffi.mjs", "assigned_elements")
fn assigned_elements(_slot: Dynamic) -> Result(Dynamic, List(DecodeError)) {
  Error([])
}
