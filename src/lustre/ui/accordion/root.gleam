// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None}
import gleam/set.{type Set}
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event.{type Handler}
import lustre/ui/accordion/context
import lustre/ui/accordion/item
import lustre/ui/accordion/panel
import lustre/ui/accordion/trigger
import lustre_ui/dom/element.{type HtmlElement} as html_element
import lustre_ui/dom/find
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

pub fn label(value: String) -> Attribute(message) {
  attribute.aria_label(value)
}

pub fn loop(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("loop", "")
    False -> attribute.none()
  }
}

pub fn orientation(value: String) -> Attribute(message) {
  attribute.aria_orientation(value)
}

pub fn type_(value: String) -> Attribute(message) {
  attribute("type", value)
}

pub fn default_value(open: List(String)) -> Attribute(message) {
  attribute("value", string.join(open, " "))
}

pub fn value(open: List(String)) -> Attribute(message) {
  case lustre.is_browser() {
    True -> attribute.property("value", json.array(open, json.string))
    False -> default_value(open)
  }
}

// EVENTS ----------------------------------------------------------------------

pub fn on_value_change(
  handler: fn(List(String)) -> message,
) -> Attribute(message) {
  event.on("accordion:change", {
    use open <- decode.field("detail", decode.list(decode.string))

    decode.success(handler(open))
  })
}

