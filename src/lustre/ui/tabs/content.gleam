// IMPORTS ---------------------------------------------------------------------

import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/tabs/context.{type Context, type Tab}

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs-content"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      context.on_change(TabsProvidedContext),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(active: Option(Tab))
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(active: None)
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  TabsProvidedContext(value: Context)
}

fn update(_, message: Message) -> #(Model, Effect(Message)) {
  case message {
    TabsProvidedContext(value) -> {
      let model = Model(active: value.active)
      let effect = effect.none()

      #(model, effect)
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: block;
      }
      "
    }),

    case model.active {
      Some(tab) -> component.named_slot(tab.name, [], [])
      None -> element.none()
    },
  ])
}
