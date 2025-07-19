// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/float
import gleam/int
import gleam/json
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ffi/dom

// ELEMENTS --------------------------------------------------------------------

// The name of the custom element as rendered in the DOM: "lustre-ui-collapse".
//
pub const name: String = "lustre-ui-collapse"

// Register the collapse component with the tag name "lustre-ui-collapse". You
// must do this before the component will properly render.
//
pub fn register() -> Result(Nil, lustre.Error) {
  let app =
    lustre.component(init, update, view, [
      component.adopt_styles(True),
      component.on_attribute_change("aria-expanded", fn(value) {
        case value {
          "true" -> Ok(ParentSetExpanded(True))
          "false" | "" -> Ok(ParentSetExpanded(False))
          _ -> Error(Nil)
        }
      }),
    ])

  lustre.register(app, name)
}

//
// The `trigger` element should **not** contain interactive controls such as
// buttons or inputs.
//
// The size of the `content` element is measured whenever it changes (but not
// if its children change) and the collapse will adjust its height accordingly.
//
pub fn element(
  attributes: List(Attribute(msg)),
  trigger trigger: Element(msg),
  content content: Element(msg),
) -> Element(msg) {
  element.element(name, attributes, [
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
  attribute.style("transition-duration", int.to_string(ms) <> "ms")
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Bool) -> msg) -> Attribute(msg) {
  event.on("change", {
    use expanded <- decode.subfield(["detail", "expanded"], decode.bool)

    decode.success(handler(expanded))
  })
}

pub fn on_expand(handler: msg) -> Attribute(msg) {
  event.on("expand", decode.success(handler))
}

pub fn on_collapse(handler: msg) -> Attribute(msg) {
  event.on("collapse", decode.success(handler))
}

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
  UserPressedTrigger(Float, event: Dynamic)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedContent(height) -> #(Model(..model, height:), effect.none())
    ParentSetExpanded(expanded) -> #(Model(..model, expanded:), effect.none())
    UserPressedTrigger(height, event) -> {
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

      let effect =
        effect.batch([
          emit_change,
          emit_expand_collapse,
          dom.prevent_default(event),
        ])

      #(model, effect)
    }
  }
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
  html.slot(
    [
      attribute("part", "collapse-trigger"),
      attribute.name("trigger"),
      event.on("click", handle_click()),
      event.on("keydown", handle_keydown()),
    ],
    [],
  )
}

fn view_content(height: String) -> Element(Msg) {
  html.div(
    [
      attribute("part", "collapse-content"),
      attribute.styles([
        #("transition-duration", "inherit"),
        #("height", height),
      ]),
    ],
    [html.slot([event.on("slotchange", handle_slot_change())], [])],
  )
}

// EVENT HANDLERS --------------------------------------------------------------

fn handle_click() -> Decoder(Msg) {
  use heights <- decode.subfield(
    ["currentTarget", "nextElementSibling", "firstElementChild"],
    dom.assigned_elements(
      dom.bounding_client_rect() |> decode.map(fn(rect) { rect.height }),
      lenient: False,
    ),
  )
  let height = float.sum(heights)

  decode.success(UserPressedTrigger(height, event: dynamic.nil()))
}

fn handle_keydown() -> Decoder(Msg) {
  use event <- decode.then(decode.dynamic)
  use key <- decode.field("key", decode.string)

  case key {
    "Enter" | " " -> {
      use heights <- decode.subfield(
        ["currentTarget", "nextElementSibling", "firstElementChild"],
        dom.assigned_elements(
          dom.bounding_client_rect()
            |> decode.map(fn(rect) { rect.height }),
          lenient: False,
        ),
      )
      let height = float.sum(heights)

      decode.success(UserPressedTrigger(height, event:))
    }

    _ -> decode.failure(UserPressedTrigger(0.0, event: dynamic.nil()), "")
  }
}

fn handle_slot_change() -> Decoder(Msg) {
  use heights <- decode.subfield(
    ["currentTarget", "nextElementSibling", "firstElementChild"],
    dom.assigned_elements(
      dom.bounding_client_rect() |> decode.map(fn(rect) { rect.height }),
      lenient: False,
    ),
  )
  let height = float.sum(heights)

  decode.success(ParentChangedContent(height))
}
