// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/dom

// COMPONENT -------------------------------------------------------------------

const tag: String = "lustre-ui-otp"

const digit_tag: String = "lustre-ui-otp-digit"

const separator_tag: String = "lustre-ui-otp-separator"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    tag,
  )
}

// ATTRIBUTES ------------------------------------------------------------------

///
///
pub fn value(otp: String) -> Attribute(msg) {
  attribute.value(otp)
}

///
///
pub fn disabled(is_disabled: Bool) -> Attribute(msg) {
  attribute.disabled(is_disabled)
}

///
///
pub type AllowedCharacters {
  Digits
  Letters
  Both
}

///
///
pub fn allow(allowed: AllowedCharacters) -> Attribute(msg) {
  let attribute = case allowed {
    Digits -> "digits"
    Letters -> "letters"
    Both -> "digits letters"
  }
  attribute.attribute("allow", attribute)
}

// EVENTS ----------------------------------------------------------------------

///
///
pub fn on_change(handler: fn(String) -> msg) -> Attribute(msg) {
  let handle_change =
    decode.at(["detail"], decode.string)
    |> decode.map(handler)

  event.on("lustre-ui:change", handle_change)
}

///
///
pub fn on_complete(handler: fn(String) -> msg) -> Attribute(msg) {
  let handle_complete =
    decode.at(["detail"], decode.string)
    |> decode.map(handler)

  event.on("lustre-ui:complete", handle_complete)
}

// ELEMENTS --------------------------------------------------------------------

///
///
pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Item),
) -> Element(msg) {
  element(tag, attributes, {
    list.map(children, fn(item) {
      case item {
        Digit -> element(digit_tag, [], [])
        Separator -> element(separator_tag, [], [])
      }
    })
  })
}

///
///
pub opaque type Item {
  Digit
  Separator
}

///
///
pub fn digit() -> Item {
  Digit
}

///
///
pub fn separator() -> Item {
  Separator
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    value: String,
    template: List(Item),
    slots: Int,
    show_caret: Bool,
    disabled: Bool,
    allowed: AllowedCharacters,
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      value: "",
      template: [Digit, Digit, Digit, Digit],
      slots: 4,
      show_caret: False,
      disabled: False,
      allowed: Digits,
    )
  let effect = effect.none()

  #(model, effect)
}

