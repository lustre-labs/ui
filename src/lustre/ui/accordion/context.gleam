// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json
import gleam/set.{type Set}
import lustre/component
import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

pub type Context {
  Context(open: Set(String))
}

pub type ItemContext {
  ItemContext(name: String, panel: String, open: Bool)
}

// COMPONENT OPTIONS -----------------------------------------------------------

pub fn on_change(handler: fn(Context) -> message) -> component.Option(message) {
  component.on_context_change("accordion", {
    use open <- decode.field("open", {
      decode.list(decode.string) |> decode.map(set.from_list)
    })

    decode.success(handler(Context(open:)))
  })
}

pub fn on_item_change(
  handler: fn(ItemContext) -> message,
) -> component.Option(message) {
  component.on_context_change("accordion/item", {
    use name <- decode.field("name", decode.string)
    use panel <- decode.field("panel", decode.string)
    use open <- decode.field("open", decode.bool)

    decode.success(handler(ItemContext(name:, panel:, open:)))
  })
}

// EFFECTS ---------------------------------------------------------------------

pub fn provide(open open: Set(String)) -> Effect(message) {
  effect.provide("accordion", {
    json.object([
      #("open", open |> set.to_list |> json.array(json.string)),
    ])
  })
}

pub fn provide_item(
  name name: String,
  panel panel: String,
  open open: Bool,
) -> Effect(message) {
  effect.provide("accordion/item", {
    json.object([
      #("name", json.string(name)),
      #("panel", json.string(panel)),
      #("open", json.bool(open)),
    ])
  })
}
