// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode
import gleam/json
import gleam/result
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tabs/context.{
  type Context, type Orientation, Horizontal, Vertical,
}
import lustre/ui/tabs/trigger
import lustre_ui/dom/element.{type HtmlElement} as html_element
import lustre_ui/dom/find
import lustre_ui/dom/web_component
import lustre_ui/prop.{type Prop}

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn orientation(value: Orientation) -> Attribute(message) {
  attribute("orientation", case value {
    Vertical -> "vertical"
    Horizontal -> "horizontal"
  })
}

pub fn mode(value: ActivationMode) -> Attribute(message) {
  attribute("mode", case value {
    Automatic -> "automatic"
    Manual -> "manual"
  })
}

pub fn loop(enabled: Bool) -> Attribute(message) {
  case enabled {
    True -> attribute("loop", "")
    False -> attribute.none()
  }
}

// EVENTS ----------------------------------------------------------------------

pub fn on_select(handler: fn(String) -> message) -> Attribute(message) {
  event.on("tabs/list:select", {
    use name <- decode.subfield(["detail", "name"], decode.string)

    decode.success(handler(name))
  })
}

fn emit_select(name: String) -> Effect(message) {
  event.emit("tabs/list:select", { json.object([#("name", json.string(name))]) })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs-list"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_attribute_change("orientation", fn(value) {
        case value {
          "vertical" -> Ok(ParentSetOrientation(value: Vertical))
          _ -> Ok(ParentSetOrientation(value: Horizontal))
        }
      }),

      component.on_attribute_change("loop", fn(_) { Ok(ParentToggledLoop) }),

      component.on_attribute_change("mode", fn(value) {
        case value {
          "manual" -> Ok(ParentSetMode(value: Manual))
          _ -> Ok(ParentSetMode(value: Automatic))
        }
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(mode: ActivationMode, orientation: Prop(Orientation), loop: Bool)
}

pub type ActivationMode {
  Automatic
  Manual
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(mode: Automatic, orientation: prop.new(Horizontal), loop: False)

  let effect =
    web_component.before_paint(fn(_, _, component) {
      web_component.role(component, "tablist")
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentSetMode(value: ActivationMode)
  ParentSetOrientation(value: Orientation)
  ParentToggledLoop
  TabsProvidedContext(value: Context)
  UserActivatedTrigger(name: String)
  UserNavigatedFocus(next: HtmlElement)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentSetMode(value) -> {
      let model = Model(..model, mode: value)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetOrientation(value) -> {
      let model =
        Model(..model, orientation: prop.control(model.orientation, value))
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.aria_orientation(component, case value {
            Vertical -> "vertical"
            Horizontal -> "horizontal"
          })
        })

      #(model, effect)
    }

    ParentToggledLoop -> {
      let model = Model(..model, loop: !model.loop)
      let effect = effect.none()

      #(model, effect)
    }

    TabsProvidedContext(value: context) -> {
      use <- bool.guard(model.orientation.controlled, #(model, effect.none()))
      let orientation = prop.default(model.orientation, context.orientation)
      let model = Model(..model, orientation:)
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.aria_orientation(component, case orientation.value {
            Vertical -> "vertical"
            Horizontal -> "horizontal"
          })
        })

      #(model, effect)
    }

    UserActivatedTrigger(name:) -> {
      let effect = emit_select(name)

      #(model, effect)
    }

    UserNavigatedFocus(next:) -> {
      let effect = html_element.focus(next)

      #(model, effect)
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Message) {
  let handle_focusin = {
    use target <- decode.field("target", html_element.decoder())
    let result = {
      use trigger <- result.try(html_element.closest(target, trigger.tag))
      use name <- result.try(html_element.attribute(trigger, "name"))

      Ok(name)
    }

    case result {
      Ok(trigger) if model.mode == Automatic ->
        decode.success(UserActivatedTrigger(name: trigger))

      Ok(_) | Error(_) -> decode.failure(UserActivatedTrigger(""), "")
    }
  }

  element.fragment([
    html.style([], {
      "
      :host {
        display: block;
      }
      "
    }),
  ])

  component.default_slot(
    [
      trigger.on_activate(UserActivatedTrigger),
      event.on("focusin", handle_focusin),
      event.advanced("keydown", {
        handle_keydown(model.orientation.value, model.loop)
      }),
    ],
    [],
  )
}

fn handle_keydown(
  orientation: Orientation,
  loop: Bool,
) -> decode.Decoder(event.Handler(Message)) {
  use key <- decode.field("key", decode.string)
  use tabs_list <- decode.field("currentTarget", {
    use slot <- decode.then(html_element.decoder())

    case html_element.host(slot) {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  use trigger <- decode.field("target", {
    use target <- decode.then(html_element.decoder())

    case html_element.closest(target, trigger.tag) {
      Ok(element) -> decode.success(element)
      Error(_) -> decode.failure(html_element.nil(), "")
    }
  })

  let selector = fn(element) {
    case html_element.tag(element) {
      "lustre-tabs-trigger" -> find.Accept
      _ -> find.Skip
    }
  }

  let result = case key, orientation {
    "Home", _ ->
      find.first_descendant(of: tabs_list, pierce: False, matching: selector)
      |> result.map(UserNavigatedFocus)

    "ArrowUp", Vertical | "ArrowLeft", Horizontal ->
      find.previous_descendant(
        of: tabs_list,
        before: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )
      |> result.map(UserNavigatedFocus)

    "ArrowDown", Vertical | "ArrowRight", Horizontal ->
      find.next_descendant(
        of: tabs_list,
        after: trigger,
        pierce: False,
        wrap: loop,
        matching: selector,
      )
      |> result.map(UserNavigatedFocus)

    "End", _ ->
      find.last_descendant(of: tabs_list, pierce: False, matching: selector)
      |> result.map(UserNavigatedFocus)

    _, _ -> Error(Nil)
  }

  case result {
    Ok(message) ->
      decode.success(event.handler(
        dispatch: message,
        prevent_default: True,
        stop_propagation: True,
      ))

    Error(_) ->
      decode.failure(
        event.handler(
          dispatch: UserNavigatedFocus(html_element.nil()),
          prevent_default: False,
          stop_propagation: False,
        ),
        "",
      )
  }
}
