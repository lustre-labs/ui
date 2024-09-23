// IMPORTS ---------------------------------------------------------------------

import decipher
import gleam/dict.{type Dict}
import gleam/dynamic.{type Decoder, dynamic}
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option}
import gleam/result
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/collapse.{collapse}
import lustre/ui/icon

// COMPONENT API ---------------------------------------------------------------

pub const name: String = "lustre-ui-accordion"

pub fn register() -> Result(Nil, lustre.Error) {
  let app = lustre.component(init, update, view, on_attribute_change())

  lustre.register(app, name)
}

pub fn accordion(
  attributes: List(Attribute(msg)),
  options: List(#(String, Element(msg))),
) -> Element(msg) {
  element(
    name,
    [attribute("options", int.to_string(list.length(options))), ..attributes],
    {
      use children, #(label, expanded), id <- list.index_fold(options, [])
      let name = "option-" <> int.to_string(id)
      let trigger = trigger(name, label)
      let content = content(name, expanded)

      [trigger, content, ..children]
    },
  )
}

fn trigger(name: String, label: String) -> Element(msg) {
  let base = "py-lui-sm w-full flex justify-between items-center border-b group"
  let hover = "group-hover:underline"

  html.button([attribute("slot", name <> ":trigger"), attribute.class(base)], [
    html.span([attribute.class(hover)], [html.text(label)]),
    icon.caret_left([attribute.class("size-6")]),
  ])
}

fn content(name: String, children: Element(msg)) -> Element(msg) {
  html.div(
    [attribute("slot", name <> ":content"), attribute.class("py-lui-sm")],
    [children],
  )
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(options: Int, active: Option(Int))
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Model(options: 10, active: option.None)
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentSetOptions(Int)
  UserToggledOption(Int)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case io.debug(msg) {
    ParentSetOptions(options) -> {
      let active = case model.active {
        option.Some(n) if n >= options -> option.None
        _ -> model.active
      }

      #(Model(options:, active:), effect.none())
    }

    UserToggledOption(id) -> {
      let active = case model.active {
        option.Some(n) if n == id -> option.None
        _ -> option.Some(id)
      }

      #(Model(options: model.options, active: active), effect.none())
    }
  }
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("options", fn(value) {
      value
      |> dynamic.any([dynamic.int, decipher.int_string])
      |> result.map(ParentSetOptions)
    }),
  ])
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment(
    list.map(list.range(0, model.options - 1), fn(id) {
      let name = "option-" <> int.to_string(id)
      let open = option.Some(id) == model.active
      let handle_change = fn(_) { Ok(UserToggledOption(id)) }

      collapse(
        [
          attribute.class("duration-200"),
          event.on("change", handle_change),
          collapse.open(open),
        ],
        trigger: html.slot([attribute.name(name <> ":trigger")]),
        content: html.slot([attribute.name(name <> ":content")]),
      )
    }),
  )
}
