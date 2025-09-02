// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json.{type Json}
import gleam/list
import gleam/result
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/event
import lustre/ui/menu_internal/context.{type MenuItem}
import lustre/ui/menu_internal/item
import lustre/ui_internal/dom
import lustre/ui_internal/host

// COMPONENT -------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    context.menu_item_group_tag,
  ))

  inject_id(context.menu_item_group_tag)

  Ok(Nil)
}

@external(javascript, "./group.ffi.mjs", "inject_id")
fn inject_id(name: String) -> Nil

// ELEMENTS --------------------------------------------------------------------

pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(context.menu_item_group_tag, attributes, children)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(String, List(String)) -> msg) -> Attribute(msg) {
  event.on("lustre-ui:menu-item-group-change", {
    use group <- decode.subfield(["target", "group-id"], decode.string)
    use items <- decode.subfield(
      ["detail", "items"],
      decode.list(decode.string),
    )

    decode.success(handler(group, items))
  })
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(id: String, items: List(MenuItem))
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(id: "", items: [])
  let effect = host.set_role("group")

  #(model, effect)
}

fn options() -> List(component.Option(Msg)) {
  []
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentChangedChildren(items: List(MenuItem))
  ParentChangedGroupChildren(id: String, items: List(String))
  ParentChangedItemValue(prev: String, next: String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedChildren(items:) -> {
      let model = Model(..model, items:)
      let effect = emit_change(items)

      #(model, effect)
    }

    ParentChangedGroupChildren(id: group_id, items:) -> {
      let items =
        list.map(model.items, fn(item) {
          case item {
            context.MenuItemGroup(..) if item.id == group_id ->
              context.MenuItemGroup(
                id: group_id,
                items: list.map(items, context.MenuItem),
              )
            context.MenuItem(..) | context.MenuItemGroup(..) -> item
          }
        })

      let model = Model(..model, items:)
      let effect = emit_change(items)

      #(model, effect)
    }

    ParentChangedItemValue(prev:, next:) -> {
      let items =
        list.filter_map(model.items, fn(item) {
          case item {
            context.MenuItem(value:) if value == prev ->
              case next {
                "" -> Error(Nil)
                value -> Ok(context.MenuItem(value:))
              }
            context.MenuItem(..) | context.MenuItemGroup(..) -> Ok(item)
          }
        })

      let model = Model(..model, items:)
      let effect = emit_change(items)

      #(model, effect)
    }
  }
}

fn emit_change(items: List(MenuItem)) -> Effect(msg) {
  event.emit(
    "lustre-ui:menu-item-group-change",
    json.object([
      #("items", json.preprocessed_array(items_to_json(items))),
    ]),
  )
}

// Nested groups are flattened into a single array of strings.
fn items_to_json(items: List(MenuItem)) -> List(Json) {
  use item <- list.flat_map(items)

  case item {
    context.MenuItem(value:) -> [json.string(value)]
    context.MenuItemGroup(items:, ..) -> items_to_json(items)
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Msg) {
  let handle_slotchange = {
    use slot <- decode.field("target", dom.element_decoder())
    use items <- decode.then(context.items_decoder(slot))

    decode.success(ParentChangedChildren(items:))
  }

  element.fragment([
    component.named_slot("label", [], []),
    component.default_slot(
      [
        event.on("slotchange", handle_slotchange),
        on_change(ParentChangedGroupChildren) |> event.stop_propagation,
        item.on_change(ParentChangedItemValue) |> event.stop_propagation,
      ],
      [],
    ),
  ])
}
