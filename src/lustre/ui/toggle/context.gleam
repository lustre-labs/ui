// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import lustre/effect.{type Effect}

// TYPES -----------------------------------------------------------------------

pub type GroupContext {
  GroupContext(value: Option(String), disabled: Bool)
}

// CONSTANTS -------------------------------------------------------------------

pub const group = "toggle/group"

// COMPONENT OPTIONS -----------------------------------------------------------

pub fn on_group_change(
  handler: fn(GroupContext) -> message,
) -> Effect(message) {
  effect.subscribe(group, {
    use value <- decode.field("value", decode.optional(decode.string))
    use disabled <- decode.field("disabled", decode.bool)

    decode.success(handler(GroupContext(value:, disabled:)))
  })
}

// EFFECTS ---------------------------------------------------------------------

pub fn provide_group(
  value value: Option(String),
  disabled disabled: Bool,
) -> Effect(message) {
  effect.provide(group, {
    json.object([
      #("value", case value {
        Some(v) -> json.string(v)
        None -> json.null()
      }),
      #("disabled", json.bool(disabled)),
    ])
  })
}
