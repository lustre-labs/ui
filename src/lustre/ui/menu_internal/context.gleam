// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None}
import lustre/component
import lustre/effect.{type Effect}
import lustre/ui_internal/dom.{type HtmlElement}

// CONSTANTS -------------------------------------------------------------------

const name: String = "lustre-ui:menu-context"

pub const menu_tag: String = "lustre-ui-menu"

pub const menu_item_tag: String = "lustre-ui-menu-item"

pub const menu_item_separator_tag: String = "lustre-ui-menu-separator-item"

pub const menu_item_group_tag: String = "lustre-ui-menu-item-group"

// TYPES -----------------------------------------------------------------------

///
///
pub type Context {
  Context(active: Option(String))
}

///
///
pub type MenuItem {
  MenuItem(value: String)
  MenuItemGroup(id: String, items: List(MenuItem))
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn new() -> Context {
  Context(active: None)
}

// OPTIONS ---------------------------------------------------------------------

///
///
pub fn on_change(handler: fn(Context) -> msg) -> component.Option(msg) {
  component.on_context_change(name, {
    use active <- decode.field("active", decode.optional(decode.string))
    decode.success(handler(Context(active:)))
  })
}

// EFFECTS ---------------------------------------------------------------------

///
///
pub fn provide(context: Context) -> Effect(msg) {
  effect.provide(name, {
    json.object([
      #("active", json.nullable(context.active, json.string)),
    ])
  })
}

// DECODERS --------------------------------------------------------------------

pub fn items_decoder(slot: HtmlElement) -> Decoder(List(MenuItem)) {
  use <- bool.guard(dom.tag(slot) != "slot", decode.failure([], ""))
  let elements = dom.assigned_elements(slot)

  use items <- decode.then(
    list.fold(elements, decode.success([]), fn(items, element) {
      case dom.tag(element) {
        tag if tag == menu_item_tag ->
          case dom.attribute(element, "value") {
            Ok("") | Error(_) -> items
            Ok(value) -> decode.map(items, list.prepend(_, MenuItem(value:)))
          }

        // Groups will dispatch their own change events containing the decoded
        // children, so for now we just need to know its id to handle that event
        // correctly.
        tag if tag == menu_item_group_tag ->
          case dom.property(element, "group-id", decode.string) {
            Ok("") | Error(_) -> items
            Ok(id) ->
              decode.map(items, list.prepend(_, MenuItemGroup(id:, items: [])))
          }

        _ -> items
      }
    }),
  )

  decode.success(list.reverse(items))
}
