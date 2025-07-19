//// The [`combobox`](#element) element combines a textbox with a drop-down list.
//// This allows users to select a value from a predefined list of options, or
//// optionally enter a custom value by typing.
////
//// Common uses for comboboxes include:
////
//// - Selecting from a filtered list of items like countries or currencies
////
//// - Entering common text values with typeahead like calendar input fields
////
//// ## Anatomy
////
//// <image src="/assets/diagram-combobox.svg" alt="" width="100%">
////
//// A combobox is made up of different parts:
////
//// - The main [`element`](#element) container used to control the combobox's
////   styles and layout. (**required**)
////
//// - The [`trigger`](#element) button used to open and close the combobox menu.
////   (**required**)
////
//// - An input control used to filter the available options. (**required**)
////
//// - A list of [`option`](#option) elements representing the available choices.
////   (**required**)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `combobox` element.
////
//// ### A basic combobox with text options:
////
//// ```gleam
//// import lustre/ui/combobox
////
//// pub fn fruit_picker() {
////   combobox.element([], [
////     combobox.option(value: "apple", label: "Apple"),
////     combobox.option(value: "banana", label: "Banana"),
////     combobox.option(value: "orange", label: "Orange"),
////   ])
//// }
//// ```
////
//// ### A combobox with typeahead filtering:
////
//// ```gleam
//// import lustre/ui/combobox
////
//// pub fn language_picker() {
////   combobox.element([], [
////     combobox.option(value: "gleam", label: "Gleam"),
////     combobox.option(value: "go", label: "Go"),
////     combobox.option(value: "javascript", label: "JavaScript"),
////     combobox.option(value: "kotlin", label: "Kotlin"),
////     combobox.option(value: "rust", label: "Rust"),
////     combobox.option(value: "typescript", label: "TypeScript"),
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// It is possible to control some aspects of a combobox's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `combobox` element to match
//// elements outside of this package.
////
//// ## Accessibility
////
//// Comboboxes created with this element have a robust set of keyboard commands:
////
//// - <kbd>ArrowDown</kbd> will focus the next option in the menu
//// - <kbd>ArrowUp</kbd> will focus the previous option in the menu
//// - <kbd>End</kbd> will focus the last option in the menu
//// - <kbd>Enter</kbd> will open/close the menu and select the focused option
//// - <kbd>Escape</kbd> will close the menu
//// - <kbd>Home</kbd> will focus the first option in the menu
//// - <kbd>Space</kbd> will open/close the menu
//// - <kbd>Tab</kbd> will close the menu and focus the next focusable element
////

// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
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
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/keyed
import lustre/event
import lustre/ffi/dom
import lustre/ui/data/bidict.{type Bidict}
import lustre/ui/input
import lustre/ui/primitives/icon
import lustre/ui/primitives/popover

// TYPES -----------------------------------------------------------------------

pub opaque type Item(msg) {
  Item(value: String, label: String, content: List(Element(msg)))
}

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-combobox"

pub fn register() -> Result(Nil, lustre.Error) {
  case popover.register() {
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app =
        lustre.component(init, update, view, [
          component.adopt_styles(False),
          component.on_attribute_change("value", fn(value) {
            Ok(ParentSetValue(value))
          }),
          component.on_attribute_change("placeholder", fn(value) {
            Ok(ParentSetPlaceholder(value))
          }),
          component.on_attribute_change("strategy", fn(value) {
            case value {
              "by-length" -> Ok(ParentSetStrategy(ByLength))
              "by-index" -> Ok(ParentSetStrategy(ByIndex))
              _ -> Error(Nil)
            }
          }),
        ])

      lustre.register(app, name)
    }
    error -> error
  }
}

