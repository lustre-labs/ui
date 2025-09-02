// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/list
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event.{type Handler}

// ELEMENTS --------------------------------------------------------------------

///
///
pub fn root(
  attributes attributes: List(Attribute(msg)),
  keymap keymap: List(#(String, Handler(msg))),
) -> Element(msg) {
  let handle_keydown = {
    use key <- decode.field("key", decode.string)

    case list.key_find(keymap, key) {
      Ok(handler) -> decode.success(handler)
      Error(_) ->
        decode.failure(
          event.handler(
            dispatch: unsafe_as_message(Nil),
            prevent_default: False,
            stop_propagation: False,
          ),
          "",
        )
    }
  }

  html.div(
    [
      attribute.id("keyboard-listener"),
      event.advanced("keydown", handle_keydown),
      // https://benmyers.dev/blog/native-visually-hidden/
      attribute.styles([
        #("border", "0"),
        #("clip", "rect(0 0 0 0)"),
        #("clip-path", "inset(50%)"),
        #("height", "1px"),
        #("margin", "-1px"),
        #("overflow", "hidden"),
        #("padding", "0"),
        #("position", "absolute"),
        #("white-space", "nowrap"),
        #("width", "1px"),
      ]),
      ..attributes
    ],
    [],
  )
}

@external(javascript, "../../../gleam_stdlib/gleam/function.mjs", "identity")
fn unsafe_as_message(_: Nil) -> msg
