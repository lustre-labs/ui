// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{DecodeError, Decoder}
import gleam/function.{constant}
import gleam/list
import gleam/map.{Map}
import gleam/option.{None, Option, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{attribute, property}
import lustre/effect.{Effect}
import lustre/element.{Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/icon

// CONSTANTS -------------------------------------------------------------------

pub const name: String = "lustre-ui-listbox"

pub const styles: String = "
  lustre-ui-listbox {
    display: block;
  }

  lustre-ui-listbox .listbox-label {
    font-size: var(--text-xs);
    border-radius: var(--border-radius);
    margin-bottom: var(--space-xs);
  }

  lustre-ui-listbox .listbox-options {
    border-radius: var(--border-radius);
    border: 2px solid var(--element-border-subtle);
    list-style: none;
    max-height: 24em;
    outline: none;
    overflow-y: auto;
    padding: var(--space-xs) 0;
    width: 100%;
  }

  lustre-ui-listbox:focus-within .listbox-options {
    border-color: var(--element-border-strong);
  }

  lustre-ui-listbox .listbox-option {
    align-items: center;
    cursor: pointer;
    display: flex;
    gap: var(--space-xs);
    padding: var(--space-xs) var(--space-md);
  }

  lustre-ui-listbox .listbox-option .option-icon {
    width: 15px;
    height: 15px;
  }

  lustre-ui-listbox .listbox-option:hover {
    background-color: var(--element-background-hover);
  }

  lustre-ui-listbox .listbox-option:hover:active {
    background-color: var(--element-background-strong);
  }

  lustre-ui-listbox .listbox-option[aria-selected='true'] {
    background-color: var(--element-background-strong);
  }
"

// COMPONENT -------------------------------------------------------------------

pub fn listbox(
  label: String,
  options: List(String),
  default: Option(String),
  on_change: fn(String) -> msg,
) -> Element(msg) {
  let _ = case lustre.is_browser() && !lustre.is_registered(name) {
    True -> lustre.component(name, init, update, view, on_attribute_change())
    False -> Ok(Nil)
  }

  element(
    name,
    [
      attribute("label", label),
      property("options", options),
      property("default", default),
      event.on(
        "change",
        fn(event) {
          event
          |> dynamic.field("detail", dynamic.string)
          |> result.map(on_change)
        },
      ),
    ],
    [],
  )
}

fn on_attribute_change() -> Map(String, Decoder(Msg)) {
  let on_label_change = fn(dyn) {
    dyn
    |> dynamic.string
    |> result.map(GotLabel)
  }
  let on_options_change = fn(dyn) {
    dyn
    |> dynamic.list(dynamic.string)
    |> result.map(GotOptions)
  }
  let on_default_change = fn(dyn) {
    dyn
    |> dynamic.optional(dynamic.string)
    |> result.map(GotDefault)
  }

  map.from_list([
    #("label", on_label_change),
    #("options", on_options_change),
    #("default", on_default_change),
  ])
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    label: String,
    selected: Option(String),
    focused: Bool,
    options: List(String),
  )
}

fn init() -> #(Model, Effect(Msg)) {
  #(
    Model(label: "", selected: None, focused: False, options: []),
    effect.none(),
  )
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  GotDefault(Option(String))
  GotLabel(String)
  GotOptions(List(String))
  OnBlur
  OnFocus
  OnKeyPress(Key)
  OnSelect(String)
}

type Key {
  Down
  End
  Home
  Up
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let focused = model.focused

  case msg {
    GotLabel(label) -> #(Model(..model, label: label), effect.none())
    GotOptions(options) -> #(Model(..model, options: options), effect.none())
    GotDefault(None) -> #(Model(..model, selected: None), effect.none())
    GotDefault(Some(default)) -> #(
      Model(..model, selected: Some(default)),
      scroll_to_option(default),
    )
    OnBlur -> #(model, effect.none())
    OnFocus -> #(Model(..model, focused: True), effect.none())
    OnKeyPress(key) if focused -> on_key_press(model, key)
    OnKeyPress(_) -> #(model, effect.none())
    OnSelect(selected) -> #(
      Model(..model, selected: Some(selected)),
      event.emit("change", selected),
    )
  }
}

fn on_key_press(model: Model, key: Key) -> #(Model, Effect(Msg)) {
  let effects = fn(selected) {
    effect.batch([
      scroll_to_option(selected),
      focus_to_parent(selected),
      event.emit("change", selected),
    ])
  }

  case key {
    Down -> {
      let selected = select_after(model.options, model.selected)

      #(
        Model(..model, selected: selected),
        selected
        |> option.map(effects)
        |> option.unwrap(effect.none()),
      )
    }

    End -> {
      let selected = select_last(model.options)

      #(
        Model(..model, selected: selected),
        selected
        |> option.map(effects)
        |> option.unwrap(effect.none()),
      )
    }

    Home -> {
      let selected = select_first(model.options)

      #(
        Model(..model, selected: selected),
        selected
        |> option.map(effects)
        |> option.unwrap(effect.none()),
      )
    }

    Up -> {
      let selected = select_before(model.options, model.selected)

      #(
        Model(..model, selected: selected),
        selected
        |> option.map(effects)
        |> option.unwrap(effect.none()),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div(
    [],
    [
      view_label(model.label),
      view_options(model.options, model.selected, model.label),
    ],
  )
}

