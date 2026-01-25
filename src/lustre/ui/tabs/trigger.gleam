// IMPORTS ---------------------------------------------------------------------

import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tabs/context.{type Context, type Tab}
import lustre_ui/dom/web_component

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn name(value: String) -> Attribute(message) {
  attribute("name", value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_identify(
  handler: fn(Option(String), String, String) -> message,
) -> Attribute(message) {
  event.on("tabs/trigger:identify", {
    use previous <- decode.subfield(["detail", "previous_name"], {
      decode.optional(decode.string)
    })
    use name <- decode.subfield(["detail", "name"], decode.string)
    use id <- decode.subfield(["detail", "id"], decode.string)

    decode.success(handler(previous, name, id))
  })
}

fn emit_identify(
  previous_name: Option(String),
  name: String,
  id: String,
) -> Effect(message) {
  event.emit("tabs/trigger:identify", {
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

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs-trigger"

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

      component.on_attribute_change("name", fn(value) {
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
  Model(name: String, id: String, active: Option(Tab))
}

fn init(_) -> #(Model, Effect(Message)) {
  let model = Model(name: "", id: "", active: None)
  let effect =
    web_component.before_paint(fn(_, _, component) {
      web_component.role(component, "tab")
      web_component.ensure_id(component)
      web_component.tabbable(component, False)
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
    ParentRemovedId | ParentSetId(value: "") -> {
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.ensure_id(component)
        })

      #(model, effect)
    }

    ParentSetId(value:) -> {
      let model = Model(..model, id: value)
      let effect = case model.name != "" {
        True -> emit_identify(None, model.name, model.id)
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentRemovedName | ParentSetName(value: "") -> {
      let model = Model(..model, name: "")
      let effect = activate(model.name, model.active)

      #(model, effect)
    }

    ParentSetName(value:) -> {
      let previous = case model.name {
        "" -> None
        name if name == value -> None
        name -> Some(name)
      }

      let model = Model(..model, name: value)
      let effect =
        effect.batch([
          activate(model.name, model.active),

          case model.id != "" {
            True -> emit_identify(previous, model.name, model.id)
            False -> effect.none()
          },
        ])

      #(model, effect)
    }

    TabsProvidedContext(value:) -> {
      let model = Model(..model, active: value.active)
      let effect =
        effect.batch([
          activate(model.name, model.active),

          web_component.before_paint(fn(_, _, component) {
            case dict.get(value.all, model.name) {
              Ok(tab) -> web_component.aria_controls(component, [tab.panel])
              Error(_) -> web_component.aria_controls(component, [])
            }
          }),
        ])

      #(model, effect)
    }
  }
}

fn activate(name: String, active: Option(Tab)) -> Effect(message) {
  case active {
    Some(tab) if tab.name == name ->
      effect.batch([
        component.set_pseudo_state("active"),
        web_component.before_paint(fn(_, _, component) {
          web_component.tabbable(component, True)
          web_component.aria_selected(component, True)
        }),
      ])

    Some(_) | None ->
      effect.batch([
        component.remove_pseudo_state("active"),
        web_component.before_paint(fn(_, _, component) {
          web_component.tabbable(component, False)
          web_component.aria_selected(component, False)
        }),
      ])
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
