// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/checkbox_internal/context as checkbox_context
import lustre/ui/menu_internal/context.{type Context}
import lustre/ui_internal/host
import lustre/ui_internal/keyboard_listener
import lustre/ui_internal/value.{type Value, Controlled, Uncontrolled}

// COMPONENT -------------------------------------------------------------------

pub fn register() -> Result(Nil, lustre.Error) {
  lustre.register(
    lustre.component(init:, update:, view:, options: options()),
    context.menu_item_tag,
  )
}

// ELEMENTS --------------------------------------------------------------------

pub fn root(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element(context.menu_item_tag, attributes, children)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn checkbox() -> Attribute(msg) {
  attribute("type", "checkbox")
}

pub fn value(value: String) -> Attribute(msg) {
  attribute("value", value)
}

pub fn checked(value: Bool) -> Attribute(msg) {
  case lustre.is_browser() {
    True -> attribute.property("checked", json.bool(value))
    False if value -> default_checked()
    False -> attribute.none()
  }
}

pub fn default_checked() -> Attribute(msg) {
  attribute("checked", "")
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(String, String) -> msg) -> Attribute(msg) {
  event.on("lustre-ui:menu-item-change", {
    use prev <- decode.subfield(["detail", "prev"], decode.string)
    use next <- decode.subfield(["detail", "next"], decode.string)

    decode.success(handler(prev, next))
  })
}

pub fn on_select(handler: fn(String) -> msg) -> Attribute(msg) {
  event.on("lustre-ui:menu-item-select", {
    use value <- decode.subfield(["detail", "value"], decode.string)

    decode.success(handler(value))
  })
}

pub fn on_toggle(handler: fn(String, Bool) -> msg) -> Attribute(msg) {
  event.on("lustre-ui:menu-item-toggle", {
    use value <- decode.subfield(["detail", "value"], decode.string)
    use checked <- decode.subfield(["detail", "checked"], decode.bool)

    decode.success(handler(value, checked))
  })
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    kind: Type,
    value: String,
    active: Option(String),
    /// This only makes sense when the `kind` is `Checkbox`.
    checked: Value(Bool),
  )
}

type Type {
  Item
  Checkbox
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model =
    Model(
      kind: Item,
      value: "",
      active: None,
      checked: Uncontrolled(value: False, default: False, touched: False),
    )
  let effect =
    effect.batch([
      host.set_role("menuitem"),
      host.add_event_listener("click", decode.success(UserClickedItem)),
    ])

  #(model, effect)
}

