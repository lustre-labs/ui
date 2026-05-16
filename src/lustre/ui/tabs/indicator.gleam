// IMPORTS ---------------------------------------------------------------------

import gleam/float
import gleam/option
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/tabs/context.{type Context}
import lustre/ui/tabs/list as tabslist
import lustre/ui/tabs/root
import lustre/ui/tabs/trigger
import lustre_ui/dom/element as html_element
import lustre_ui/dom/web_component

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs-indicator"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_connect(ComponentConnectedToDom),
      component.on_disconnect(ComponentDisconnectedFromDom),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(x: Float, y: Float, width: Float, height: Float)
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
  let effect =
    web_component.before_paint(fn(_, _, component) {
      web_component.role(component, "presentation")
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ComponentConnectedToDom
  ComponentDisconnectedFromDom
  TabsProvidedContext(Context)
  TriggerProvidedBounds(left: Float, top: Float, width: Float, height: Float)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ComponentConnectedToDom -> {
      let effect = context.on_change(TabsProvidedContext)

      #(model, effect)
    }

    ComponentDisconnectedFromDom -> {
      let effect = effect.unsubscribe(context.tabs)

      #(model, effect)
    }

    TabsProvidedContext(context.Context(active: option.None, ..)) -> {
      let model = Model(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
      let effect = effect.none()

      #(model, effect)
    }

    TabsProvidedContext(context.Context(active: option.Some(active), ..)) -> {
      let effect =
        web_component.before_paint(fn(dispatch, _, component) {
          let result = {
            use root <- result.try(html_element.closest(component, root.tag))
            use list <- result.try(
              html_element.query_selector(root, tabslist.tag)
              |> result.map(html_element.bounding_client_rect),
            )

            let selector = trigger.tag <> "[name=\"" <> active.name <> "\"]"
            use trigger <- result.try(
              html_element.query_selector(root, selector)
              |> result.map(html_element.bounding_client_rect),
            )

            let x = trigger.0 -. list.0
            let y = trigger.1 -. list.1

            Ok(#(x, y, trigger.2, trigger.3))
          }

          case result {
            Ok(bounds) ->
              dispatch(TriggerProvidedBounds(
                left: bounds.0,
                top: bounds.1,
                width: bounds.2,
                height: bounds.3,
              ))

            Error(_) -> Nil
          }
        })

      #(model, effect)
    }

    TriggerProvidedBounds(left:, top:, width:, height:) -> {
      let model = Model(x: left, y: top, width: width, height: height)
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
        display: inline;

        --indicator-x: ${x}px;
        --indicator-y: ${y}px;
        --indicator-width: ${width}px;
        --indicator-height: ${height}px;
      }
      "
      |> string.replace("${x}", float.to_string(model.x))
      |> string.replace("${y}", float.to_string(model.y))
      |> string.replace("${width}", float.to_string(model.width))
      |> string.replace("${height}", float.to_string(model.height))
    }),

    component.default_slot([attribute.inert(True)], []),
  ])
}
