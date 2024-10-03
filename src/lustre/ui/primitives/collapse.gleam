// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/float
import gleam/int
import gleam/json
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event

//                                                                            //
// PUBLIC API ------------------------------------------------------------------
//                                                                            //

// ELEMENTS --------------------------------------------------------------------

// The name of the custom element as rendered in the DOM: "lustre-ui-collapse".
//
pub const name: String = "lustre-ui-collapse"

// Register the collapse component with the tag name "lustre-ui-collapse". You
// must do this before the component will properly render.
//
pub fn register() -> Result(Nil, lustre.Error) {
  let app = lustre.component(init, update, view, on_attribute_change())

  lustre.register(app, name)
}

//
// The `trigger` element should **not** contain interactive controls such as
// buttons or inputs.
//
// The size of the `content` element is measured whenever it changes (but not
// if its children change) and the collapse will adjust its height accordingly.
//
pub fn collapse(
  attributes: List(Attribute(msg)),
  trigger trigger: Element(msg),
  content content: Element(msg),
) -> Element(msg) {
  element(name, attributes, [
    html.div([attribute("slot", "trigger")], [trigger]),
    content,
  ])
}

// ATTRIBUTES ------------------------------------------------------------------

// Set whether the collapse component is expanded or not. This attribute _must_
// be set in order for the collapse component to change state. You can read more
// about this approach [here](#).
//
pub fn expanded(is_expanded: Bool) -> Attribute(msg) {
  attribute("aria-expanded", bool.to_string(is_expanded) |> string.lowercase)
}

// By default,
//
pub fn duration(ms: Int) -> Attribute(msg) {
  attribute.style([#("transition-duration", int.to_string(ms) <> "ms")])
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Bool) -> msg) -> Attribute(msg) {
  use event <- event.on("change")
  use is_expanded <- result.try(decipher.at(
    ["detail", "expanded"],
    dynamic.bool,
  )(event))

  Ok(handler(is_expanded))
}

pub fn on_expand(handler: msg) -> Attribute(msg) {
  use _ <- event.on("expand")

  Ok(handler)
}

pub fn on_collapse(handler: msg) -> Attribute(msg) {
  use _ <- event.on("collapse")

  Ok(handler)
}

//                                                                            --
// INTERNALS -------------------------------------------------------------------
//                                                                            --

// MODEL -----------------------------------------------------------------------

type Model {
  Model(height: Float, expanded: Bool)
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(height: 0.0, expanded: False)
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentChangedContent(Float)
  ParentSetExpanded(Bool)
  UserPressedTrigger(Float)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedContent(height) -> #(Model(..model, height:), effect.none())
    ParentSetExpanded(expanded) -> #(Model(..model, expanded:), effect.none())
    UserPressedTrigger(height) -> {
      let model = Model(..model, height:)

      let emit_change =
        event.emit(
          "change",
          json.object([#("expanded", json.bool(!model.expanded))]),
        )

      let emit_expand_collapse = case model.expanded {
        True -> event.emit("collapse", json.null())
        False -> event.emit("expand", json.null())
      }

      let effect = effect.batch([emit_change, emit_expand_collapse])

      #(model, effect)
    }
  }
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    //
    #("aria-expanded", fn(value) {
      value
      |> decipher.bool_string
      |> result.map(ParentSetExpanded)
    }),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let height = case model.expanded {
    True -> float.to_string(model.height) <> "px"
    False -> "0px"
  }

  element.fragment([view_trigger(), view_content(height)])
}

fn view_trigger() -> Element(Msg) {
  let outline = "focus:outline outline-1 outline-w-accent outline-offset-4"

  html.slot([
    attribute.class("block cursor-pointer rounded"),
    attribute.class(outline),
    attribute.name("trigger"),
    attribute("tabindex", "0"),
    event.on("click", handle_click),
    event.on("keydown", handle_keydown),
  ])
}

fn view_content(height: String) -> Element(Msg) {
  html.div(
    [
      attribute.class("transition-height overflow-y-hidden"),
      attribute.style([#("transition-duration", "inherit"), #("height", height)]),
    ],
    [html.slot([event.on("slotchange", handle_slot_change)])],
  )
}

// EVENT HANDLERS --------------------------------------------------------------

fn handle_click(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  let path = ["currentTarget", "nextElementSibling", "firstElementChild"]
  use slot <- result.try(decipher.at(path, dynamic)(event))
  use height <- result.try(calculate_slot_height(slot))

  Ok(UserPressedTrigger(height))
}

fn handle_keydown(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))

  case key {
    "Enter" | " " -> {
      let path = ["currentTarget", "nextElementSibling", "firstElementChild"]
      use slot <- result.try(decipher.at(path, dynamic)(event))
      use height <- result.try(calculate_slot_height(slot))

      Ok(UserPressedTrigger(height))
    }

    _ -> Error([])
  }
}

fn handle_slot_change(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use slot <- result.try(dynamic.field("target", dynamic)(event))
  use height <- result.try(calculate_slot_height(slot))

  Ok(ParentChangedContent(height))
}

fn calculate_slot_height(slot: Dynamic) -> Result(Float, List(DecodeError)) {
  use content <- result.try(assigned_elements(slot))
  use heights <- result.try(
    dynamic.list(dynamic.field("clientHeight", dynamic.float))(content),
  )

  Ok(float.sum(heights))
}

@external(javascript, "../../../dom.ffi.mjs", "assigned_elements")
fn assigned_elements(_slot: Dynamic) -> Result(Dynamic, List(DecodeError))
