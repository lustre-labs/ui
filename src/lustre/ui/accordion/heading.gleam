// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre_ui/dom/element as html_element
import lustre_ui/dom/web_component

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

// EVENTS ----------------------------------------------------------------------

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-ui-accordion-heading"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_context_change("accordion/item", {
        use open <- decode.field("open", decode.bool)

        decode.success(AccordionItemProvidedContext(open:))
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(open: Bool)
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(open: False)
  let effect =
    web_component.before_paint(fn(_, _, component) {
      web_component.role(component, "heading")

      case html_element.attribute(component, "aria-level") {
        Ok("") | Error(_) -> web_component.aria_level(component, 3)
        Ok(_) -> Nil
      }
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  AccordionItemProvidedContext(open: Bool)
}

fn update(_, message: Message) -> #(Model, Effect(Message)) {
  case message {
    AccordionItemProvidedContext(open:) -> {
      let model = Model(open:)
      let effect = case open {
        True -> component.set_pseudo_state("open")
        False -> component.remove_pseudo_state("open")
      }

      #(model, effect)
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: block;
      }
      "
    }),
    component.default_slot([], []),
  ])
}
