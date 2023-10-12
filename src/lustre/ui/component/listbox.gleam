// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic.{Decoder}
import gleam/function
import gleam/int
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string
import internals/options
import internals/dom
import lustre
import lustre/attribute.{Attribute, attribute}
import lustre/effect.{Effect}
import lustre/element.{Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/icon
import lustre/ui/layout/aside.{aside}
import lustre/ui/layout/box.{box}
import lustre/ui/layout/stack.{stack}

// ELEMENTS --------------------------------------------------------------------

///
/// 
pub fn listbox(attributes: List(Attribute(msg))) -> Element(msg) {
  let _ = case lustre.is_browser(), lustre.is_registered("lustre-ui-listbox") {
    True, True -> Ok(Nil)
    True, False ->
      lustre.component(
        "lustre-ui-listbox",
        init,
        update,
        view,
        on_attribute_change(),
      )
    False, _ -> Ok(Nil)
  }

  element("lustre-ui-listbox", attributes, [])
}

// ATTRIBUTES ------------------------------------------------------------------

///
/// 
pub fn on_change(handler: fn(String) -> msg) -> Attribute(msg) {
  use event <- event.on("change")

  event
  |> dynamic.field("detail", dynamic.string)
  |> result.map(handler)
}

///
/// 
pub fn options(opts: List(String)) -> Attribute(msg) {
  case lustre.is_browser() {
    True -> attribute.property("options", opts)

    // If we're rendering on the server we need some sensible way to encode
    // the options being passed in. We'll use a comma-separated string, and
    // HTML entity encode any commas in the options.
    False ->
      attribute(
        "options",
        opts
        |> list.map(string.replace(_, ",", "&#44;"))
        |> string.join(", "),
      )
  }
}

///
/// 
pub fn value(val: String) -> Attribute(msg) {
  attribute("value", val)
}

///
/// 
pub fn label(val: String) -> Attribute(msg) {
  attribute("label", val)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(id: String, label: String, value: String, options: List(String))
}

fn init() -> #(Model, Effect(Msg)) {
  let id =
    int.random(0, 9999)
    |> int.to_string
    |> string.append("listbox-", _)
  let model = Model(id: id, label: "", value: "", options: [])

  #(model, effect.none())
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  OnAttrChange(Attr)
  OnKeyPress(Key)
  OnSelect(String)
}

type Attr {
  Id(String)
  Label(String)
  Options(List(String))
  Value(String)
}

type Key {
  ArrowUp
  ArrowDown
  Home
  End
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    OnAttrChange(Id(id)) -> {
      #(Model(..model, id: id), effect.none())
    }
    OnAttrChange(Label(label)) -> {
      #(Model(..model, label: label), effect.none())
    }
    OnAttrChange(Options(opts)) -> {
      #(Model(..model, options: opts), effect.none())
    }
    OnAttrChange(Value(val)) -> {
      #(Model(..model, value: val), effect.none())
    }
    OnKeyPress(key) -> {
      let value = case key {
        ArrowUp -> options.previous(model.options, model.value)
        ArrowDown -> options.next(model.options, model.value)
        Home -> options.first(model.options)
        End -> options.last(model.options)
      }

      #(Model(..model, value: value), event.emit("change", value))
    }
    OnSelect(value) -> {
      #(
        Model(..model, value: value),
        effect.batch([event.emit("change", value), dom.focus(model.id)]),
      )
    }
  }
}

fn on_attribute_change() -> Map(String, Decoder(Msg)) {
  map.from_list([
    #(
      "value",
      fn(dyn) {
        dyn
        |> dynamic.string
        |> result.map(function.compose(Value, OnAttrChange))
      },
    ),
    #(
      "options",
      dynamic.any([
        fn(dyn) {
          dyn
          |> dynamic.list(dynamic.string)
          |> result.map(function.compose(Options, OnAttrChange))
        },
        fn(dyn) {
          dyn
          |> dynamic.string
          |> result.map(string.split(_, ", "))
          |> result.map(list.map(_, string.replace(_, "&#44;", ",")))
          |> result.map(function.compose(Options, OnAttrChange))
        },
      ]),
    ),
    #(
      "label",
      fn(dyn) {
        dyn
        |> dynamic.string
        |> result.map(function.compose(Label, OnAttrChange))
      },
    ),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  stack(
    [attribute("tabindex", "0"), on_key_press(), stack.tight()],
    [
      view_label(model.id, model.label),
      view_options(model.id, model.options, model.value),
    ],
  )
}

fn on_key_press() -> Attribute(Msg) {
  use event <- event.on("keydown")
  use key <- result.try(dynamic.field("key", dynamic.string)(event))

  case key {
    "ArrowUp" -> {
      event.prevent_default(event)
      Ok(OnKeyPress(ArrowUp))
    }
    "ArrowDown" -> {
      event.prevent_default(event)
      Ok(OnKeyPress(ArrowDown))
    }
    "Home" -> {
      event.prevent_default(event)
      Ok(OnKeyPress(Home))
    }
    "End" -> {
      event.prevent_default(event)
      Ok(OnKeyPress(End))
    }
    _ -> Error([])
  }
}

fn view_label(id: String, label: String) -> Element(Msg) {
  html.label(
    [attribute.id(id <> "-label"), attribute.for(id), attribute.class("label")],
    [element.text(label)],
  )
}

fn view_options(
  id: String,
  options: List(String),
  value: String,
) -> Element(Msg) {
  stack(
    [
      attribute.id(id),
      attribute.class("options"),
      attribute("role", "listbox"),
      stack.packed(),
    ],
    list.map(options, view_option(_, value)),
  )
}

fn view_option(option: String, value: String) -> Element(Msg) {
  box(
    [
      attribute.class("option"),
      attribute("role", "option"),
      attribute(
        "aria-selected",
        string.lowercase(bool.to_string(option == value)),
      ),
      event.on_click(OnSelect(option)),
    ],
    [
      aside(
        [],
        html.span([], [element.text(option)]),
        html.span(
          [attribute.class("marker")],
          [
            case value == option {
              True -> icon.check([])
              False -> element.text("")
            },
          ],
        ),
      ),
    ],
  )
}
