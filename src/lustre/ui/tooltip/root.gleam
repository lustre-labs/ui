// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/int
import gleam/json

import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tooltip/context
import lustre/ui/tooltip/popover
import lustre/ui/tooltip/trigger
import lustre_ui/dom/element as html_element
import lustre_ui/dom/web_component
import lustre_ui/prop.{type Prop, Prop}

// ELEMENTS --------------------------------------------------------------------

///
///
pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn default_open(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("value", "true")
    False -> attribute("value", "false")
  }
}

pub fn open(value: Bool) -> Attribute(message) {
  case lustre.is_browser() {
    True -> attribute.property("open", json.bool(value))
    False -> default_open(value)
  }
}

// EVENTS ----------------------------------------------------------------------

pub fn on_open_change(handler: fn(Bool) -> message) -> Attribute(message) {
  event.on("tooltip:change", {
    use open <- decode.field("detail", decode.bool)

    decode.success(handler(open))
  })
}

fn emit_change(open: Bool) -> Effect(Message) {
  event.emit("tooltip:change", json.bool(open))
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tooltip"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_attribute_change("delay", fn(value) {
        case int.parse(value) {
          Ok(number) if number < 0 -> Ok(ParentSetDelay(0))
          Ok(number) -> Ok(ParentSetDelay(number))
          Error(_) -> Ok(ParentResetDelay)
        }
      }),

      component.on_attribute_change("open", fn(value) {
        case value {
          "true" -> Ok(ParentSetDefaultOpen(True))
          "false" | "" -> Ok(ParentSetDefaultOpen(False))
          _ -> Error(Nil)
        }
      }),

      component.on_property_change("open", {
        decode.bool
        |> decode.map(ParentSetOpen)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(popover: String, open: Prop(Bool), delay: Int)
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(popover: "", open: prop.new(False), delay: 50)
  let effect =
    effect.batch([
      context.provide("", False, 50),
      web_component.before_paint(fn(dispatch, _, component) {
        case html_element.attribute(component, "value") {
          Ok("") | Error(_) -> {
            let selector = "lustre-tooltip-popover[open=\"true\"]"

            case html_element.query_selector(component, selector) {
              Ok(_) -> dispatch(ParentSetDefaultOpen(True))
              Error(_) -> Nil
            }
          }

          Ok(_) -> Nil
        }
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentResetDelay
  ParentSetDefaultOpen(value: Bool)
  ParentSetDelay(value: Int)
  ParentSetOpen(value: Bool)
  UserActivatedTrigger
  UserDismissedTrigger
  UserSetPopoverId(value: String)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentResetDelay -> {
      let model = Model(..model, delay: 50)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetDefaultOpen(value:) ->
      case model.open.controlled || model.open.touched {
        True -> #(model, effect.none())
        False -> {
          let open = Prop(..model.open, value:)
          let model = Model(..model, open:)
          let effect = context.provide(model.popover, model.open.value, 50)

          #(model, effect)
        }
      }

    ParentSetDelay(value:) -> {
      let model = Model(..model, delay: value)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetOpen(value:) -> {
      let model = Model(..model, open: prop.control(model.open, value))
      let effect = context.provide(model.popover, model.open.value, 50)

      #(model, effect)
    }

    UserActivatedTrigger ->
      case model.open.controlled {
        True -> {
          let effect = emit_change(True)
          #(model, effect)
        }
        False -> {
          let open = prop.touch(model.open, True)
          let model = Model(..model, open:)
          let effect =
            effect.batch([
              context.provide(model.popover, model.open.value, 50),
              emit_change(model.open.value),
            ])

          #(model, effect)
        }
      }

    UserDismissedTrigger ->
      case model.open.controlled {
        True -> {
          let effect = emit_change(False)
          #(model, effect)
        }

        False -> {
          let open = prop.touch(model.open, False)
          let model = Model(..model, open:)
          let effect =
            effect.batch([
              context.provide(model.popover, model.open.value, 50),
              emit_change(model.open.value),
            ])

          #(model, effect)
        }
      }

    UserSetPopoverId(value:) -> {
      let model = Model(..model, popover: value)
      let effect = context.provide(model.popover, model.open.value, 50)

      #(model, effect)
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_model: Model) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: contents;
      }
      "
    }),

    component.default_slot(
      [
        trigger.on_activate(UserActivatedTrigger),
        trigger.on_dismiss(UserDismissedTrigger),
        popover.on_identify(UserSetPopoverId),
      ],
      [],
    ),
  ])
}
