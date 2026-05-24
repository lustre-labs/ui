// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode
import gleam/json
import gleam/result
import gleam/set
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/accordion/context.{type Context}
import lustre/ui/accordion/heading
import lustre/ui/accordion/panel
import lustre/ui/accordion/trigger
import lustre_ui/dom/document
import lustre_ui/dom/element as html_element
import lustre_ui/dom/web_component
import lustre_ui/prop.{type Prop, Prop}

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn open(value: Bool) -> Attribute(message) {
  attribute.property("open", json.bool(value))
}

pub fn default_open(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("open", "")
    False -> attribute.none()
  }
}

pub fn name(value: String) -> Attribute(message) {
  attribute.name(value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(String, Bool) -> message) -> Attribute(message) {
  event.on("accordion/item:change", {
    use id <- decode.subfield(["detail", "id"], decode.string)
    use open <- decode.subfield(["detail", "open"], decode.bool)

    decode.success(handler(id, open))
  })
}

fn emit_change(id: String, open: Bool) -> Effect(message) {
  let show_hide = case open {
    True -> "accordion/item:show"
    False -> "accordion/item:hide"
  }

  effect.batch([
    event.emit(show_hide, json.object([#("id", json.string(id))])),
    event.emit("accordion/item:change", {
      json.object([
        #("id", json.string(id)),
        #("open", json.bool(open)),
      ])
    }),
  ])
}

pub fn on_show(message: fn(String) -> message) -> Attribute(message) {
  event.on("accordion/item:show", {
    use id <- decode.subfield(["detail", "id"], decode.string)

    decode.success(message(id))
  })
}

pub fn on_hide(message: fn(String) -> message) -> Attribute(message) {
  event.on("accordion/item:hide", {
    use id <- decode.subfield(["detail", "id"], decode.string)

    decode.success(message(id))
  })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-accordion-item"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),

      component.on_connect(ComponentConnectedToDom),
      component.on_disconnect(ComponentDisconnectedFromDom),

      component.on_attribute_change("name", fn(value) {
        Ok(ParentSetName(value))
      }),

      component.on_attribute_change("open", fn(value) {
        case value {
          "true" -> Ok(ParentSetDefaultOpen(True))
          "false" -> Ok(ParentSetDefaultOpen(False))
          "" -> Ok(ParentToggledDefaultOpen)
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
  Model(name: String, panel: String, open: Prop(Bool))
}

fn init(_) -> #(Model, Effect(Message)) {
  let open = Prop(value: False, controlled: False, touched: False)

  let model = Model(name: "", panel: "", open:)
  let effect =
    effect.batch([
      context.provide_item(model.name, model.panel, False),
      // If the user has explicitly set an id on the panel, we'll miss the event
      // emit because we haven't had a chance to render and attach event listeners
      // so instead we can query the DOM directly.
      web_component.before_paint(fn(dispatch, _, component) {
        let result =
          component
          |> html_element.query_selector(panel.tag)
          |> result.try(html_element.attribute(_, "id"))

        case result {
          Ok(id) -> dispatch(UserSetPanelId(id))
          Error(_) -> Nil
        }
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  AccordionProvidedContext(context: Context)
  ComponentConnectedToDom
  ComponentDisconnectedFromDom
  ParentSetDefaultOpen(value: Bool)
  ParentSetName(value: String)
  ParentSetOpen(value: Bool)
  ParentToggledDefaultOpen
  UserPressedTrigger
  UserSetPanelId(value: String)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    AccordionProvidedContext(..) if model.open.controlled -> {
      #(model, effect.none())
    }

    AccordionProvidedContext(context) -> {
      let open =
        Prop(..model.open, touched: True, value: {
          set.contains(context.open, model.name)
        })

      let model = Model(..model, open:)
      let effect = case model.open.value {
        True ->
          effect.batch([
            context.provide_item(model.name, model.panel, open.value),
            component.set_pseudo_state("open"),
          ])

        False ->
          effect.batch([
            context.provide_item(model.name, model.panel, open.value),
            component.remove_pseudo_state("open"),
            divert_focus(),
          ])
      }

      #(model, effect)
    }

    ComponentConnectedToDom -> {
      let effect = context.on_change(AccordionProvidedContext)

      #(model, effect)
    }

    ComponentDisconnectedFromDom -> {
      let effect = effect.unsubscribe("accordion")

      #(model, effect)
    }

    ParentSetDefaultOpen(value:) ->
      case model.open.controlled || model.open.touched {
        True -> #(model, effect.none())
        False -> {
          let open = Prop(..model.open, value:)
          let model = Model(..model, open:)
          let effect = case model.open.value {
            True ->
              effect.batch([
                context.provide_item(model.name, model.panel, open.value),
                component.set_pseudo_state("open"),
              ])

            False ->
              effect.batch([
                context.provide_item(model.name, model.panel, open.value),
                component.remove_pseudo_state("open"),
                divert_focus(),
              ])
          }
          #(model, effect)
        }
      }

    ParentSetName(value:) -> {
      let model = Model(..model, name: value)
      let effect =
        context.provide_item(model.name, model.panel, model.open.value)

      #(model, effect)
    }

    ParentSetOpen(value:) -> {
      let open = Prop(value:, controlled: True, touched: True)
      let model = Model(..model, open:)
      let effect = case model.open.value {
        True ->
          effect.batch([
            context.provide_item(model.name, model.panel, open.value),
            component.set_pseudo_state("open"),
          ])

        False ->
          effect.batch([
            context.provide_item(model.name, model.panel, open.value),
            component.remove_pseudo_state("open"),
            divert_focus(),
          ])
      }

      #(model, effect)
    }

    ParentToggledDefaultOpen ->
      case model.open.controlled || model.open.touched {
        True -> #(model, effect.none())
        False -> {
          let open = Prop(..model.open, value: !model.open.value)
          let model = Model(..model, open:)
          let effect = case model.open.value {
            True ->
              effect.batch([
                context.provide_item(model.name, model.panel, open.value),
                component.set_pseudo_state("open"),
              ])

            False ->
              effect.batch([
                context.provide_item(model.name, model.panel, open.value),
                component.remove_pseudo_state("open"),
                divert_focus(),
              ])
          }

          #(model, effect)
        }
      }

    UserPressedTrigger ->
      case model.open.controlled {
        True -> {
          let next = !model.open.value
          let effect = emit_change(model.name, next)

          #(model, effect)
        }

        False -> {
          let open = Prop(..model.open, value: !model.open.value, touched: True)
          let model = Model(..model, open:)
          let effect = case model.open.value {
            True ->
              effect.batch([
                emit_change(model.name, model.open.value),
                context.provide_item(model.name, model.panel, model.open.value),
                component.set_pseudo_state("open"),
              ])

            False ->
              effect.batch([
                emit_change(model.name, model.open.value),
                context.provide_item(model.name, model.panel, model.open.value),
                component.remove_pseudo_state("open"),
                divert_focus(),
              ])
          }

          #(model, effect)
        }
      }

    UserSetPanelId(value:) -> {
      let model = Model(..model, panel: value)
      let effect =
        context.provide_item(model.name, model.panel, model.open.value)

      #(model, effect)
    }
  }
}

fn divert_focus() -> Effect(message) {
  use _, _, component <- web_component.before_paint
  let _ = {
    use active <- result.try(document.active_element())
    use item <- result.try(html_element.closest(active, tag))

    use <- bool.guard(!html_element.is(item, component), Error(Nil))
    use trigger <- result.try(html_element.query_selector(
      component,
      heading.tag <> " > " <> trigger.tag,
    ))

    Ok(html_element.do_focus(trigger))
  }

  Nil
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

    component.default_slot(
      [
        panel.on_identify(UserSetPanelId),
        trigger.on_activate(UserPressedTrigger),
      ],
      [],
    ),
  ])
}
