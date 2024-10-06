// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/data/bidict.{type Bidict}
import lustre/ui/icon
import lustre/ui/primitives/menu.{menu}

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-combobox"

pub fn register() -> Result(Nil, lustre.Error) {
  case menu.register() {
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app = lustre.component(init, update, view, on_attribute_change())
      lustre.register(app, name)
    }
    error -> error
  }
}

pub fn combobox(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(name, attributes, children)
}

pub fn option(value value: String, label label: String) -> Element(msg) {
  html.option([attribute.value(value)], label)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn value(value: String) -> Attribute(msg) {
  attribute.value(value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(String) -> msg) -> Attribute(msg) {
  use event <- event.on("change")
  use detail <- result.try(dynamic.field("detail", dynamic)(event))
  use value <- result.try(dynamic.field("value", dynamic.string)(detail))

  Ok(handler(value))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    expanded: Bool,
    value: String,
    query: String,
    intent: Option(String),
    intent_strategy: Strategy,
    options: Options,
  )
}

type Strategy {
  ByIndex
  ByLength
}

type Options {
  Options(
    all: List(#(String, String)),
    filtered: List(#(String, String)),
    lookup_label: Bidict(String, String),
    lookup_index: Bidict(String, Int),
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      expanded: False,
      value: "",
      query: "",
      intent: option.None,
      intent_strategy: ByIndex,
      options: Options(
        all: [],
        filtered: [],
        lookup_label: bidict.new(),
        lookup_index: bidict.new(),
      ),
    )
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentChangedChildren(List(#(String, String)))
  ParentSetStrategy(Strategy)
  ParentSetValue(String)
  UserChangedQuery(String)
  UserClosedMenu
  UserHoveredOption(String)
  UserOpenedMenu
  UserPressedDown
  UserPressedEnd
  UserPressedEnter
  UserPressedEscape
  UserPressedHome
  UserPressedUp
  UserSelectedOption(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedChildren(all) -> {
      let lookup_label = bidict.from_list(all)
      let lookup_index = bidict.indexed(list.map(all, pair.first))
      let filtered =
        list.filter(all, fn(option) {
          string.lowercase(option.0)
          |> string.contains(string.lowercase(model.query))
        })
      let options = Options(all:, filtered:, lookup_label:, lookup_index:)
      let intent = option.None
      let model = Model(..model, options:, intent:, options:)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetStrategy(strategy) -> #(
      Model(..model, intent_strategy: strategy),
      effect.none(),
    )

    ParentSetValue(value) -> {
      let model = Model(..model, value:, intent: option.Some(value))
      let effect = effect.none()

      #(model, effect)
    }

    UserChangedQuery(query) -> {
      let filtered =
        list.filter(model.options.all, fn(option) {
          string.lowercase(option.0)
          |> string.contains(string.lowercase(query))
        })
      let options = Options(..model.options, filtered:)
      let intent =
        intent_from_query(query, model.intent_strategy, model.options)
      let model = Model(..model, query:, intent:, options:)
      let effect = effect.none()

      #(model, effect)
    }

    UserClosedMenu -> #(
      Model(..model, expanded: False, intent: option.None),
      effect.none(),
    )

    UserHoveredOption(intent) -> #(
      Model(..model, intent: option.Some(intent)),
      effect.none(),
    )

    UserOpenedMenu -> #(Model(..model, expanded: True), effect.none())

    UserPressedDown -> {
      let intent = case model.intent {
        option.Some(intent) ->
          bidict.next(model.options.lookup_index, intent, int.add(_, 1))
          |> result.or(Ok(intent))
          |> option.from_result
        option.None ->
          bidict.min_inverse(model.options.lookup_index, int.compare)
          |> option.from_result
      }

      let model = Model(..model, intent:)
      let effect = effect.none()

      #(model, effect)
    }

    UserPressedEnd -> {
      let intent =
        model.options.lookup_index
        |> bidict.max_inverse(int.compare)
        |> option.from_result
      let model = Model(..model, intent:)
      let effect = effect.none()

      #(model, effect)
    }

    UserPressedEnter -> {
      let effect = case model.intent {
        option.Some(value) ->
          event.emit("change", json.object([#("value", json.string(value))]))
        option.None -> effect.none()
      }

      #(model, effect)
    }

    UserPressedEscape -> {
      let model = Model(..model, expanded: False, intent: option.None)
      let effect = effect.none()

      #(model, effect)
    }

    UserPressedHome -> {
      let intent =
        model.options.lookup_index
        |> bidict.min_inverse(int.compare)
        |> option.from_result
      let model = Model(..model, intent:)
      let effect = effect.none()

      #(model, effect)
    }

    UserPressedUp -> {
      let intent = case model.intent {
        option.Some(intent) ->
          bidict.next(model.options.lookup_index, intent, int.subtract(_, 1))
          |> result.or(Ok(intent))
          |> option.from_result
        option.None ->
          bidict.max_inverse(model.options.lookup_index, int.compare)
          |> option.from_result
      }

      let model = Model(..model, intent:)
      let effect = effect.none()

      #(model, effect)
    }

    UserSelectedOption(value) -> {
      let intent =
        value
        |> io.debug
        |> bidict.get(model.options.lookup_label, _)
        |> option.from_result
      let model = Model(..model, intent:)
      let effect =
        event.emit("change", json.object([#("value", json.string(value))]))

      #(model, effect)
    }
  }
}

fn intent_from_query(
  query: String,
  strategy: Strategy,
  options: Options,
) -> Option(String) {
  use <- bool.guard(query == "", option.None)
  let query = string.lowercase(query)
  let matches =
    list.filter(options.all, fn(option) {
      option.1 |> string.lowercase |> string.contains(query)
    })

  let sorted =
    list.sort(matches, fn(a, b) {
      let a_label = string.lowercase(a.1)
      let b_label = string.lowercase(b.1)

      let a_starts_with_query = string.starts_with(a_label, query)
      let b_starts_with_query = string.starts_with(b_label, query)

      let assert Ok(a_index) = bidict.get(options.lookup_index, a.0)
      let assert Ok(b_index) = bidict.get(options.lookup_index, b.0)

      let a_length = string.length(a_label)
      let b_length = string.length(b_label)

      case a_starts_with_query, b_starts_with_query, strategy {
        True, False, _ -> order.Lt
        False, True, _ -> order.Gt
        _, _, ByIndex -> int.compare(a_index, b_index)
        _, _, ByLength -> int.compare(a_length, b_length)
      }
    })

  sorted
  |> list.first
  |> result.map(pair.first)
  |> option.from_result
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("value", fn(value) {
      value
      |> dynamic.string
      |> result.map(ParentSetValue)
    }),
    #("strategy", fn(value) {
      case dynamic.string(value) {
        Ok("by-index") -> Ok(ParentSetStrategy(ByIndex))
        Ok("by-length") -> Ok(ParentSetStrategy(ByLength))
        _ -> Error([])
      }
    }),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.slot([event.on("slotchange", handle_slot_change)]),
    menu(
      [
        menu.open(model.expanded),
        menu.on_open(UserOpenedMenu),
        menu.on_close(UserClosedMenu),
        // Some browsers will not consider the custom events emit by the menu
        // component as user-generated events and so won't let us manually focus
        // the input in response.
        //
        // To handle those, we instead listen for explicit interaction events and
        // trigger the focus from them. These events will never produce a message.
        //
        event.on("click", handle_menu_click(_, !model.expanded)),
        event.on("keydown", handle_menu_keydown(_, !model.expanded)),
      ],
      trigger: view_trigger(model.value, model.expanded, model.options),
      content: html.div(
        [
          attribute.class("bg-w-bg border border-w-accent rounded-w-sm "),
          attribute.class("mt-w-xs p-w-xs space-y-w-xs"),
        ],
        [
          view_input(model.query),
          view_options(model.options, model.value, model.intent),
        ],
      ),
    ),
  ])
}

fn handle_slot_change(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use children <- result.try(dynamic.field("target", assigned_elements)(event))
  use options <- result.try(
    dynamic.list(fn(el) {
      dynamic.decode2(
        pair.new,
        get_attribute("value"),
        dynamic.field("textContent", dynamic.string),
      )(el)
    })(children),
  )

  options
  |> list.fold_right(#([], set.new()), fn(acc, option) {
    use <- bool.guard(set.contains(acc.1, option.0), acc)
    let seen = set.insert(acc.1, option.0)
    let options = [option, ..acc.0]

    #(options, seen)
  })
  |> pair.first
  |> ParentChangedChildren
  |> Ok
}

@external(javascript, "../../dom.ffi.mjs", "assigned_elements")
fn assigned_elements(_slot: Dynamic) -> Result(Dynamic, List(DecodeError))

@external(javascript, "../../dom.ffi.mjs", "get_attribute")
fn get_attribute(name: String) -> Decoder(String)

fn handle_menu_click(
  event: Dynamic,
  will_open: Bool,
) -> Result(Msg, List(DecodeError)) {
  use target <- result.try(dynamic.field("currentTarget", dynamic)(event))
  use input <- result.try(get_element("input")(target))

  case will_open {
    True -> after_paint(fn() { focus(input) })
    False -> Nil
  }

  Error([])
}

fn handle_menu_keydown(
  event: Dynamic,
  will_open: Bool,
) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))
  use target <- result.try(dynamic.field("currentTarget", dynamic)(event))
  use input <- result.try(get_element("input")(target))

  case key {
    "Enter" | " " if will_open -> after_paint(fn() { focus(input) })
    _ -> Nil
  }

  Error([])
}

@external(javascript, "../../dom.ffi.mjs", "get_element")
fn get_element(selector: String) -> Decoder(Dynamic)

@external(javascript, "../../dom.ffi.mjs", "focus")
fn focus(element: Dynamic) -> Nil

@external(javascript, "../../scheduler.ffi.mjs", "after_paint")
fn after_paint(k: fn() -> Nil) -> Nil

// VIEW TRIGGER ----------------------------------------------------------------

fn view_trigger(value: String, expanded: Bool, options: Options) -> Element(Msg) {
  let border = "border border-w-accent rounded-w-sm"
  let focus = "focus:outline outline-1 outline-w-primary-solid outline-offset-0"
  let text = case value {
    "" -> "text-w-text-subtle"
    _ -> ""
  }

  html.button(
    [
      attribute.class("group w-full flex items-center gap-w-xs p-w-sm"),
      attribute.class(text),
      attribute.class(border),
      attribute.class(focus),
    ],
    [
      html.span([attribute.class("flex-1 text-left")], [
        html.text(
          value
          |> bidict.get(options.lookup_label, _)
          |> result.unwrap("Select an option..."),
        ),
      ]),
      html.span(
        [
          attribute.class(
            "rounded-w-sm transition-colors group-hover:bg-w-tint-subtle",
          ),
        ],
        [
          icon.chevron_up([
            attribute.class("size-6 p-1"),
            attribute.class("transition-transform"),
            attribute.class(case expanded {
              True -> "transform rotate-180"
              False -> "transform rotate-0"
            }),
          ]),
        ],
      ),
    ],
  )
}

// VIEW INPUT ------------------------------------------------------------------

fn view_input(query: String) -> Element(Msg) {
  html.div(
    [
      attribute.class("relative flex items-center gap-w-xs"),
      attribute.class("-mx-w-xs -mt-w-xs"),
      attribute.class("border-b border-w-accent"),
    ],
    [
      icon.magnifying_glass([attribute.class("absolute left-2 size-4")]),
      html.input([
        attribute.class("w-full p-w-sm pl-8 bg-transparent rounded-t-sm"),
        attribute.class(
          "focus:outline outline-1 outline-w-primary-solid outline-offset-0",
        ),
        attribute.autocomplete("off"),
        event.on_input(UserChangedQuery),
        event.on("keydown", handle_input_keydown),
        attribute.value(query),
      ]),
    ],
  )
}

fn handle_input_keydown(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))

  case key {
    "ArrowDown" -> {
      event.prevent_default(event)
      Ok(UserPressedDown)
    }

    "ArrowEnd" -> {
      event.prevent_default(event)
      Ok(UserPressedEnd)
    }

    "Enter" -> {
      event.prevent_default(event)
      Ok(UserPressedEnter)
    }

    "Escape" -> {
      use root <- result.try(dynamic.field("target", get_root)(event))
      use trigger <- result.try(get_element("button")(root))

      after_paint(fn() { focus(trigger) })
      event.prevent_default(event)

      Ok(UserPressedEscape)
    }

    "Home" -> {
      event.prevent_default(event)
      Ok(UserPressedHome)
    }

    "ArrowUp" -> {
      event.prevent_default(event)
      Ok(UserPressedUp)
    }

    "Tab" -> {
      Ok(UserClosedMenu)
    }

    _ -> Error([])
  }
}

