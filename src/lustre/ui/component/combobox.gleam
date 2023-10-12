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
import lustre/ui/button.{button}
import lustre/ui/icon
import lustre/ui/layout/aside.{aside}
import lustre/ui/layout/box.{box}
import lustre/ui/layout/stack.{stack}

// ELEMENTS --------------------------------------------------------------------

///
/// 
pub fn select(attributes: List(Attribute(msg))) -> Element(msg) {
  let _ = case lustre.is_browser(), lustre.is_registered("lustre-ui-combobox") {
    True, True -> Ok(Nil)
    True, False ->
      lustre.component(
        "lustre-ui-combobox",
        init,
        update,
        view,
        on_attribute_change(),
      )
    False, _ -> Ok(Nil)
  }

  element("lustre-ui-combobox", attributes, [])
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
  Model(
    id: String,
    label: String,
    value: String,
    options: List(String),
    expanded: Bool,
    interactive: Bool,
  )
}

fn init() -> #(Model, Effect(Msg)) {
  let model =
    Model(
      id: int.random(0, 9999)
      |> int.to_string
      |> string.append("listbox-", _),
      label: "",
      value: "",
      options: [],
      expanded: False,
      interactive: False,
    )

  #(model, effect.none())
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  OnAttrChange(Attr)
  OnExpand
  OnHide
  OnKeyPress(Key)
  OnSelect(String)
  OnToggle
}

type Attr {
  Id(String)
  Interactive(Bool)
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
    OnAttrChange(Interactive(interactive)) -> {
      #(Model(..model, interactive: interactive), effect.none())
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
    OnExpand -> {
      #(Model(..model, expanded: True), dom.focus("#" <> model.id))
    }
    OnHide -> {
      #(Model(..model, expanded: False), effect.none())
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
        Model(..model, value: value, expanded: True),
        effect.batch([event.emit("change", value), dom.focus("#" <> model.id)]),
      )
    }
    OnToggle -> {
      let expanded = !model.expanded

      #(
        Model(..model, expanded: !model.expanded),
        case expanded {
          True -> dom.focus("#" <> model.id)
          False -> effect.none()
        },
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
    #(
      "interactive",
      fn(dyn) {
        dyn
        |> dynamic.bool
        |> result.map(function.compose(Interactive, OnAttrChange))
      },
    ),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  stack(
    [on_key_press(), stack.tight()],
    [
      view_label(model.id, model.label),
      view_value(model.id, model.value, model.expanded, model.interactive),
      html.div(
        [attribute.class("options-container")],
        [view_options(model.options, model.value)],
      ),
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

fn view_value(
  id: String,
  value: String,
  expanded: Bool,
  interactive: Bool,
) -> Element(Msg) {
  aside(
    [aside.tight(), aside.anchor_center()],
    case interactive {
      True ->
        html.input([
          attribute.id(id),
          attribute.class("input"),
          attribute("role", "combobox"),
          attribute("aria-expanded", string.lowercase(bool.to_string(expanded))),
          attribute("value", value),
        ])
      False ->
        html.p(
          [
            attribute.id(id),
            attribute.class("input"),
            attribute("tabindex", "0"),
            attribute("role", "combobox"),
            attribute(
              "aria-expanded",
              string.lowercase(bool.to_string(expanded)),
            ),
          ],
          [element.text(value)],
        )
    },
    case expanded {
      True ->
        button(
          [attribute.class("toggle"), event.on_click(OnHide)],
          [icon.cross([])],
        )
      False ->
        button(
          [attribute.class("toggle"), event.on_click(OnExpand)],
          [icon.caret_sort([])],
        )
    },
  )
}

fn view_options(options: List(String), value: String) -> Element(Msg) {
  stack(
    [attribute.class("options"), attribute("role", "listbox"), stack.packed()],
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
