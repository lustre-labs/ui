// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre_ui/dom/web_component

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-accordion-trigger"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_context_change("accordion/item", {
        use name <- decode.field("name", decode.string)
        use panel <- decode.field("panel", decode.string)
        use open <- decode.field("open", decode.bool)

        decode.success(AccordionItemProvidedContext(name:, panel:, open:))
      }),
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

// MODEL -----------------------------------------------------------------------

type Model {
  Model
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model
  let effect =
    web_component.before_paint(fn(_, _, element) {
      web_component.role(element, "button")
      web_component.tabindex(element, 0)
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  AccordionItemProvidedContext(name: String, panel: String, open: Bool)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    AccordionItemProvidedContext(name: _, panel:, open:) -> {
      let effect =
        effect.batch([
          web_component.before_paint(fn(_, _, element) {
            web_component.aria_controls(element, [panel])
            web_component.aria_expanded(element, open)
          }),

          case open {
            True -> component.set_pseudo_state("open")
            False -> component.remove_pseudo_state("open")
          },
        ])

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
        cursor: default;
        display: inline;
        user-select: none;
      }
      "
    }),
    component.default_slot([], []),
  ])
}
