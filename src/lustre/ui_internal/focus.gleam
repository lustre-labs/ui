// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json
import lustre/attribute.{type Attribute}
import lustre/effect.{type Effect}
import lustre/event
import lustre/ui_internal/dom.{type HtmlElement}

// EVENTS ----------------------------------------------------------------------

pub fn on_request(handler: fn(HtmlElement) -> msg) -> Attribute(msg) {
  event.on("lustre-ui:focus-request", {
    decode.at(["target"], dom.element_decoder())
    |> decode.map(handler)
  })
  |> event.stop_propagation()
}

// EFFECTS ---------------------------------------------------------------------

pub fn request() -> Effect(msg) {
  event.emit("lustre-ui:focus-request", json.null())
}

pub fn apply(element: HtmlElement) -> Effect(msg) {
  use _ <- effect.from

  do_apply(element)
}

@external(javascript, "./focus.ffi.mjs", "apply")
fn do_apply(element: HtmlElement) -> Nil
