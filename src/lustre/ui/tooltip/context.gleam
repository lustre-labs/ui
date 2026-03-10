import gleam/dynamic/decode
import gleam/json
import lustre/component
import lustre/effect.{type Effect}

pub type Context {
  Context(popover: String, open: Bool, delay: Int)
}

pub fn provide(popover: String, open: Bool, delay: Int) -> Effect(message) {
  effect.provide("tooltip", {
    json.object([
      #("popover", json.string(popover)),
      #("open", json.bool(open)),
      #("delay", json.int(delay)),
    ])
  })
}

pub fn on_change(handler: fn(Context) -> message) -> component.Option(message) {
  component.on_context_change("tooltip", {
    use popover <- decode.field("popover", decode.string)
    use open <- decode.field("open", decode.bool)
    use delay <- decode.field("delay", decode.int)

    decode.success(handler(Context(popover:, open:, delay:)))
  })
}