pub fn element(
  attributes: List(Attribute(msg)),
  children: List(Item(msg)),
) -> Element(msg) {
  keyed.element(name, attributes, {
    use item <- list.flat_map(children)
    let option =
      element.element(
        "lustre-ui-combobox-option",
        [attribute.value(item.value)],
        [html.text(item.label)],
      )

    use <- bool.guard(list.is_empty(item.content), [#(item.value, option)])

    [
      #(item.value, option),
      #(
        "option-" <> item.value,
        html.div([attribute("slot", "option-" <> item.value)], item.content),
      ),
    ]
  })
}

pub fn option(value value: String, label label: String) -> Item(msg) {
  Item(value:, label:, content: [])
}

pub fn custom(
  value value: String,
  label label: String,
  content content: List(Element(msg)),
) {
  Item(value:, label:, content:)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn value(value: String) -> Attribute(msg) {
  attribute.value(value)
}

pub fn placeholder(value: String) -> Attribute(msg) {
  attribute("placeholder", value)
}

// VARIABLES -------------------------------------------------------------------

///
/// <!-- @css-variable -->
///
pub fn padding(x x: String, y y: String) -> Attribute(msg) {
  attribute.styles([#("--padding-x", x), #("--padding-y", y)])
}

///
/// <!-- @css-variable -->
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style("--padding-x", value)
}

///
/// <!-- @css-variable -->
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style("--padding-y", value)
}

///
/// <!-- @css-variable -->
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style("--border-width", value)
}

///
/// <!-- @css-variable -->
///
pub fn radius(value: String) -> Attribute(msg) {
  attribute.style("--radius", value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on("change", {
    use value <- decode.subfield(["detail", "value"], decode.string)

    decode.success(handler(value))
  })
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
    all: List(Item(Nil)),
    filtered: List(Item(Nil)),
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
  let effect = effect.batch([component.set_pseudo_state("empty")])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  DomBlurredTrigger
  DomFocusedTrigger
  ParentChangedChildren(List(Item(Nil)))
  ParentSetPlaceholder(String)
  ParentSetStrategy(Strategy)
  ParentSetValue(String)
  UserActivatedPopoverTrigger(input: Dynamic)
  UserChangedQuery(String)
  UserClosedMenu
  UserHoveredOption(String)
  UserOpenedMenu
  UserPressedDown(event: Dynamic)
  UserPressedEnd(event: Dynamic)
  UserPressedEnter(event: Dynamic)
  UserPressedEscape(event: Dynamic, trigger: Dynamic)
  UserPressedHome(event: Dynamic)
  UserPressedUp(event: Dynamic)
  UserSelectedOption(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case echo msg {
    DomBlurredTrigger -> #(
      model,
      component.remove_pseudo_state("trigger-focus"),
    )
    DomFocusedTrigger -> #(model, component.set_pseudo_state("trigger-focus"))

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
        "" -> component.set_pseudo_state("empty")
        _ -> component.remove_pseudo_state("empty")
      }

      #(model, effect)
    }

    UserActivatedPopoverTrigger(input:) -> {
      let effect = {
        use _, _ <- effect.after_paint
        dom.do_focus(input)
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
      let effect = component.remove_pseudo_state("expanded")

      #(model, effect)
    }

    UserHoveredOption(intent) -> #(
      Model(..model, intent: option.Some(intent)),
      effect.none(),
    )

    UserOpenedMenu -> {
      let model = Model(..model, expanded: True)
      let effect = component.set_pseudo_state("expanded")

      #(model, effect)
    }

    UserPressedDown(event:) -> {
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
      let effect = dom.prevent_default(event)

      #(model, effect)
    }

    UserPressedEnd(event:) -> {
      let intent =
        model.options.lookup_index
        |> bidict.max_inverse(int.compare)
        |> option.from_result
      let model = Model(..model, intent:)
      let effect = dom.prevent_default(event)

      #(model, effect)
    }

    UserPressedEnter(event:) -> {
      let effect = case model.intent {
        option.Some(value) ->
          effect.batch([
            event.emit("change", json.object([#("value", json.string(value))])),
            dom.prevent_default(event),
          ])
        option.None -> dom.prevent_default(event)
      }

      #(model, effect)
    }

    UserPressedEscape(event:, trigger:) -> {
      let model = Model(..model, expanded: False, intent: option.None)
      let effect =
        effect.batch([
          component.remove_pseudo_state("expanded"),
          dom.prevent_default(event),
          effect.after_paint(fn(_, _) { dom.do_focus(trigger) }),
        ])

      #(model, effect)
    }

    UserPressedHome(event:) -> {
      let intent =
        model.options.lookup_index
        |> bidict.min_inverse(int.compare)
        |> option.from_result
      let model = Model(..model, intent:)
      let effect = dom.prevent_default(event)

      #(model, effect)
    }

    UserPressedUp(event:) -> {
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
      let effect = dom.prevent_default(event)

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

  let compare_options = fn(a: Item(Nil), b: Item(Nil)) -> order.Order {
    let a_label = string.lowercase(a.label)
    let b_label = string.lowercase(b.label)
    let a_starts = string.starts_with(a_label, query)
    let b_starts = string.starts_with(b_label, query)

    let assert Ok(a_index) = bidict.get(options.lookup_index, a.value)
    let assert Ok(b_index) = bidict.get(options.lookup_index, b.value)

    case a_starts, b_starts, strategy {
      True, False, _ -> order.Lt
      False, True, _ -> order.Gt
      _, _, ByIndex -> int.compare(a_index, b_index)
      _, _, ByLength ->
        int.compare(string.length(a_label), string.length(b_label))
    }
  }

  options.all
  |> list.filter(contains_query(_, query))
  |> list.sort(compare_options)
  |> list.first
  |> result.map(fn(option) { option.value })
  |> option.from_result
}

fn contains_query(option: Item(a), query: String) -> Bool {
  option.label
  |> string.lowercase
  |> string.contains(query)
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.slot(
      [
        attribute.style("display", "none"),
        event.on("slotchange", handle_slot_change()),
      ],
      [],
    ),
    popover.element(
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
        event.on("click", handle_popover_click(!model.expanded)),
        event.on("keydown", handle_popover_keydown(!model.expanded)),
      ],
      trigger: view_trigger(model.value, model.placeholder, model.options),
      content: html.div([attribute("part", "combobox-options")], [
        view_input(model.query),
        view_options(model.options, model.value, model.intent),
      ]),
    ),
  ])
}

fn handle_slot_change() -> Decoder(Msg) {
  use options <- decode.field("target", {
    dom.assigned_elements(
      {
        use tag <- decode.field("tagName", decode.string)
        use value <- decode.then(dom.attribute("value"))
        use label <- decode.field("textContent", decode.string)

        decode.success(#(tag, value, label))
      },
      lenient: True,
    )
  })

  options
  |> list.fold_right(#([], set.new()), fn(acc, option) {
    let #(tag, value, label) = option
    use <- bool.guard(tag != "LUSTRE-UI-COMBOBOX-OPTION", acc)
    use <- bool.guard(set.contains(acc.1, value), acc)
    let seen = set.insert(acc.1, value)
    let options = [Item(value:, label:, content: []), ..acc.0]

    #(options, seen)
  })
  |> pair.first
  |> ParentChangedChildren
  |> decode.success
}

fn handle_popover_click(will_open: Bool) -> Decoder(Msg) {
  use input <- decode.field(
    "currentTarget",
    dom.child("input", dynamic.nil(), decode.dynamic),
  )

  case will_open {
    True -> decode.success(UserActivatedPopoverTrigger(input:))
    False -> decode.failure(UserActivatedPopoverTrigger(input:), "")
  }
}

fn handle_popover_keydown(will_open: Bool) -> Decoder(Msg) {
  use key <- decode.field("key", decode.string)
  use input <- decode.field(
    "currentTarget",
    dom.child("input", dynamic.nil(), decode.dynamic),
  )

  case key {
    "Enter" | " " if will_open ->
      decode.success(UserActivatedPopoverTrigger(input:))
    _ -> decode.failure(UserActivatedPopoverTrigger(input:), "")
  }
}

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
    input.element([
      attribute.styles([
        #("width", "100%"),
        #("border-bottom-left-radius", "0px"),
        #("border-bottom-right-radius", "0px"),
      ]),
      attribute.autocomplete("off"),
      event.on_input(UserChangedQuery),
      event.on("keydown", handle_input_keydown()),
      attribute.value(query),
    ]),
  ])
}

