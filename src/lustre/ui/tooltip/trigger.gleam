// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tooltip/context.{type Context}
import lustre_ui/dom/web_component
import lustre_ui/dom/window.{type TimeoutId}
import lustre_ui/prop.{type Prop}

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

pub fn delay(value: Int) -> Attribute(message) {
  attribute("delay", int.to_string(int.max(value, 0)))
}

// EVENTS ----------------------------------------------------------------------

pub fn on_activate(handler: message) -> Attribute(message) {
  event.on("tooltip/trigger:activate", decode.success(handler))
}

fn emit_activate() -> Effect(message) {
  event.emit("tooltip/trigger:activate", json.null())
}

pub fn on_dismiss(handler: message) -> Attribute(message) {
  event.on("tooltip/trigger:dismiss", decode.success(handler))
}

fn emit_dismiss() -> Effect(message) {
  event.emit("tooltip/trigger:dismiss", json.null())
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tooltip-trigger"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      context.on_change(TooltipProvidedContext),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(open: Bool, delay: Prop(Int), timeout: Option(TimeoutId))
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(open: False, delay: prop.new(50), timeout: None)
  let effect =
    web_component.before_paint(fn(dispatch, _, component) {
      web_component.add_event_listener(component, "mouseenter", fn(_) {
        dispatch(UserIntentToActivateTrigger)
      })

      web_component.add_event_listener(component, "mouseleave", fn(_) {
        dispatch(UserDismissedTrigger)
      })

      web_component.add_event_listener(component, "focusin", fn(_) {
        dispatch(UserActivatedTrigger)
      })

      web_component.add_event_listener(component, "focusout", fn(_) {
        dispatch(UserDismissedTrigger)
      })
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  TooltipProvidedContext(value: Context)
  UserActivatedTrigger
  UserDismissedTrigger
  UserIntentToActivateTrigger
  UserResetDelay
  UserSetDelay(value: Int)
  WindowScheduledTimer(id: TimeoutId)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    TooltipProvidedContext(value: context) -> {
      let delay = prop.default(model.delay, context.delay)
      let model = Model(..model, delay:, open: context.open)
      let effect =
        effect.batch([
          web_component.toggle_psuedo_state("open", context.open),
          web_component.before_paint(fn(_, _, component) {
            web_component.aria_describedby(component, [context.popover])
          }),
        ])

      #(model, effect)
    }

    UserActivatedTrigger -> {
      let timeout = model.timeout
      let model = Model(..model, timeout: None)
      let effect =
        effect.batch([emit_activate(), cancel_activation_timeout(timeout)])

      #(model, effect)
    }

    UserDismissedTrigger -> {
      let timeout = model.timeout
      let model = Model(..model, timeout: None)
      let effect =
        effect.batch([emit_dismiss(), cancel_activation_timeout(timeout)])

      #(model, effect)
    }

    UserIntentToActivateTrigger if model.delay.value == 0 -> {
      let timeout = model.timeout
      let model = Model(..model, timeout: None)
      let effect =
        effect.batch([emit_activate(), cancel_activation_timeout(timeout)])

      #(model, effect)
    }

    UserIntentToActivateTrigger -> {
      let effect = case model.timeout {
        Some(_) -> effect.none()
        None if model.open -> effect.none()
        None ->
          window.set_timeout(
            model.delay.value,
            WindowScheduledTimer,
            fn(dispatch) { dispatch(UserActivatedTrigger) },
          )
      }

      #(model, effect)
    }

    UserResetDelay -> {
      let delay = case model.delay.controlled {
        True -> prop.control(model.delay, 50)
        False -> prop.default(model.delay, 50)
      }
      let model = Model(..model, delay:)
      let effect = effect.none()

      #(model, effect)
    }

    UserSetDelay(value:) -> {
      let delay = prop.control(model.delay, int.max(value, 0))
      let model = Model(..model, delay:)
      let effect = effect.none()

      #(model, effect)
    }

    WindowScheduledTimer(id:) -> {
      let existing = model.timeout
      let model = Model(..model, timeout: Some(id))
      let effect = cancel_activation_timeout(existing)

      #(model, effect)
    }
  }
}

fn cancel_activation_timeout(timeout: Option(TimeoutId)) -> Effect(Message) {
  case timeout {
    Some(id) -> window.cancel_timeout(id)
    None -> effect.none()
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: inline-block;
      }
      "
    }),
    component.default_slot([], []),
  ])
}
