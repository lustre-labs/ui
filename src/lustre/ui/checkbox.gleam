// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/result
import lustre
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/ui/checkbox_internal/context
import lustre/ui/checkbox_internal/indicator
import lustre/ui_internal/host
import lustre/ui_internal/value.{type Value}

// COMPONENT -------------------------------------------------------------------

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(indicator.register())
  use _ <- result.try(lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    context.checkbox_tag,
  ))

  Ok(Nil)
}

// ELEMENTS --------------------------------------------------------------------

///
///
pub fn indicator(children: List(Element(msg))) -> Element(msg) {
  element(context.checkbox_indicator_tag, [], children)
}

// ATTRIBUTES ------------------------------------------------------------------

// EVENTS ----------------------------------------------------------------------

// MODEL -----------------------------------------------------------------------

type Model {
  Model(checked: Value(context.Checked))
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(checked: value.Uncontrolled(context.Off, context.Off, False))
  let effect =
    effect.batch([
      context.provide(context.new(model.checked.value)),
      host.set_role("checkbox"),
    ])

  #(model, effect)
}

fn options() -> List(component.Option(Msg)) {
  [
    component.on_attribute_change("checked", fn(value) {
      Ok(case value {
        "on" -> ParentSetDefaultChecked(value: context.On)
        "indeterminate" -> ParentSetDefaultChecked(value: context.Indeterminate)
        "off" -> ParentSetDefaultChecked(value: context.Off)
        _ -> ParentToggledDefaultChecked
      })
    }),

    component.on_property_change("checked", {
      decode.one_of(
        decode.map(decode.bool, fn(on) {
          case on {
            True -> context.On
            False -> context.Off
          }
        }),
        [
          decode.then(decode.string, fn(value) {
            case value == "indeterminate" {
              True -> decode.success(context.Indeterminate)
              False -> decode.failure(context.Off, "")
            }
          }),
        ],
      )
      |> decode.map(ParentSetChecked)
    }),
  ]
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentSetChecked(value: context.Checked)
  ParentSetDefaultChecked(value: context.Checked)
  ParentToggledDefaultChecked
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    _ -> #(model, effect.none())
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_model: Model) -> Element(Msg) {
  html.text("")
}
