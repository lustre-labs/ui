// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json
import lustre/component
import lustre/effect.{type Effect}

// CONSTANTS -------------------------------------------------------------------

const name: String = "lustre-ui:checkbox-context"

pub const checkbox_tag: String = "lustre-ui-checkbox"

pub const checkbox_indicator_tag: String = "lustre-ui-checkbox-indicator"

// TYPES -----------------------------------------------------------------------

///
///
pub type Context {
  Context(checked: Checked)
}

///
///
pub type Checked {
  On
  Indeterminate
  Off
}

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn new(checked: Checked) -> Context {
  Context(checked:)
}

// OPTIONS ---------------------------------------------------------------------

///
///
pub fn on_change(handler: fn(Context) -> msg) -> component.Option(msg) {
  component.on_context_change(name, {
    use checked <- decode.field("checked", {
      decode.then(decode.string, fn(checked) {
        case checked {
          "on" -> decode.success(On)
          "indeterminate" -> decode.success(Indeterminate)
          "off" -> decode.success(Off)
          _ -> decode.failure(On, "")
        }
      })
    })

    decode.success(handler(Context(checked:)))
  })
}

// EFFECTS ---------------------------------------------------------------------

///
///
pub fn provide(context: Context) -> Effect(msg) {
  effect.provide(name, {
    json.object([
      #("checked", {
        json.string(case context.checked {
          On -> "on"
          Indeterminate -> "indeterminate"
          Off -> "off"
        })
      }),
    ])
  })
}