fn view_label(label: String) -> Element(Msg) {
  html.p(
    [
      attribute.class("listbox-label"),
      attribute.id(to_id(label)),
      event.on_click(OnFocus),
    ],
    [element.text(label)],
  )
}

fn view_options(
  options: List(String),
  selected: Option(String),
  label: String,
) -> Element(Msg) {
  html.ul(
    [
      attribute.class("listbox-options"),
      attribute("role", "listbox"),
      attribute("tabindex", "0"),
      attribute("aria-labelledby", to_id(label)),
      selected
      |> option.map(to_id)
      |> option.map(attribute("aria-activedescendant", _))
      |> option.unwrap(attribute.class("")),
      event.on_focus(OnFocus),
      event.on_blur(OnBlur),
      event.on(
        "keydown",
        fn(event) {
          use key <- result.try(dynamic.field("key", dynamic.string)(event))
          case key {
            "ArrowDown" ->
              event.prevent_default(event)
              |> constant(OnKeyPress(Down))
              |> Ok

            "ArrowUp" ->
              event.prevent_default(event)
              |> constant(OnKeyPress(Up))
              |> Ok

            "End" ->
              event.prevent_default(event)
              |> constant(OnKeyPress(End))
              |> Ok

            "Home" ->
              event.prevent_default(event)
              |> constant(OnKeyPress(Home))
              |> Ok

            // When the decoder fails no event gets emitted so we just want to
            // create a dummy error to satisfy the type checker.
            _ -> Error([DecodeError("", "", [])])
          }
        },
      ),
    ],
    list.map(options, view_option(_, selected, label)),
  )
}

fn view_option(
  option: String,
  selected: Option(String),
  label: String,
) -> Element(Msg) {
  case Some(option) == selected {
    True ->
      html.li(
        [
          attribute.id(to_id(label <> "-" <> option)),
          attribute.class("listbox-option"),
          attribute("role", "option"),
          attribute("aria-selected", "true"),
        ],
        [
          icon.check([
            attribute.class("option-icon"),
            attribute("aria-hidden", "true"),
          ]),
          html.span([attribute.class("option-label")], [element.text(option)]),
        ],
      )
    False ->
      html.li(
        [
          attribute.id(to_id(label <> "-" <> option)),
          attribute.class("listbox-option"),
          attribute("role", "option"),
          attribute("aria-selected", "false"),
          event.on_click(OnSelect(option)),
        ],
        [
          html.span([attribute.class("option-icon")], []),
          html.span([attribute.class("option-label")], [element.text(option)]),
        ],
      )
  }
}

// UTILS -----------------------------------------------------------------------

fn to_id(label: String) -> String {
  label
  |> string.lowercase
  |> string.trim
  |> string.replace(" ", "-")
  // There's probably a better way to do this, I couldn't work out how to do it
  // with gleam_regex.
  |> string.replace(":", "")
  |> string.replace(";", "")
  |> string.replace("*", "")
}

fn scroll_to_option(label: String) -> Effect(msg) {
  scroll_to("#" <> to_id(label))
}

fn focus_to_parent(label: String) -> Effect(msg) {
  focus("lustre-ui-listbox .listbox-options:has(#" <> to_id(label) <> ")")
}

fn select_first(options: List(String)) -> Option(String) {
  case options {
    [] -> None
    [option, ..] -> Some(option)
  }
}

fn select_before(
  options: List(String),
  selected: Option(String),
) -> Option(String) {
  case options, selected {
    [], _ -> None
    [a, ..], None -> Some(a)
    [a, ..], Some(selected) if a == selected -> Some(a)
    [a, b, ..], Some(selected) if b == selected -> Some(a)
    [_, b, ..rest], Some(selected) -> select_before([b, ..rest], Some(selected))
  }
}

fn select_after(
  options: List(String),
  selected: Option(String),
) -> Option(String) {
  case options, selected {
    [], _ -> None
    [_, b], _ -> Some(b)
    [option, ..], None -> Some(option)
    [a, b, ..], Some(selected) if a == selected -> Some(b)
    [_, b, ..rest], Some(selected) -> select_after([b, ..rest], Some(selected))
  }
}

fn select_last(options: List(String)) -> Option(String) {
  case options {
    [] -> None
    [option] -> Some(option)
    [_, ..rest] -> select_last(rest)
  }
}

// FFI UTILS -------------------------------------------------------------------

fn scroll_to(selector: String) -> Effect(msg) {
  use _ <- effect.from
  do_scroll_into_view(selector, "instant", "center")
}

@external(javascript, "../../lustre_ui.ffi.mjs", "scroll_into_view")
fn do_scroll_into_view(
  _selector: String,
  _behaviour: String,
  _block: String,
) -> Nil {
  Nil
}

pub fn focus(selector: String) -> Effect(a) {
  use _ <- effect.from
  do_focus(selector)
}

@external(javascript, "../../lustre_ui.ffi.mjs", "focus")
fn do_focus(_selector: String) -> Nil {
  Nil
}
