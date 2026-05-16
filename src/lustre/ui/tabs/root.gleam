// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui/tabs/content
import lustre/ui/tabs/context.{type Orientation, Horizontal, Vertical}
import lustre/ui/tabs/list
import lustre/ui/tabs/panel
import lustre/ui/tabs/trigger
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

pub fn default_value(name: String) -> Attribute(message) {
  attribute("value", name)
}

pub fn value(name: String) -> Attribute(message) {
  case lustre.is_browser() {
    True -> attribute.property("value", json.string(name))
    False -> default_value(name)
  }
}

// EVENTS ----------------------------------------------------------------------

pub fn on_value_change(handler: fn(String) -> message) -> Attribute(message) {
  event.on("tabs:change", {
    use name <- decode.subfield(["detail", "name"], decode.string)

    decode.success(handler(name))
  })
}

fn emit_change(name: String) -> Effect(Message) {
  event.emit("tabs:change", {
    json.object([
      #("name", json.string(name)),
    ])
  })
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tabs"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_attribute_change("value", fn(value) {
        Ok(ParentSetDefaultValue(value:))
      }),

      component.on_attribute_change("orientation", fn(value) {
        case value {
          "horizontal" -> Ok(ParentSetOrientation(Horizontal))
          "vertical" -> Ok(ParentSetOrientation(Vertical))
          _ -> Ok(ParentSetOrientation(Horizontal))
        }
      }),

      component.on_property_change("value", {
        decode.string
        |> decode.map(ParentSetValue)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(context: context.Context, active: Prop(Option(String)))
}

fn init(_) -> #(Model, Effect(Message)) {
  let context = context.new()
  let model =
    Model(
      context: context,
      active: Prop(value: None, controlled: False, touched: False),
    )

  let effect =
    effect.batch([
      context.provide(model.context),
      web_component.before_paint(fn(dispatch, _, component) {
        // Check for default value from attribute first
        case html_element.attribute(component, "value") {
          Ok("") | Error(_) -> {
            // If no default value set, look for initial tab in DOM
            let initial_tab =
              component
              |> html_element.query_selector(
                trigger.tag <> "[name]:not([name=\"\"])",
              )
              |> result.try(html_element.attribute(_, "name"))

            case initial_tab {
              Ok(name) -> dispatch(ParentSetDefaultValue(name))
              Error(_) -> Nil
            }
          }
          Ok(_) -> Nil
        }
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  ParentSetDefaultValue(value: String)
  ParentSetOrientation(value: Orientation)
  ParentSetValue(value: String)
  UserSelectedTab(name: String)
  UserSetPanelId(prev: Option(String), name: String, id: String)
  UserSetTriggerId(prev: Option(String), name: String, id: String)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    ParentSetDefaultValue(value:) ->
      case model.active.controlled || model.active.touched {
        True -> #(model, effect.none())
        False -> {
          let active = Prop(..model.active, value: Some(value))
          let tab = case dict.get(model.context.all, value) {
            Ok(tab) -> Some(tab)
            Error(_) -> Some(context.Tab(name: value, trigger: "", panel: ""))
          }
          let context = context.Context(..model.context, active: tab)
          let model = Model(context: context, active: active)
          let effect =
            effect.batch([context.provide(context), divert_focus(value)])

          #(model, effect)
        }
      }

    ParentSetOrientation(value:) -> {
      let context = context.Context(..model.context, orientation: value)
      let model = Model(..model, context: context)
      let effect = context.provide(context)

      #(model, effect)
    }

    ParentSetValue(value:) -> {
      let active = Prop(..model.active, value: Some(value), controlled: True)
      let tab = case dict.get(model.context.all, value) {
        Ok(tab) -> Some(tab)
        Error(_) -> Some(context.Tab(name: value, trigger: "", panel: ""))
      }
      let context = context.Context(..model.context, active: tab)
      let model = Model(context: context, active: active)
      let effect = effect.batch([context.provide(context), divert_focus(value)])

      #(model, effect)
    }

    UserSelectedTab(name:) -> {
      use <- bool.guard(model.active.value == Some(name), #(
        model,
        effect.none(),
      ))

      use <- bool.guard(model.active.controlled, #(model, emit_change(name)))

      let active = Prop(..model.active, value: Some(name), touched: True)
      let tab = case dict.get(model.context.all, name) {
        Ok(tab) -> Some(tab)
        Error(_) -> Some(context.Tab(name:, trigger: "", panel: ""))
      }

      let context = context.Context(..model.context, active: tab)
      let model = Model(context: context, active: active)
      let effect =
        effect.batch([
          context.provide(context),
          emit_change(name),
          divert_focus(name),
        ])

      #(model, effect)
    }

    UserSetPanelId(prev:, name:, id: panel) -> {
      let prev =
        prev
        |> option.to_result(Nil)
        |> result.try(dict.get(model.context.all, _))

      let next = case dict.get(model.context.all, name), prev {
        Ok(tab), _ | _, Ok(tab) -> context.Tab(..tab, panel:)
        _, _ -> context.Tab(name:, trigger: "", panel:)
      }

      let all = case prev {
        Ok(prev) ->
          model.context.all
          |> dict.delete(prev.name)
          |> dict.insert(name, next)

        Error(_) -> model.context.all |> dict.insert(name, next)
      }

      let active = case prev, model.context.active {
        Ok(prev), Some(tab) if tab.name == prev.name -> None
        _, Some(tab) if tab.name == name -> Some(next)
        _, Some(_) | _, None -> model.context.active
      }

      let context = context.Context(..model.context, all:, active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }

    UserSetTriggerId(prev:, name:, id: trigger) -> {
      let prev =
        prev
        |> option.to_result(Nil)
        |> result.try(dict.get(model.context.all, _))

      let next = case dict.get(model.context.all, name), prev {
        Ok(tab), _ | _, Ok(tab) -> context.Tab(..tab, trigger:)
        _, _ -> context.Tab(name:, trigger:, panel: "")
      }

      let all = case prev {
        Ok(prev) ->
          model.context.all
          |> dict.delete(prev.name)
          |> dict.insert(name, next)

        Error(_) -> model.context.all |> dict.insert(name, next)
      }

      let active = case prev, model.context.active {
        Ok(prev), Some(tab) if tab.name == prev.name -> None
        _, Some(tab) if tab.name == name -> Some(next)
        _, Some(_) | _, None -> model.context.active
      }

      let context = context.Context(..model.context, all:, active:)
      let model = Model(..model, context:)
      let effect = context.provide(context)

      #(model, effect)
    }
  }
}

fn divert_focus(name: String) -> Effect(message) {
  use _, _, component <- web_component.before_paint
  let _ = {
    use active <- result.try(document.active_element())

    // Check if focus was currently inside the tabs content container.
    use content <- result.try(html_element.closest(active, content.tag))
    use <- bool.guard(!html_element.contains(component, content), Error(Nil))

    // Find the trigger that was just activated, but only if it wasn't already
    // selected: we don't want to mess with focus if nothing is actually changing.
    use trigger <- result.try(
      html_element.query_selector(component, {
        "${list} > ${trigger}[name=\"${name}\":not([aria-selected=\"true\"])"
        |> string.replace("${list}", list.tag)
        |> string.replace("${trigger}", trigger.tag)
        |> string.replace("${name}", name)
      }),
    )

    // Focus the trigger so that keyboard users aren't left stranded once the
    // panel changes.
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
        list.on_select(UserSelectedTab),
        trigger.on_identify(UserSetTriggerId),
        panel.on_identify(UserSetPanelId),
      ],
      [],
    ),
  ])
}
