// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/toggle/context.{type GroupContext}
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

pub fn default_pressed(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("pressed", "")
    False -> attribute.none()
  }
}

pub fn pressed(value: Bool) -> Attribute(message) {
  attribute.property("pressed", json.bool(value))
}

pub fn value(value: String) -> Attribute(message) {
  attribute("value", value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_press(handler: fn(Bool) -> message) -> Attribute(message) {
  event.on("toggle:press", {
    use pressed <- decode.field("detail", decode.bool)

    decode.success(handler(pressed))
  })
}

fn emit_press(pressed: Bool) -> Effect(message) {
  event.emit("toggle:press", json.bool(pressed))
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-toggle"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.form_associated(),
      context.on_group_change(ToggleGroupProvidedContext),

      component.on_attribute_change("disabled", fn(value) {
        case value {
          "" -> Ok(ParentToggledDisabled)
          _ -> Ok(ParentSetDisabled)
        }
      }),

      component.on_attribute_change("pressed", fn(value) {
        case value {
          "" -> Ok(ParentToggledDefaultPressed)
          _ -> Ok(ParentSetDefaultPressed(value: True))
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

      component.on_property_change("pressed", {
        decode.bool |> decode.map(ParentSetPressed)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(pressed: Prop(Bool), value: String, disabled: Prop(Bool))
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(pressed: prop.new(False), value: "on", disabled: prop.new(False))

  let effect =
    web_component.before_paint(fn(dispatch, _, component) {
      web_component.aria_pressed(component, False)
      web_component.role(component, "button")
      web_component.tabindex(component, 0)

      web_component.add_event_listener(component, "click", fn(_) {
        dispatch(UserPressedToggle)
      })

      web_component.add_event_listener(component, "keydown", fn(event) {
        case decode.run(event, decode.at(["key"], decode.string)) {
          Ok("Enter") | Ok(" ") -> {
            html_event.prevent_default(event)
            dispatch(UserPressedToggle)
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
  ParentSetDefaultPressed(value: Bool)
  ParentSetDisabled
  ParentSetPressed(value: Bool)
  ParentSetValue(value: String)
  ParentToggledDefaultPressed
  ParentToggledDisabled
  ToggleGroupProvidedContext(context: GroupContext)
  UserPressedToggle
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

    ParentSetDefaultPressed(value:) -> {
      let pressed = prop.default(model.pressed, value)
      let did_change = pressed.value != model.pressed.value
      use <- bool.guard(!did_change, #(model, effect.none()))

      let model = Model(..model, pressed:)
      let effect = case model.pressed.value {
        True ->
          effect.batch([
            component.set_form_value(model.value),
            component.set_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, True)
            }),
          ])

        False ->
          effect.batch([
            component.clear_form_value(),
            component.remove_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, False)
            }),
          ])
      }

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

    ParentSetPressed(value:) -> {
      let pressed = prop.control(model.pressed, value)
      let did_change = pressed.value != model.pressed.value
      let model = Model(..model, pressed:)
      use <- bool.guard(!did_change, #(model, effect.none()))

      let effect = case value {
        True ->
          effect.batch([
            component.set_form_value(model.value),
            component.set_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, True)
            }),
          ])

        False ->
          effect.batch([
            component.clear_form_value(),
            component.remove_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, False)
            }),
          ])
      }

      #(model, effect)
    }

    ParentSetValue(value:) -> {
      let model = Model(..model, value:)
      let effect = case model.pressed.value {
        True -> component.set_form_value(value)
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentToggledDefaultPressed -> {
      let pressed = prop.default(model.pressed, !model.pressed.value)
      let did_change = pressed.value != model.pressed.value
      use <- bool.guard(!did_change, #(model, effect.none()))

      let model = Model(..model, pressed:)
      let effect = case model.pressed.value {
        True ->
          effect.batch([
            component.set_form_value(model.value),
            component.set_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, True)
            }),
          ])

        False ->
          effect.batch([
            component.clear_form_value(),
            component.remove_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, False)
            }),
          ])
      }

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

    ToggleGroupProvidedContext(..) if model.pressed.controlled -> {
      #(model, effect.none())
    }

    ToggleGroupProvidedContext(context:) -> {
      let pressed =
        prop.touch(model.pressed, context.value == Some(model.value))
      let disabled = prop.touch(model.disabled, context.disabled)
      let model = Model(..model, pressed:, disabled:)
      let effect =
        effect.batch([
          web_component.toggle_psuedo_state("pressed", model.pressed.value),
          web_component.before_paint(fn(_, _, component) {
            web_component.aria_disabled(component, model.disabled.value)
            web_component.aria_pressed(component, model.pressed.value)
            web_component.tabindex(component, case model.pressed.value {
              True -> 0
              False if context.value == None -> 0
              False -> -1
            })
          }),
          web_component.toggle_psuedo_state("disabled", model.disabled.value),
        ])

      #(model, effect)
    }

    UserPressedToggle if model.disabled.value -> {
      #(model, effect.none())
    }

    UserPressedToggle if model.pressed.controlled -> {
      let effect = emit_press(!model.pressed.value)

      #(model, effect)
    }

    UserPressedToggle -> {
      let pressed = prop.touch(model.pressed, !model.pressed.value)
      use <- bool.guard(pressed.controlled, #(model, emit_press(pressed.value)))

      let model = Model(..model, pressed:)
      let effect = case model.pressed.value {
        True ->
          effect.batch([
            emit_press(True),
            component.set_form_value(model.value),
            component.set_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, True)
            }),
          ])

        False ->
          effect.batch([
            emit_press(False),
            component.clear_form_value(),
            component.remove_pseudo_state("pressed"),
            web_component.before_paint(fn(_, _, component) {
              web_component.aria_pressed(component, False)
            }),
          ])
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
