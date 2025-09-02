// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/ui/menu_internal/context
import lustre/ui_internal/host

// COMPONENT -------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  lustre.register(
    lustre.application(init:, update:, view:),
    context.menu_item_separator_tag,
  )
}

// ELEMENTS --------------------------------------------------------------------

pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(context.menu_item_separator_tag, attributes, children)
}

// MODEL -----------------------------------------------------------------------

type Model =
  Nil

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Nil
  let effect = host.set_role("separator")

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg =
  Nil

fn update(_, _) -> #(Model, Effect(Msg)) {
  #(Nil, effect.none())
}

// VIEW ------------------------------------------------------------------------

fn view(_) -> Element(Msg) {
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
