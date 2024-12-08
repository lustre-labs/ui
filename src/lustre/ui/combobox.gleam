// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/int
import gleam/json
import gleam/list
import gleam/option
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
import lustre/ui/input.{input}
import lustre/ui/primitives/icon
import lustre/ui/primitives/popover.{popover}

// TYPES -----------------------------------------------------------------------

pub opaque type Item {
  Item(value: String, label: String)
}

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-combobox"

pub fn register() -> Result(Nil, lustre.Error) {
  case popover.register() {
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app = lustre.component(init, update, view, on_attribute_change())
      lustre.register(app, name)
    }
    error -> error
  }
}

pub fn combobox(
  attributes: List(Attribute(msg)),
  children: List(Item),
) -> Element(msg) {
  element.keyed(element(name, attributes, _), {
    use item <- list.map(children)
    let el =
      element("lustre-ui-combobox-option", [attribute.value(item.value)], [
        html.text(item.label),
      ])

    #(item.value, el)
  })
}

pub fn option(value value: String, label label: String) -> Item {
  Item(value:, label:)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn value(value: String) -> Attribute(msg) {
  attribute.value(value)
}

pub fn placeholder(value: String) -> Attribute(msg) {
  attribute("placeholder", value)
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
    placeholder: String,
    query: String,
    intent: option.Option(String),
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
    all: List(Item),
    filtered: List(Item),
    lookup_label: Bidict(String, String),
    lookup_index: Bidict(String, Int),
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      expanded: False,
      value: "",
      placeholder: "Select an option...",
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
  let effect = effect.batch([set_state("empty")])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  DomBlurredTrigger
  DomFocusedTrigger
  ParentChangedChildren(List(Item))
  ParentSetPlaceholder(String)
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
    DomBlurredTrigger -> #(model, remove_state("trigger-focus"))

    DomFocusedTrigger -> #(model, set_state("trigger-focus"))

    ParentChangedChildren(all) -> {
      let lookup_label =
        bidict.from_list(list.map(all, fn(item) { #(item.value, item.label) }))
      let lookup_index = bidict.indexed(list.map(all, fn(item) { item.value }))
      let filtered =
        list.filter(all, fn(option) {
          string.lowercase(option.label)
          |> string.contains(string.lowercase(model.query))
        })
      let options = Options(all:, filtered:, lookup_label:, lookup_index:)
      let intent = option.None
      let model = Model(..model, options:, intent:)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetPlaceholder(placeholder) -> #(
      Model(..model, placeholder:),
      effect.none(),
    )

    ParentSetStrategy(strategy) -> #(
      Model(..model, intent_strategy: strategy),
      effect.none(),
    )

    ParentSetValue(value) -> {
      let model = Model(..model, value:, intent: option.Some(value))
      let effect = case value {
        "" -> set_state("empty")
        _ -> remove_state("empty")
      }

      #(model, effect)
    }

    UserChangedQuery(query) -> {
      let filtered =
        list.filter(model.options.all, fn(option) {
          string.lowercase(option.label)
          |> string.contains(string.lowercase(query))
        })
      let options = Options(..model.options, filtered:)
      let intent =
        intent_from_query(query, model.intent_strategy, model.options)
      let model = Model(..model, query:, intent:, options:)
      let effect = effect.none()

      #(model, effect)
    }

    UserClosedMenu -> {
      let model = Model(..model, expanded: False, intent: option.None)
      let effect = remove_state("expanded")

      #(model, effect)
    }

    UserHoveredOption(intent) -> #(
      Model(..model, intent: option.Some(intent)),
      effect.none(),
    )

    UserOpenedMenu -> {
      let model = Model(..model, expanded: True)
      let effect = set_state("expanded")

      #(model, effect)
    }

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
      let effect = remove_state("expanded")

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
) -> option.Option(String) {
  use <- bool.guard(query == "", option.None)
  let query = string.lowercase(query)
  let matches =
    list.filter(options.all, fn(option) {
      option.label |> string.lowercase |> string.contains(query)
    })

  let sorted =
    list.sort(matches, fn(a, b) {
      let a_label = string.lowercase(a.label)
      let b_label = string.lowercase(b.label)

      let a_starts_with_query = string.starts_with(a_label, query)
      let b_starts_with_query = string.starts_with(b_label, query)

      let assert Ok(a_index) = bidict.get(options.lookup_index, a.value)
      let assert Ok(b_index) = bidict.get(options.lookup_index, b.value)

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
  |> result.map(fn(option) { option.value })
  |> option.from_result
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("value", fn(value) {
      value
      |> dynamic.string
      |> result.map(ParentSetValue)
    }),
    #("placeholder", fn(value) {
      value
      |> dynamic.string
      |> result.map(ParentSetPlaceholder)
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

// EFFECTS ---------------------------------------------------------------------

fn set_state(value: String) -> Effect(msg) {
  use _, root <- element.get_root

  do_set_state(value, root)
}

@external(javascript, "../../dom.ffi.mjs", "set_state")
fn do_set_state(value: String, root: Dynamic) -> Nil

fn remove_state(value: String) -> Effect(msg) {
  use _, root <- element.get_root

  do_remove_state(value, root)
}

@external(javascript, "../../dom.ffi.mjs", "remove_state")
fn do_remove_state(value: String, root: Dynamic) -> Nil

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.slot([
      attribute.style([#("display", "none")]),
      event.on("slotchange", handle_slot_change),
    ]),
    popover(
      [
        popover.anchor(popover.BottomMiddle),
        popover.equal_width(),
        popover.gap("var(--padding-y)"),
        popover.on_close(UserClosedMenu),
        popover.on_open(UserOpenedMenu),
        popover.open(model.expanded),
        // Some browsers will not consider the custom events emit by the popover
        // component as user-generated events and so won't let us manually focus
        // the input in response.
        //
        // To handle those, we instead listen for explicit interaction events and
        // trigger the focus from them. These events will never produce a message.
        //
        event.on("click", handle_popover_click(_, !model.expanded)),
        event.on("keydown", handle_popover_keydown(_, !model.expanded)),
      ],
      trigger: view_trigger(model.value, model.placeholder, model.options),
      content: html.div([attribute("part", "combobox-options")], [
        view_input(model.query),
        view_options(model.options, model.value, model.intent),
      ]),
    ),
  ])
}

fn handle_slot_change(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use children <- result.try(dynamic.field("target", assigned_elements)(event))
  use options <- result.try(
    dynamic.list(fn(el) {
      dynamic.decode3(
        fn(tag, value, label) { #(tag, value, label) },
        dynamic.field("tagName", dynamic.string),
        get_attribute("value"),
        dynamic.field("textContent", dynamic.string),
      )(el)
    })(children),
  )

  options
  |> list.fold_right(#([], set.new()), fn(acc, option) {
    let #(tag, value, label) = option

    use <- bool.guard(tag != "LUSTRE-UI-COMBOBOX-OPTION", acc)
    use <- bool.guard(set.contains(acc.1, value), acc)
    let seen = set.insert(acc.1, value)
    let options = [Item(value:, label:), ..acc.0]

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

fn handle_popover_click(
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

fn handle_popover_keydown(
  event: Dynamic,
  will_open: Bool,
) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))
  use target <- result.try(dynamic.field("currentTarget", dynamic)(event))
  use input <- result.try(get_element("input")(target))

  case key {
    "Enter" | " " if will_open -> {
      after_paint(fn() { focus(input) })
      Error([])
    }
    _ -> Error([])
  }
}

@external(javascript, "../../dom.ffi.mjs", "get_element")
fn get_element(selector: String) -> Decoder(Dynamic)

@external(javascript, "../../dom.ffi.mjs", "focus")
fn focus(element: Dynamic) -> Nil

@external(javascript, "../../scheduler.ffi.mjs", "after_paint")
fn after_paint(k: fn() -> Nil) -> Nil

// VIEW TRIGGER ----------------------------------------------------------------

fn view_trigger(
  value: String,
  placeholder: String,
  options: Options,
) -> Element(Msg) {
  let label =
    value
    |> bidict.get(options.lookup_label, _)
    |> result.unwrap(placeholder)

  html.button(
    [
      attribute("part", "combobox-trigger"),
      attribute("tabindex", "0"),
      event.on_focus(DomFocusedTrigger),
      event.on_blur(DomBlurredTrigger),
    ],
    [
      html.span(
        [
          attribute("part", "combobox-trigger-label"),
          attribute.class(case label {
            "" -> "empty"
            _ -> ""
          }),
        ],
        [html.text(label)],
      ),
      icon.chevron_down([attribute("part", "combobox-trigger-icon")]),
    ],
  )
}

// VIEW INPUT ------------------------------------------------------------------

fn view_input(query: String) -> Element(Msg) {
  input.container([attribute("part", "combobox-input")], [
    icon.magnifying_glass([]),
    input([
      attribute.style([
        #("width", "100%"),
        #("border-bottom-left-radius", "0px"),
        #("border-bottom-right-radius", "0px"),
      ]),
      attribute.autocomplete("off"),
      event.on_input(UserChangedQuery),
      event.on("keydown", handle_input_keydown),
      attribute.value(query),
    ]),
  ])
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
  intent: option.Option(String),
) -> Element(Msg) {
  element.keyed(
    html.ul([], _),
    do_view_options(options.filtered, value, intent),
  )
}

fn do_view_options(
  options: List(Item),
  value: String,
  intent: option.Option(String),
) -> List(#(String, Element(Msg))) {
  case options {
    [] -> []
    [option] -> [#(option.value, view_option(option, value, intent, True))]
    [option, ..rest] -> [
      #(option.label, view_option(option, value, intent, False)),
      ..do_view_options(rest, value, intent)
    ]
  }
}

fn view_option(
  option: Item,
  value: String,
  intent: option.Option(String),
  last: Bool,
) -> Element(Msg) {
  let is_selected = option.value == value
  let is_intent = option.Some(option.value) == intent

  let icon = case is_selected {
    True -> icon.check(_)
    False -> html.span(_, [])
  }

  let parts = [
    "combobox-option",
    case is_intent {
      True -> "intent"
      False -> ""
    },
    case last {
      True -> "last"
      False -> ""
    },
  ]

  html.li(
    [
      attribute("part", string.join(parts, " ")),
      attribute("value", option.value),
      event.on_mouse_over(UserHoveredOption(option.value)),
      event.on_mouse_down(UserSelectedOption(option.value)),
    ],
    [
      icon([attribute.style([#("height", "1rem"), #("width", "1rem")])]),
      html.span([attribute.style([#("flex", "1 1 0%")])], [
        element("slot", [attribute.name("option-" <> option.value)], [
          html.text(option.label),
        ]),
      ]),
    ],
  )
}
