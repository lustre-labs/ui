// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/ui/checkbox_internal/context.{type Context}

// COMPONENT -------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    context.checkbox_indicator_tag,
  )
}

// ELEMENTS --------------------------------------------------------------------

pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(context.checkbox_indicator_tag, attributes, children)
}

// MODEL -----------------------------------------------------------------------

type Model =
  Context

fn init(_) -> #(Model, Effect(Msg)) {
  let model = context.new(context.Off)
  let effect = effect.none()

  #(model, effect)
}

fn options() -> List(component.Option(Msg)) {
  [context.on_change(ParentProvidedContext)]
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentProvidedContext(value: Context)
}

fn update(_, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentProvidedContext(value:) -> #(value, effect.none())
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: inline;
      }
      "
    }),

    case model.checked {
      context.On -> component.default_slot([], [])
      context.Indeterminate -> component.named_slot("indeterminate", [], [])
      context.Off -> element.none()
    },
  ])
}
