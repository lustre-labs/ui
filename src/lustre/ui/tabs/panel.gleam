// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tabs/context.{type Context}
import lustre_ui/dom/find
import lustre_ui/dom/web_component
import lustre_ui/shortid

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_identify(
  handler: fn(Option(String), String, String) -> message,
) -> Attribute(message) {
  event.on("tabs/panel:identify", {
    use previous_name <- decode.subfield(["detail", "previous_name"], {
      decode.optional(decode.string)
    })
    use name <- decode.subfield(["detail", "name"], decode.string)
    use id <- decode.subfield(["detail", "id"], decode.string)

    decode.success(handler(previous_name, name, id))
  })
}

fn emit_identify(
  previous_name: Option(String),
  name: String,
  id: String,
) -> Effect(message) {
  event.emit("tabs/panel:identify", {
    json.object([
      #("previous_name", case previous_name {
        Some(name) -> json.string(name)
        None -> json.null()
      }),
      #("name", json.string(name)),
      #("id", json.string(id)),
    ])
  })
}

pub fn on_open(handler: fn(String) -> message) -> Attribute(message) {
  event.on("tabs/panel:open", {
    use name <- decode.subfield(["detail", "name"], decode.string)
    decode.success(handler(name))
  })
}

fn emit_open(name: String) -> Effect(message) {
  event.emit("tabs/panel:open", { json.object([#("name", json.string(name))]) })
}

pub fn on_close(handler: fn(String) -> message) -> Attribute(message) {
  event.on("tabs/panel:close", {
    use name <- decode.subfield(["detail", "name"], decode.string)
    decode.success(handler(name))
  })
}

fn emit_close(name: String) -> Effect(message) {
  event.emit("tabs/panel:close", { json.object([#("name", json.string(name))]) })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs-panel"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      context.on_change(TabsProvidedContext),
      component.on_attribute_change("id", fn(value) {
        case value {
          "" -> Ok(ParentRemovedId)
          id -> Ok(ParentSetId(value: id))
        }
      }),

      component.on_attribute_change("slot", fn(value) {
        case value {
          "" -> Ok(ParentRemovedName)
          name -> Ok(ParentSetName(value: name))
        }
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(name: String, id: String, context: Context)
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(name: "", id: "", context: context.new())
  let effect =
    web_component.before_paint(fn(_, _, component) {
      web_component.ensure_id(component)
      web_component.role(component, "tabpanel")
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentRemovedId
  ParentRemovedName
  ParentSetId(value: String)
  ParentSetName(value: String)
  TabsProvidedContext(value: Context)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentRemovedId -> {
      let model = Model(..model, id: "")
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.id(component, shortid.new(6))
        })

      #(model, effect)
    }

    ParentRemovedName -> {
      let model = Model(..model, name: "")
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetId(value:) -> {
      let model = Model(..model, id: value)
      let effect = emit_identify(None, model.name, model.id)

      #(model, effect)
    }

    ParentSetName(value:) -> {
      let prev = case model.name {
        "" -> None
        name if name == value -> None
        name -> Some(name)
      }

      let model = Model(..model, name: value)
      let effect = emit_identify(prev, model.name, model.id)

      #(model, effect)
    }

    TabsProvidedContext(value: context) -> {
      let prev = model.context.active
      let #(did_open, did_close) = case prev, context.active {
        Some(old), Some(new) if old.name == model.name -> #(False, old != new)
        Some(old), Some(new) if new.name == model.name -> #(old != new, False)
        Some(old), None -> #(False, old.name == model.name)
        None, Some(new) -> #(new.name == model.name, False)
        _, _ -> #(False, False)
      }

      let model = Model(..model, context:)
      let effect =
        effect.batch([
          web_component.before_paint(fn(_, _, component) {
            case dict.get(context.all, model.name) {
              Ok(tab) -> web_component.aria_labelledby(component, [tab.trigger])
              Error(_) -> Nil
            }
          }),

          web_component.before_paint(fn(_, _, component) {
            use <- bool.guard(!did_open, Nil)

            let first_tabbable_child =
              find.first_descendant(
                of: component,
                pierce: True,
                matching: fn(element) {
                  case find.is_tabbable(element) {
                    True -> find.Accept
                    False -> find.Skip
                  }
                },
              )

            web_component.tabbable(
              component,
              result.is_error(first_tabbable_child),
            )
          }),

          effect.batch(case did_open {
            True -> [
              emit_open(model.name),
              component.set_pseudo_state("active"),
            ]
            False -> []
          }),

          effect.batch(case did_close {
            True -> [
              emit_close(model.name),
              component.remove_pseudo_state("active"),
            ]
            False -> []
          }),
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
        display: block;
      }
      "
    }),
    html.slot([], []),
  ])
}