fn handle_input_keydown() -> Decoder(Msg) {
  use event <- decode.then(decode.dynamic)
  use key <- decode.field("key", decode.string)

  case key {
    "ArrowDown" -> decode.success(UserPressedDown(event:))
    "ArrowEnd" -> decode.success(UserPressedEnd(event:))
    "Enter" -> decode.success(UserPressedEnter(event:))
    "Escape" -> {
      use trigger <- decode.field(
        "target",
        dom.child("button", dynamic.nil(), decode.dynamic),
      )

      decode.success(UserPressedEscape(event:, trigger:))
    }
    "Home" -> decode.success(UserPressedHome(event:))
    "ArrowUp" -> decode.success(UserPressedUp(event:))
    "Tab" -> decode.success(UserClosedMenu)
    _ -> decode.failure(UserClosedMenu, "")
  }
}

// VIEW OPTIONS ----------------------------------------------------------------

fn view_options(
  options: Options,
  value: String,
  intent: option.Option(String),
) -> Element(Msg) {
  keyed.ul([], do_view_options(options.filtered, value, intent))
}

fn do_view_options(
  options: List(Item(msg)),
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
  option: Item(msg),
  value: String,
  intent: option.Option(String),
  last: Bool,
) -> Element(Msg) {
  let is_selected = option.value == value
  let is_intent = option.Some(option.value) == intent

  let icon = case is_selected {
    True -> icon.check
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
      icon([attribute.styles([#("height", "1rem"), #("width", "1rem")])]),
      html.span([attribute.style("flex", "1 1 0%")], [
        element.element("slot", [attribute.name("option-" <> option.value)], [
          html.text(option.label),
        ]),
      ]),
    ],
  )
}
