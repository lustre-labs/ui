// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/menu_internal/context.{
  type Context, type MenuItem, Context, MenuItem, MenuItemGroup,
}
import lustre/ui/menu_internal/group
import lustre/ui/menu_internal/item
import lustre/ui/menu_internal/separator
import lustre/ui_internal/dom
import lustre/ui_internal/host

// COMPONENT -------------------------------------------------------------------

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(item.register())
  use _ <- result.try(group.register())
  use _ <- result.try(separator.register())
  use _ <- result.try(lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    context.menu_tag,
  ))

  Ok(Nil)
}

// ELEMENTS --------------------------------------------------------------------

///
///
pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(context.menu_tag, attributes, children)
}

///
///
pub fn item(
  value: String,
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  case string.trim(value) {
    "" -> element.none()
    value -> item.root([item.value(value), ..attributes], children)
  }
}

///
///
pub fn checkbox(
  value: String,
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  case string.trim(value) {
    "" -> element.none()
    value ->
      item.root([item.value(value), item.checkbox(), ..attributes], children)
  }
}

///
///
pub fn group(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  group.root(attributes, children)
}

///
///
pub fn group_label(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.p([component.slot("label"), ..attributes], children)
}

///
///
pub fn separator(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  separator.root(attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn label(value: String) -> Attribute(msg) {
  attribute.aria_label(value)
}

///
///
pub fn default_checked(value: Bool) -> Attribute(msg) {
  case value {
    True -> item.default_checked()
    False -> attribute.none()
  }
}

///
///
pub fn checked(value: Bool) -> Attribute(msg) {
  item.checked(value)
}

// EVENTS ----------------------------------------------------------------------

///
///
pub fn on_select(handler: fn(String) -> msg) -> Attribute(msg) {
  item.on_select(handler)
}

///
///
pub fn on_toggle(handler: fn(String, Bool) -> msg) -> Attribute(msg) {
  item.on_toggle(handler)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(context: Context, items: List(MenuItem))
}

fn init(_) -> #(Model, Effect(Msg)) {
  let context = context.new()
  let model = Model(context:, items: [])
  let effect = effect.batch([context.provide(context), host.set_role("menu")])

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
  UserHoveredItem(value: String)
  UserPressedDown
  UserPressedEnd
  UserPressedHome
  UserPressedUp
  UserRemovedFocus
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedChildren(items:) -> {
      let active = retain_active(model.context.active, in: items)
      let context = Context(active:)
      let model = Model(..model, items:)
      let effect = context.provide(context)

      #(model, effect)
    }

    ParentChangedGroupChildren(id:, items:) -> {
      let items =
        list.map(model.items, fn(item) {
          case item {
            context.MenuItemGroup(..) if item.id == id ->
              context.MenuItemGroup(
                id: id,
                items: list.map(items, context.MenuItem),
              )
            context.MenuItem(..) | context.MenuItemGroup(..) -> item
          }
        })
      let active = retain_active(model.context.active, in: items)
      let context = Context(active:)
      let model = Model(..model, items:)
      let effect = context.provide(context)

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
      let active = retain_active(model.context.active, in: items)
      let context = Context(active:)
      let model = Model(..model, items:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserHoveredItem(value:) -> {
      let context = Context(active: Some(value))
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserPressedDown -> {
      let active = case model.context.active {
        Some(active) ->
          case find_siblings(active, in: model.items) {
            Ok(#(_, _, Some(next))) -> Some(next)
            Ok(#(_, next, _)) -> Some(next)
            Error(_) -> find_first(model.items)
          }
        None -> find_first(model.items)
      }

      let context = Context(active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserPressedHome -> {
      let active = find_first(model.items)
      let context = Context(active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserPressedEnd -> {
      let active = find_last(model.items)
      let context = Context(active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserPressedUp -> {
      let active = case model.context.active {
        Some(active) ->
          case find_siblings(active, in: model.items) {
            Ok(#(Some(prev), _, _)) -> Some(prev)
            Ok(#(_, prev, _)) -> Some(prev)
            Error(_) -> find_last(model.items)
          }
        None -> find_last(model.items)
      }
      let context = Context(active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserRemovedFocus -> {
      let context = Context(active: None)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }
  }
}

// HELPERS ---------------------------------------------------------------------

fn retain_active(
  current: Option(String),
  in items: List(MenuItem),
) -> Option(String) {
  option.then(current, fn(active) {
    case contains_active(active, in: items) {
      True -> Some(active)
      False -> find_first(items)
    }
  })
}

fn contains_active(current: String, in items: List(MenuItem)) -> Bool {
  list.any(items, fn(item) {
    case item {
      MenuItem(value:) if value == current -> True
      MenuItem(..) -> False
      MenuItemGroup(items:, ..) -> contains_active(current, in: items)
    }
  })
}

//

fn find_first(items: List(MenuItem)) -> Option(String) {
  case items {
    [MenuItem(value:), ..] -> Some(value)
    [MenuItemGroup(items:, ..), ..] -> find_first(items)
    [] -> None
  }
}

fn find_siblings(
  active: String,
  in items: List(MenuItem),
) -> Result(#(Option(String), String, Option(String)), Nil) {
  flatten_items(items) |> do_find_siblings(active, _)
}

fn do_find_siblings(
  active: String,
  in items: List(String),
) -> Result(#(Option(String), String, Option(String)), Nil) {
  case items {
    [a, b, c, ..] if b == active -> Ok(#(Some(a), b, Some(c)))
    [a, b, ..] if a == active -> Ok(#(None, a, Some(b)))
    [a, b] if b == active -> Ok(#(Some(a), b, None))
    [a] if a == active -> Ok(#(None, a, None))
    [_, ..rest] -> do_find_siblings(active, rest)
    [] -> Error(Nil)
  }
}

fn flatten_items(items: List(MenuItem)) -> List(String) {
  list.flat_map(items, fn(item) {
    case item {
      MenuItem(value:) -> [value]
      MenuItemGroup(items:, ..) -> flatten_items(items)
    }
  })
}

fn find_last(items: List(MenuItem)) -> Option(String) {
  case list.reverse(items) {
    [MenuItem(value:), ..] -> Some(value)
    [MenuItemGroup(items:, ..), ..] -> find_last(items)
    [] -> None
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Msg) {
  let handle_slotchange = {
    use slot <- decode.field("target", dom.element_decoder())
    use items <- decode.then(context.items_decoder(slot))

    decode.success(ParentChangedChildren(items:))
  }

  let handle_keydown = {
    use key <- decode.field("key", decode.string)

    case key {
      "ArrowDown" -> decode.success(event.handler(UserPressedDown, True, False))
      "ArrowUp" -> decode.success(event.handler(UserPressedUp, True, False))
      "End" -> decode.success(event.handler(UserPressedEnd, True, False))
      "Home" -> decode.success(event.handler(UserPressedHome, True, False))
      _ -> decode.failure(event.handler(UserPressedUp, False, False), "")
    }
  }

  let handle_mousemove = {
    use target <- decode.field("target", dom.element_decoder())

    case dom.attribute(target, "value") {
      Ok("") | Error(_) -> decode.failure(UserHoveredItem(value: ""), "")
      Ok(value) -> decode.success(UserHoveredItem(value:))
    }
  }

  let handle_focus = {
    use target <- decode.field("target", dom.element_decoder())

    case dom.attribute(target, "value") {
      Ok("") | Error(_) -> decode.failure(UserHoveredItem(value: ""), "")
      Ok(value) -> decode.success(UserHoveredItem(value:))
    }
  }

  let handle_blur = {
    use related_target <- decode.field(
      "relatedTarget",
      decode.optional(dom.element_decoder()),
    )

    case option.map(related_target, dom.tag) {
      Some(tag) if tag == context.menu_item_tag ->
        decode.failure(UserRemovedFocus, "")
      Some(_) | None -> decode.success(UserRemovedFocus)
    }
  }

  element.fragment([
    html.style([], {
      "
      :host {
        display: block;
      }
      "
    }),

    component.default_slot([], []),

    component.named_slot(
      "content",
      [
        event.on("slotchange", handle_slotchange),
        event.on("focusin", handle_focus),
        event.on("focusout", handle_blur),
        event.on("mousemove", handle_mousemove),
        event.advanced("keydown", handle_keydown),
        item.on_change(ParentChangedItemValue) |> event.stop_propagation,
        group.on_change(ParentChangedGroupChildren) |> event.stop_propagation,
      ],
      [],
    ),
  ])
}
