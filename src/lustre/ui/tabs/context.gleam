// IMPORTS ---------------------------------------------------------------------

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/function
import gleam/json.{type Json}
import gleam/option.{None, Some}
import lustre/component
import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

pub type Context {
  Context(
    orientation: Orientation,
    active: option.Option(Tab),
    all: Dict(String, Tab),
  )
}

pub type Orientation {
  Horizontal
  Vertical
}

pub type Tab {
  Tab(name: String, trigger: String, panel: String)
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn new() -> Context {
  Context(orientation: Horizontal, active: None, all: dict.new())
}

// COMPONENT OPTIONS -----------------------------------------------------------

pub fn on_change(handler: fn(Context) -> message) -> component.Option(message) {
  component.on_context_change("tabs", {
    use orientation <- decode.field("orientation", {
      decode.then(decode.string, fn(value) {
        case value {
          "horizontal" -> decode.success(Horizontal)
          "vertical" -> decode.success(Vertical)
          _ -> decode.failure(Horizontal, "Orientation")
        }
      })
    })
    use active <- decode.field("active", decode.optional(tab_decoder()))
    use all <- decode.field("all", decode.dict(decode.string, tab_decoder()))

    decode.success(handler(Context(orientation, active:, all:)))
  })
}

fn tab_decoder() -> Decoder(Tab) {
  use name <- decode.field("name", decode.string)
  use trigger <- decode.field("trigger", decode.string)
  use panel <- decode.field("panel", decode.string)

  decode.success(Tab(name:, trigger:, panel:))
}

// EFFECTS ---------------------------------------------------------------------

pub fn provide(context: Context) -> Effect(message) {
  effect.provide("tabs", {
    json.object([
      #("orientation", orientation_to_json(context.orientation)),
      #("active", case context.active {
        Some(tab) -> tab_to_json(tab)
        None -> json.null()
      }),
      #("all", json.dict(context.all, function.identity, tab_to_json)),
    ])
  })
}

fn orientation_to_json(orientation: Orientation) -> Json {
  case orientation {
    Horizontal -> json.string("horizontal")
    Vertical -> json.string("vertical")
  }
}

fn tab_to_json(tab: Tab) -> Json {
  json.object([
    #("name", json.string(tab.name)),
    #("trigger", json.string(tab.trigger)),
    #("panel", json.string(tab.panel)),
  ])
}