@external(javascript, "../../dom.ffi.mjs", "get_root")
fn get_root(element: Dynamic) -> Result(Dynamic, List(DecodeError))

// VIEW OPTIONS ----------------------------------------------------------------

fn view_options(
  options: Options,
  value: String,
  intent: Option(String),
) -> Element(Msg) {
  element.keyed(html.ul([attribute.class("space-y-w-  xs")], _), {
    use option <- list.map(options.filtered)
    let html = view_option(option, value, intent)

    #(option.0, html)
  })
}

fn view_option(
  option: #(String, String),
  value: String,
  intent: Option(String),
) -> Element(Msg) {
  let is_selected = option.0 == value
  let is_intent = option.Some(option.0) == intent
  let colours = case is_intent {
    True -> "bg-w-tint-subtle"
    False -> ""
  }

  html.li(
    [
      attribute.class("flex items-center gap-w-xs p-w-xs cursor-pointer"),
      attribute.class("rounded-w-sm"),
      attribute.class(colours),
      attribute.value(option.0),
      event.on_mouse_over(UserHoveredOption(option.0)),
      event.on_mouse_down(UserSelectedOption(option.0)),
    ],
    [
      case is_selected {
        True -> icon.check([attribute.class("size-4")])
        False -> html.span([attribute.class("size-4")], [])
      },
      html.span([attribute.class("flex-1")], [html.text(option.1)]),
    ],
  )
}