fn options() -> List(component.Option(Msg)) {
  [
    component.delegates_focus(True),
    component.form_associated(),
    component.on_attribute_change("value", fn(value) {
      Ok(ParentChangedValue(value:))
    }),
    component.on_attribute_change("disabled", fn(_) {
      Ok(ParentToggledDisabled)
    }),
    component.on_attribute_change("allow", fn(allowed) {
      case allowed {
        "" -> Ok(Digits)
        "digits" -> Ok(Digits)
        "letters" -> Ok(Letters)
        "letters digits" | "digits letters" -> Ok(Both)
        _ -> Error(Nil)
      }
      |> result.map(ParentChangedAllowed)
    }),
  ]
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  InputChangedSelection
  ParentChangedSlot(items: List(Item))
  ParentChangedValue(value: String)
  ParentToggledDisabled
  ParentChangedAllowed(allowed: AllowedCharacters)
  UserBlurredInput
  UserFocusedInput
  UserPressedIgnoredKey
  UserUpdatedValue(value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    InputChangedSelection -> #(model, reset_selection())

    ParentChangedSlot(items: template) -> {
      let slots = list.count(template, fn(item) { item == Digit })
      let value =
        model.value
        |> filter_value(model.allowed)
        |> crop_value(slots)
      let did_change = model.value != value
      let is_complete = did_change && string.length(value) == slots
      let model = Model(..model, template:, slots:, value:)
      let effect = case did_change {
        True if is_complete ->
          effect.batch([
            event.emit("lustre-ui:change", json.string(value)),
            event.emit("lustre-ui:complete", json.string(value)),
          ])
        True -> event.emit("lustre-ui:change", json.string(value))
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentChangedValue(value:) -> {
      let value =
        value
        |> filter_value(model.allowed)
        |> crop_value(model.slots)
      let model = Model(..model, value:)
      let effect = effect.none()

      #(model, effect)
    }

    ParentToggledDisabled -> {
      let model = Model(..model, disabled: !model.disabled)
      let effect = effect.none()

      #(model, effect)
    }

    ParentChangedAllowed(allowed:) -> {
      let value = filter_value(model.value, allowed)
      let model = Model(..model, value:, allowed:)
      let effect = effect.none()

      #(model, effect)
    }

    UserBlurredInput -> {
      let model = Model(..model, show_caret: False)
      let effect = effect.none()

      #(model, effect)
    }

    UserFocusedInput -> {
      let model = Model(..model, show_caret: True)
      let effect = reset_selection()

      #(model, effect)
    }

    UserPressedIgnoredKey -> {
      #(model, effect.none())
    }

    UserUpdatedValue(value:) -> {
      let value =
        value
        |> filter_value(model.allowed)
        |> crop_value(model.slots)
      let is_complete = string.length(value) == model.slots
      let model = Model(..model, value:)
      let effect = case is_complete {
        True ->
          effect.batch([
            event.emit("lustre-ui:change", json.string(value)),
            event.emit("lustre-ui:complete", json.string(value)),
          ])
        False -> event.emit("lustre-ui:change", json.string(value))
      }

      #(model, effect)
    }
  }
}

fn crop_value(value: String, slots: Int) -> String {
  case string.length(value) {
    length if length > slots -> string.drop_end(value, length - slots)
    _ -> value
  }
}

fn filter_value(value: String, allowed: AllowedCharacters) -> String {
  let options = regexp.Options(case_insensitive: True, multi_line: False)
  let assert Ok(banned) =
    case allowed {
      Digits -> "[^0-9]"
      Letters -> "[^a-z]"
      Both -> "[^0-9a-z]"
    }
    |> regexp.compile(options)

  regexp.replace(each: banned, in: value, with: "")
}

// EFFECTS ---------------------------------------------------------------------

fn reset_selection() -> Effect(msg) {
  use _, root <- effect.before_paint
  do_reset_selection(root)
}

@external(javascript, "./otp.ffi.mjs", "reset_selection")
fn do_reset_selection(root: Dynamic) -> Nil

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let handle_slotchange = {
    use target <- decode.field("target", dom.element_decoder())
    let assigned_elements = dom.assigned_elements(target)
    let items =
      list.filter_map(assigned_elements, fn(element) {
        case dom.tag(element) {
          tag if tag == digit_tag -> Ok(Digit)
          tag if tag == separator_tag -> Ok(Separator)
          _ -> Error(Nil)
        }
      })

    decode.success(ParentChangedSlot(items:))
  }

  let handle_keydown = {
    use key <- decode.field("key", decode.string)
    use ctrl <- decode.field("ctrlKey", decode.bool)
    use meta <- decode.field("metaKey", decode.bool)

    case key {
      // Prevent the user moving the input caret left or right
      "Arrow" <> _ ->
        decode.success(event.handler(UserPressedIgnoredKey, True, False))

      // Prevent the user selecting the entire input
      "a" if ctrl || meta ->
        decode.success(event.handler(UserPressedIgnoredKey, True, False))

      _ ->
        decode.failure(event.handler(UserPressedIgnoredKey, False, False), "")
    }
  }

  element.fragment([
    html.style([], {
      "
      /* FUNCTIONAL STYLES -------------------------------------------------- */

      :host {
        align-items: center;
        display: inline-flex;
        position: relative;
      }

      .otp-input {
        clip-path: inset(50%);
        clip: rect(0 0 0 0);
        height: 1px;
        left: 0;
        overflow: hidden;
        position: absolute;
        top: 0;
        user-select: none;
        width: 1px;
      }

      .otp-digits {
        display: contents;
      }

      /* DEFAULT DISPLAY STYLES --------------------------------------------- */

      :is(.otp-digit) {
        align-items: center;
        cursor: text;
        display: flex;
        justify-content: center;
        user-select: none;
      }

      @keyframes otp-caret-blink {
        0% { opacity: 0; }
        50% { opacity: 1; }
        100% { opacity: 0; }
      }

      :is(.otp-caret) {
        animation: otp-caret-blink 1s step-start infinite;
      }
      "
    }),
    component.default_slot(
      [event.on("slotchange", handle_slotchange), attribute.hidden(True)],
      [],
    ),
    html.input([
      attribute.class("otp-input"),
      attribute.value(model.value),
      attribute.maxlength(model.slots),
      attribute.disabled(model.disabled),
      event.on_input(UserUpdatedValue),
      event.on_focus(UserFocusedInput),
      event.on_blur(UserBlurredInput),
      event.advanced("keydown", handle_keydown),
    ]),
    html.div(
      [
        attribute.class("otp-digits"),
        // Browsers have inconsistent behaviour when selecting the non-interactive
        // part of a custom element if that custom element a) enables focus
        // delegation, b) already has focus, and c) the element in focus is an
        // input.
        //
        // Some browsers appear to select the entire input text, which we want to
        // avoid. Dispatching this event lets us run an effect to force the input
        // selection to always be at the end of the input text.
        event.on("pointerdown", decode.success(InputChangedSelection)),
      ],
      view_digits(model.value, model.template, model.show_caret),
    ),
  ])
}

fn view_digits(
  value: String,
  template: List(Item),
  show_caret: Bool,
) -> List(Element(Msg)) {
  do_view_digits(string.to_graphemes(value), template, !show_caret, [])
}

fn do_view_digits(
  graphemes: List(String),
  template: List(Item),
  hide_caret: Bool,
  out: List(Element(Msg)),
) -> List(Element(Msg)) {
  case graphemes, template {
    [char, ..rest_graphemes], [Digit] ->
      do_view_digits(rest_graphemes, [], hide_caret, [
        view_digit(!hide_caret, [html.text(char)]),
        ..out
      ])

    [char, ..rest_graphemes], [Digit, ..rest_template] ->
      do_view_digits(rest_graphemes, rest_template, hide_caret, [
        view_digit(False, [html.text(char)]),
        ..out
      ])

    [], [Digit, ..rest_template] if hide_caret ->
      do_view_digits([], rest_template, hide_caret, [
        view_digit(False, []),
        ..out
      ])

    [], [Digit, ..rest_template] ->
      do_view_digits([], rest_template, True, [
        view_digit(True, [view_caret()]),
        ..out
      ])

    _, [Separator, ..rest_template] ->
      do_view_digits(graphemes, rest_template, hide_caret, [
        view_separator(),
        ..out
      ])

    _, [] -> list.reverse(out)
  }
}

fn view_digit(visual_focus: Bool, children: List(Element(Msg))) -> Element(Msg) {
  html.div(
    [
      attribute.class("otp-digit"),
      component.parts([#("digit", True), #("active", visual_focus)]),
    ],
    children,
  )
}

fn view_separator() -> Element(Msg) {
  html.div([component.part("separator")], [])
}

fn view_caret() -> Element(Msg) {
  html.div([attribute.class("otp-caret"), component.part("caret")], [])
}
