// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/accordion/context.{type ItemContext}
import lustre_ui/dom/event as html_event
import lustre_ui/dom/web_component

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-accordion-trigger"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      context.on_item_change(AccordionItemProvidedContext),
    ])

  lustre.register(component, tag)
}

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_activate(handler: message) -> Attribute(message) {
  event.on("accordion/trigger:activate", decode.success(handler))
}

fn emit_activate() -> Effect(message) {
  event.emit("accordion/trigger:activate", json.object([]))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model
  let effect =
    web_component.before_paint(fn(dispatch, _, component) {
      web_component.role(component, "button")
      web_component.tabindex(component, 0)

      web_component.add_event_listener(component, "click", fn(_) {
        dispatch(UserActivatedTrigger)
      })

      web_component.add_event_listener(component, "keydown", fn(event) {
        case decode.run(event, decode.at(["key"], decode.string)) {
          Ok("Enter") | Ok(" ") -> {
            html_event.prevent_default(event)
            dispatch(UserActivatedTrigger)
          }

          Ok(_) | Error(_) -> Nil
        }
      })
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  AccordionItemProvidedContext(ItemContext)
  UserActivatedTrigger
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    AccordionItemProvidedContext(context) -> {
      let effect =
        effect.batch([
          web_component.before_paint(fn(_, _, element) {
            web_component.aria_controls(element, [context.panel])
            web_component.aria_expanded(element, context.open)
          }),

          web_component.toggle_psuedo_state("open", context.open),
        ])

      #(model, effect)
    }

    UserActivatedTrigger -> #(model, emit_activate())
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        cursor: default;
        display: inline;
        user-select: none;
      }
      "
    }),
    component.default_slot([], []),
  ])
}