fn options() -> List(component.Option(Msg)) {
  [
    component.on_attribute_change("checked", fn(value) {
      case value {
        // Lustre unfortunately can't report when an attribute was removed, best
        // it can do is report it as an empty string. An empty string is also the
        // value when the attribute is present so when a value is missing we report
        // is as "toggled" and use app logic to determine whether that means
        // added or removed.
        "" -> Ok(ParentToggledDefaultChecked)
        _ -> Ok(ParentSetDefaultChecked)
      }
    }),

    component.on_attribute_change("type", fn(value) {
      case value {
        "checkbox" -> Ok(ParentSetType(kind: Checkbox))
        _ -> Ok(ParentSetType(kind: Item))
      }
    }),

    component.on_attribute_change("value", fn(value) {
      Ok(ParentSetValue(value:))
    }),

    component.on_property_change(
      "checked",
      decode.bool |> decode.map(ParentSetChecked),
    ),

    context.on_change(ParentProvidedContext),

    component.delegates_focus(True),
  ]
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentProvidedContext(value: Context)
  ParentSetChecked(value: Bool)
  ParentSetDefaultChecked
  ParentSetType(kind: Type)
  ParentSetValue(value: String)
  ParentToggledDefaultChecked
  UserClickedItem
  UserPressedEnter
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentProvidedContext(value:) -> {
      let model = Model(..model, active: value.active)
      let effect = case model.active == Some(model.value) {
        True -> component.set_pseudo_state("active")
        False -> component.remove_pseudo_state("active")
      }

      #(model, effect)
    }

    ParentSetChecked(value:) -> {
      let model = Model(..model, checked: Controlled(value:))
      let effect = case model.kind {
        Checkbox -> set_checked(model.checked.value)
        Item -> effect.none()
      }

      #(model, effect)
    }

    ParentSetDefaultChecked -> {
      let checked = model.checked

      case checked {
        Controlled(..) -> #(model, effect.none())

        Uncontrolled(touched: True, ..) -> {
          let checked = Uncontrolled(..checked, default: True)
          let model = Model(..model, checked:)

          #(model, effect.none())
        }

        Uncontrolled(..) -> {
          let checked = Uncontrolled(value: True, default: True, touched: False)
          let model = Model(..model, checked:)

          #(model, effect.none())
        }
      }
    }

    ParentSetType(kind:) -> {
      let model = Model(..model, kind:)
      let effect = case kind {
        Item -> host.set_role("menuitem")
        Checkbox ->
          effect.batch([
            host.set_role("menuitemcheckbox"),
            set_checked(model.checked.value),
          ])
      }

      #(model, effect)
    }

    ParentSetValue(value:) -> {
      let prev = model.value
      let model = Model(..model, value:)
      let effect = case model.value != prev {
        True -> emit_change(prev, model.value)
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentToggledDefaultChecked -> {
      // We have to make this binding because Gleam's variant inference is not
      // smart enough to work through record access.
      let checked = model.checked

      case checked {
        Controlled(..) -> #(model, effect.none())

        Uncontrolled(touched: True, ..) -> {
          let checked = Uncontrolled(..checked, default: !checked.default)
          let model = Model(..model, checked:)

          #(model, effect.none())
        }

        Uncontrolled(value:, ..) -> {
          let value = !value
          let checked = Uncontrolled(value:, default: value, touched: False)
          let model = Model(..model, checked:)
          let effect = set_checked(value)

          #(model, effect)
        }
      }
    }

    UserClickedItem | UserPressedEnter ->
      case model.kind {
        Item -> {
          let effect = emit_select(model.value)

          #(model, effect)
        }

        Checkbox -> {
          let checked = model.checked

          case checked {
            Controlled(..) -> {
              let effect =
                effect.batch([
                  set_checked(checked.value),
                  emit_select(model.value),
                  emit_toggle(model.value, !checked.value),
                ])

              #(model, effect)
            }

            Uncontrolled(..) -> {
              let checked =
                Uncontrolled(..checked, value: !checked.value, touched: True)
              let model = Model(..model, checked:)
              let effect =
                effect.batch([
                  set_checked(checked.value),
                  emit_select(model.value),
                  emit_toggle(model.value, checked.value),
                ])

              #(model, effect)
            }
          }
        }
      }
  }
}

fn set_checked(value: Bool) -> Effect(msg) {
  effect.batch([
    set_aria_checked(value),
    case value {
      True ->
        checkbox_context.provide(checkbox_context.new(checkbox_context.On))
      False ->
        checkbox_context.provide(checkbox_context.new(checkbox_context.Off))
    },
    case value {
      True -> component.set_pseudo_state("checked")
      False -> component.remove_pseudo_state("checked")
    },
  ])
}

fn set_aria_checked(value: Bool) -> Effect(msg) {
  use _, shadow_root <- effect.before_paint
  do_set_aria_checked(shadow_root, value)
}

@external(javascript, "./item.ffi.mjs", "set_aria_checked")
fn do_set_aria_checked(shadow_root: Dynamic, aria_checked: Bool) -> Nil

fn emit_change(old_value: String, new_value: String) -> Effect(msg) {
  event.emit(
    "lustre-ui:menu-item-change",
    json.object([
      #("prev", json.string(old_value)),
      #("next", json.string(new_value)),
    ]),
  )
}

fn emit_select(value: String) -> Effect(msg) {
  event.emit(
    "lustre-ui:menu-item-select",
    json.object([#("value", json.string(value))]),
  )
}

fn emit_toggle(value: String, checked: Bool) -> Effect(msg) {
  event.emit(
    "lustre-ui:menu-item-toggle",
    json.object([
      #("value", json.string(value)),
      #("checked", json.bool(checked)),
    ]),
  )
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.style([], {
      "
      :host {
        display: block;
        cursor: pointer;
      }

      ::slotted(*) {
        user-select: none;
      }
      "
    }),

    keyboard_listener.root(
      attributes: [
        attribute.tabindex(case model.active {
          Some(active) if active == model.value -> 0
          Some(_) -> -1
          None -> 0
        }),
        attribute.autofocus(model.active == Some(model.value)),
      ],
      keymap: [
        #(" ", event.handler(UserPressedEnter, True, True)),
        #("Enter", event.handler(UserPressedEnter, True, True)),
      ],
    ),

    component.default_slot([], []),
  ])
}
