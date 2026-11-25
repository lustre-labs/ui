// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode
import gleam/json
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre_ui/dom/event as html_event
import lustre_ui/dom/web_component
import lustre_ui/prop.{type Prop}

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

pub fn disabled(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("disabled", "")
    False -> attribute.none()
  }
}

pub fn default_checked(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("checked", "")
    False -> attribute.none()
  }
}

pub fn checked(value: Bool) -> Attribute(message) {
  attribute.property("checked", json.bool(value))
}

pub fn value(value: String) -> Attribute(message) {
  attribute("value", value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Bool) -> message) -> Attribute(message) {
  event.on("switch:change", {
    use checked <- decode.field("detail", decode.bool)

    decode.success(handler(checked))
  })
}

fn emit_change(checked: Bool) -> Effect(message) {
  event.emit("switch:change", json.bool(checked))
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-switch"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.form_associated(),

      component.on_attribute_change("checked", fn(value) {
        case value {
          "" -> Ok(ParentToggledDefaultChecked)
          _ -> Ok(ParentSetDefaultChecked(value: True))
        }
      }),

      component.on_attribute_change("disabled", fn(value) {
        case value {
          "" -> Ok(ParentToggledDisabled)
          _ -> Ok(ParentSetDisabled)
        }
      }),

      component.on_attribute_change("tabindex", fn(value) {
        case value {
          "" -> Ok(ParentRemovedTabindex)
          _ -> Error(Nil)
        }
      }),

      component.on_attribute_change("value", fn(value) {
        case value {
          "" -> Ok(ParentSetValue(value: "on"))
          _ -> Ok(ParentSetValue(value:))
        }
      }),

      component.on_property_change("checked", {
        decode.bool |> decode.map(ParentSetChecked)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(checked: Prop(Bool), value: String, disabled: Prop(Bool))
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(checked: prop.new(False), value: "on", disabled: prop.new(False))

  let effect =
    web_component.before_paint(fn(dispatch, _, component) {
      web_component.aria_checked(component, False)
      web_component.role(component, "switch")
      web_component.tabindex(component, 0)

      web_component.add_event_listener(component, "click", fn(_) {
        dispatch(UserToggledSwitch)
      })

      web_component.add_event_listener(component, "keydown", fn(event) {
        case decode.run(event, decode.at(["key"], decode.string)) {
          Ok("Enter") | Ok(" ") -> {
            html_event.prevent_default(event)
            dispatch(UserToggledSwitch)
          }

          Ok(_) | Error(_) -> Nil
        }
      })
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentRemovedTabindex
  ParentSetChecked(value: Bool)
  ParentSetDefaultChecked(value: Bool)
  ParentSetDisabled
  ParentSetValue(value: String)
  ParentToggledDefaultChecked
  ParentToggledDisabled
  UserToggledSwitch
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentRemovedTabindex -> {
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.tabindex(component, 0)
        })

      #(model, effect)
    }

    ParentSetChecked(value:) -> {
      let checked = prop.control(model.checked, value)
      let did_change = checked.value != model.checked.value
      let model = Model(..model, checked:)
      use <- bool.guard(!did_change, #(model, effect.none()))

      let effect = check(model.checked.value, model.value)

      #(model, effect)
    }

    ParentSetDefaultChecked(value:) -> {
      let checked = prop.default(model.checked, value)
      let did_change = checked.value != model.checked.value
      use <- bool.guard(!did_change, #(model, effect.none()))

      let model = Model(..model, checked:)
      let effect = check(model.checked.value, model.value)

      #(model, effect)
    }

    ParentSetDisabled -> {
      let disabled = prop.control(model.disabled, True)
      let model = Model(..model, disabled:)
      let effect =
        effect.batch([
          web_component.before_paint(fn(_, _, component) {
            web_component.aria_disabled(component, model.disabled.value)
          }),
          web_component.toggle_psuedo_state("disabled", model.disabled.value),
        ])

      #(model, effect)
    }

    ParentSetValue(value:) -> {
      let model = Model(..model, value:)
      let effect = case model.checked.value {
        True -> component.set_form_value(value)
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentToggledDefaultChecked -> {
      let checked = prop.default(model.checked, !model.checked.value)
      let did_change = checked.value != model.checked.value
      use <- bool.guard(!did_change, #(model, effect.none()))

      let model = Model(..model, checked:)
      let effect = check(model.checked.value, model.value)

      #(model, effect)
    }

    ParentToggledDisabled -> {
      let disabled = prop.control(model.disabled, !model.disabled.value)
      let model = Model(..model, disabled:)
      let effect =
        effect.batch([
          web_component.before_paint(fn(_, _, component) {
            web_component.aria_disabled(component, model.disabled.value)
          }),
          web_component.toggle_psuedo_state("disabled", model.disabled.value),
        ])

      #(model, effect)
    }

    UserToggledSwitch if model.disabled.value -> {
      #(model, effect.none())
    }

    UserToggledSwitch if model.checked.controlled -> {
      let effect = emit_change(!model.checked.value)

      #(model, effect)
    }

    UserToggledSwitch -> {
      let checked = prop.touch(model.checked, !model.checked.value)
      let model = Model(..model, checked:)
      let effect =
        effect.batch([
          emit_change(model.checked.value),
          check(model.checked.value, model.value),
        ])

      #(model, effect)
    }
  }
}

fn check(checked: Bool, value: String) -> Effect(message) {
  case checked {
    True ->
      effect.batch([
        component.set_form_value(value),
        component.set_pseudo_state("checked"),
        web_component.before_paint(fn(_, _, component) {
          web_component.aria_checked(component, True)
        }),
      ])

    False ->
      effect.batch([
        component.clear_form_value(),
        component.remove_pseudo_state("checked"),
        web_component.before_paint(fn(_, _, component) {
          web_component.aria_checked(component, False)
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
        display: inline;
        cursor: default;
        user-select: none;
        -webkit-user-select: none;
      }
      "
    }),
    component.default_slot([], []),
  ])
}
