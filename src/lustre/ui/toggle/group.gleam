// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event.{type Handler}
import lustre/ui/toggle/context
import lustre_ui/dom/element.{type HtmlElement} as html_element
import lustre_ui/dom/find
import lustre_ui/dom/web_component
import lustre_ui/prop.{type Prop}

// ELEMENTS --------------------------------------------------------------------

pub fn root(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element(tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn disabled(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("disabled", "")
    False -> attribute.none()
  }
}

pub fn loop(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("loop", "")
    False -> attribute.none()
  }
}

pub fn orientation(value: String) -> Attribute(message) {
  attribute("orientation", value)
}

pub fn default_value(value: Option(String)) -> Attribute(message) {
  case value {
    Some(v) -> attribute("value", v)
    None -> attribute.none()
  }
}

pub fn value(value: Option(String)) -> Attribute(message) {
  attribute.property("value", {
    case value {
      Some(v) -> json.string(v)
      None -> json.null()
    }
  })
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Option(String)) -> message) -> Attribute(message) {
  event.on("toggle/group:change", {
    use value <- decode.field("detail", decode.optional(decode.string))

    decode.success(handler(value))
  })
}

fn emit_change(value: Option(String)) -> Effect(message) {
  event.emit("toggle/group:change", {
    case value {
      None -> json.null()
      Some(v) -> json.string(v)
    }
  })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-toggle-group"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.form_associated(),
      component.on_attribute_change("disabled", fn(value) {
        case value {
          "" -> Ok(ParentToggledDisabled)
          _ -> Ok(ParentSetDisabled)
        }
      }),

      component.on_attribute_change("loop", fn(value) {
        case value {
          "" -> Ok(ParentToggledLoop)
          _ -> Ok(ParentSetLoop)
        }
      }),

      component.on_attribute_change("orientation", fn(value) {
        case value {
          "horizontal" -> Ok(ParentSetOrientation(Horizontal))
          "vertical" | "" -> Ok(ParentSetOrientation(Vertical))
          _ -> Error(Nil)
        }
      }),

      component.on_attribute_change("value", fn(value) {
        case value {
          "" -> Ok(ParentSetDefaultValue(None))
          _ -> Ok(ParentSetDefaultValue(Some(value)))
        }
      }),

      component.on_property_change("value", {
        use value <- decode.then(decode.optional(decode.string))

        case value {
          Some("") -> decode.success(ParentSetValue(None))
          Some(_) | None -> decode.success(ParentSetValue(value))
        }
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    value: Prop(Option(String)),
    disabled: Bool,
    orientation: Orientation,
    loop: Bool,
  )
}

type Orientation {
  Horizontal
  Vertical
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(
      value: prop.new(None),
      disabled: False,
      orientation: Horizontal,
      loop: False,
    )

  let effect =
    effect.batch([
      context.provide_group(model.value.value, model.disabled),
      web_component.before_paint(fn(_, _, component) {
        web_component.role(component, "group")

        case html_element.attribute(component, "orientation") {
          Ok("horizontal" as orientation) | Ok("vertical" as orientation) ->
            web_component.aria_orientation(component, orientation)

          Ok(_) | Error(_) ->
            web_component.aria_orientation(component, "horizontal")
        }
        // TODO: read the `pressed` attribute of any children to set a default.
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentSetDefaultValue(Option(String))
  ParentSetDisabled
  ParentSetLoop
  ParentSetOrientation(Orientation)
  ParentSetValue(Option(String))
  ParentToggledDisabled
  ParentToggledLoop
  UserNavigatedFocus(next: HtmlElement)
  UserToggledItem(value: String, pressed: Bool)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentSetDefaultValue(value) ->
      case model.value.controlled || model.value.touched {
        True -> #(model, effect.none())
        False -> {
          let value = prop.default(model.value, value)
          let model = Model(..model, value:)
          let effect = effect.none()

          #(model, effect)
        }
      }

    ParentSetDisabled -> {
      let model = Model(..model, disabled: True)
      let effect =
        effect.batch([
          web_component.toggle_psuedo_state("disabled", model.disabled),
          context.provide_group(model.value.value, model.disabled),
        ])

      #(model, effect)
    }

    ParentSetLoop -> {
      let model = Model(..model, loop: True)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetOrientation(value) -> {
      let model = Model(..model, orientation: value)
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.aria_orientation(component, case value {
            Horizontal -> "horizontal"
            Vertical -> "vertical"
          })
        })

      #(model, effect)
    }

    ParentSetValue(value) -> {
      let value = prop.control(model.value, value)
      let model = Model(..model, value:)
      let effect = case value.value {
        Some(v) ->
          effect.batch([
            context.provide_group(value.value, model.disabled),
            component.set_form_value(v),
          ])
        None ->
          effect.batch([
            context.provide_group(value.value, model.disabled),
            component.clear_form_value(),
          ])
      }

      #(model, effect)
    }

    ParentToggledDisabled -> {
      let model = Model(..model, disabled: !model.disabled)
      let effect =
        effect.batch([
          web_component.toggle_psuedo_state("disabled", model.disabled),
          context.provide_group(model.value.value, model.disabled),
        ])

      #(model, effect)
    }

    ParentToggledLoop -> {
      let model = Model(..model, loop: !model.loop)
      let effect = effect.none()

      #(model, effect)
    }

    UserNavigatedFocus(next:) -> {
      let effect = html_element.focus(next)

      #(model, effect)
    }

    UserToggledItem(value:, pressed:) -> {
      let next = case pressed {
        True -> Some(value)
        False -> None
      }

      use <- bool.guard(model.value.controlled, #(model, emit_change(next)))
      let model = Model(..model, value: prop.touch(model.value, next))
      let effect =
        effect.batch([
          context.provide_group(next, model.disabled),
          emit_change(next),
          case next {
            Some(v) -> component.set_form_value(v)
            None -> component.clear_form_value()
          },
        ])

      #(model, effect)
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Message) {
  let handle_press = {
    use target <- decode.field("target", html_element.decoder())
    use pressed <- decode.field("detail", decode.bool)

    case html_element.attribute(target, "value") {
      Ok("") | Error(_) ->
        decode.failure(UserToggledItem(value: "", pressed:), "")
      Ok(value) -> decode.success(UserToggledItem(value:, pressed:))
    }
  }

  element.fragment([
    html.style([], {
      "
      :host {
        display: inline;
      }
      "
    }),
    component.default_slot(
      [
        event.on("toggle:press", handle_press),
        event.advanced("keydown", handle_keydown(model.orientation, model.loop)),
      ],
      [],
    ),
  ])
}

fn handle_keydown(
  orientation: Orientation,
  loop: Bool,
) -> Decoder(Handler(Message)) {
  use key <- decode.field("key", decode.string)
  use group <- decode.field("currentTarget", {
    use slot <- decode.then(html_element.decoder())

    case html_element.host(slot) {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  use trigger <- decode.field("target", {
    use target <- decode.then(html_element.decoder())

    case html_element.closest(target, "lustre-toggle") {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  let selector = fn(element) {
    case html_element.tag(element) {
      "lustre-toggle" -> find.Accept
      _ -> find.Skip
    }
  }

  let result = case key, orientation {
    "ArrowUp", Vertical | "ArrowLeft", Horizontal ->
      find.previous_descendant(
        of: group,
        before: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )

    "ArrowDown", Vertical | "ArrowRight", Horizontal ->
      find.next_descendant(
        of: group,
        after: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )

    _, _ -> Error(Nil)
  }

  use next <- decode.then(case result {
    Ok(element) -> decode.success(element)
    Error(_) -> decode.failure(html_element.nil(), "")
  })

  decode.success(event.handler(
    dispatch: UserNavigatedFocus(next),
    prevent_default: True,
    stop_propagation: True,
  ))
}