fn emit_change(open: Set(String)) -> Effect(Message) {
  event.emit("accordion:change", {
    open
    |> set.to_list
    |> json.array(json.string)
  })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-accordion"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_attribute_change("loop", fn(_) { Ok(ParentToggledLoop) }),

      component.on_attribute_change("aria-label", fn(value) {
        Ok(ParentSetLabel(value:))
      }),

      component.on_attribute_change("aria-orientation", fn(value) {
        case value {
          "horizontal" -> Ok(ParentSetOrientation(Horizontal))
          "vertical" | "" -> Ok(ParentSetOrientation(Vertical))
          _ -> Error(Nil)
        }
      }),

      component.on_attribute_change("type", fn(value) {
        case value {
          "single" | "" -> Ok(ParentSetMultiple(False))
          "multiple" -> Ok(ParentSetMultiple(True))
          _ -> Error(Nil)
        }
      }),

      component.on_attribute_change("value", fn(value) {
        Ok(ParentSetDefaultValue(string.split(value, " ")))
      }),

      component.on_property_change("value", {
        decode.list(decode.string)
        |> decode.map(ParentSetValue)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    focused: Option(HtmlElement),
    orientation: Orientation,
    loop: Bool,
    multiple: Bool,
    open: Prop(Set(String)),
  )
}

type Orientation {
  Horizontal
  Vertical
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(
      focused: None,
      orientation: Vertical,
      loop: False,
      multiple: False,
      open: Prop(value: set.new(), controlled: False, touched: False),
    )

  let effect =
    effect.batch([
      context.provide(model.open.value),
      web_component.before_paint(fn(dispatch, _, component) {
        // If the parent hasn't explicitly set the `aria-orientation` attribute
        // then we manually sprout it with the default value of "vertical". We
        // don't need to dispatch any messages here: the `Model` already defaults
        // to a vertical orientation, and if the parent did set this attribute
        // we'll receive a message to update the model accordingly.
        case html_element.attribute(component, "aria-orientation") {
          Ok("horizontal") | Ok("vertical") -> Nil
          Ok(_) | Error(_) ->
            web_component.aria_orientation(component, "vertical")
        }

        // Before we find out if this accordion is controlled or not, we need to
        // work out what its default open items are, if any. If the parent has set
        // a non-empty value attribute, then we'll receive a message about it and
        // should use that as the default. But if there is no default value we
        // can read directly on the component, we can attempt to derive it from
        // the default state of any child items.
        case html_element.attribute(component, "value") {
          Ok("") | Error(_) -> {
            let selector = item.tag <> "[open]:not([open=\"false\"])"

            let default_open =
              component
              |> html_element.query_selector_all(selector)
              |> list.filter_map(html_element.attribute(_, "name"))

            dispatch(ParentSetDefaultValue(default_open))
          }

          Ok(_) -> Nil
        }
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentSetDefaultValue(value: List(String))
  ParentSetLabel(value: String)
  ParentSetLoop(value: Bool)
  ParentSetMultiple(value: Bool)
  ParentSetOrientation(value: Orientation)
  ParentSetValue(value: List(String))
  ParentToggledLoop
  ParentToggledMultiple
  UserNavigatedFocus(next: HtmlElement)
  UserToggledItem(id: String, open: Bool)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentSetDefaultValue(value:) ->
      case model.open.controlled || model.open.touched {
        True -> #(model, effect.none())
        False -> {
          let open = Prop(..model.open, value: set.from_list(value))
          let model = Model(..model, open:)
          let effect = context.provide(open.value)

          #(model, effect)
        }
      }

    ParentSetLabel(value:) -> {
      let effect =
        web_component.before_paint(fn(_, _, component) {
          case value {
            "" -> html_element.remove_attribute(component, "role")
            _ -> web_component.role(component, "region")
          }
        })

      #(model, effect)
    }

    ParentSetLoop(value:) -> {
      let model = Model(..model, loop: value)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetMultiple(value:) -> {
      let model = Model(..model, multiple: value)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetOrientation(value:) -> {
      let model = Model(..model, orientation: value)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetValue(value:) -> {
      let open =
        Prop(..model.open, value: set.from_list(value), controlled: True)
      let model = Model(..model, open:)
      let effect = context.provide(open.value)

      #(model, effect)
    }

    ParentToggledLoop -> {
      let model = Model(..model, loop: !model.loop)
      let effect = effect.none()

      #(model, effect)
    }

    ParentToggledMultiple -> {
      let model = Model(..model, multiple: !model.multiple)
      let effect = effect.none()

      #(model, effect)
    }

    UserNavigatedFocus(next:) -> {
      let effect = html_element.focus(next)

      #(model, effect)
    }

    UserToggledItem(id:, open:) -> {
      let next = case open {
        True if model.multiple -> set.insert(model.open.value, id)
        False if model.multiple -> set.delete(model.open.value, id)
        True -> set.from_list([id])
        False -> set.new()
      }

      use <- bool.guard(model.open.controlled, #(model, emit_change(next)))

      let open = Prop(..model.open, value: next, touched: True)
      let model = Model(..model, open:)
      let effect = effect.batch([context.provide(next), emit_change(next)])

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
    component.default_slot(
      [
        event.advanced("keydown", handle_keydown(model.orientation, model.loop)),
        item.on_change(UserToggledItem),
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
  use accordion <- decode.field("currentTarget", {
    use slot <- decode.then(html_element.decoder())

    case html_element.host(slot) {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  let selector = fn(element) {
    case html_element.tag(element) {
      tag if tag == trigger.tag -> find.Accept
      // We shouldn't enter panel content to find the next trigger, so we reject
      // it to stop searching that entire subtree.
      tag if tag == panel.tag -> find.Reject
      _ -> find.Skip
    }
  }

  use trigger <- decode.field("target", {
    use target <- decode.then(html_element.decoder())

    case html_element.closest(target, trigger.tag) {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  let result = case key, orientation {
    "Home", _ ->
      find.first_descendant(of: accordion, pierce: False, matching: selector)

    "ArrowUp", Vertical | "ArrowLeft", Horizontal ->
      find.previous_descendant(
        of: accordion,
        before: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )

    "ArrowDown", Vertical | "ArrowRight", Horizontal ->
      find.next_descendant(
        of: accordion,
        after: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )

    "End", _ ->
      find.last_descendant(of: accordion, pierce: False, matching: selector)

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
