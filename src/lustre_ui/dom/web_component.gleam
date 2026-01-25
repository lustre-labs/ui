// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/string
import lustre/component
import lustre/effect.{type Effect}
import lustre_ui/dom/element.{type HtmlElement}
import lustre_ui/shortid

//

///
///
pub fn tabbable(component: HtmlElement, enabled: Bool) -> Nil {
  element.set_attribute(component, "tabindex", case enabled {
    True -> "0"
    False -> "-1"
  })
}

///
///
pub fn ensure_id(component: HtmlElement) -> Nil {
  case element.attribute(component, "id") {
    Ok("") | Error(_) -> element.set_attribute(component, "id", shortid.new(6))
    Ok(_) -> Nil
  }
}

// MANIPULATIONS ---------------------------------------------------------------

///
///
pub fn role(component: HtmlElement, value: String) -> Nil {
  element.set_attribute(component, "role", value)
}

///
///
@external(javascript, "./web_component.ffi.mjs", "addEventListener")
pub fn add_event_listener(
  component: HtmlElement,
  name: String,
  handler: fn(Dynamic) -> Nil,
) -> Nil

///
///
pub fn aria_controls(component: HtmlElement, value: List(String)) -> Nil {
  element.set_attribute(component, "aria-controls", string.join(value, " "))
}

///
///
pub fn aria_describedby(component: HtmlElement, value: List(String)) -> Nil {
  element.set_attribute(component, "aria-describedby", string.join(value, " "))
}

///
///
pub fn aria_disabled(component: HtmlElement, value: Bool) -> Nil {
  element.set_attribute(component, "aria-disabled", case value {
    True -> "true"
    False -> "false"
  })
}

///
///
pub fn aria_expanded(component: HtmlElement, value: Bool) -> Nil {
  element.set_attribute(component, "aria-expanded", case value {
    True -> "true"
    False -> "false"
  })
}

///
///
pub fn aria_labelledby(component: HtmlElement, value: List(String)) -> Nil {
  element.set_attribute(component, "aria-labelledby", string.join(value, " "))
}

///
///
pub fn aria_level(component: HtmlElement, value: Int) -> Nil {
  element.set_attribute(component, "aria-level", int.to_string(value))
}

///
///
pub fn aria_orientation(component: HtmlElement, value: String) -> Nil {
  element.set_attribute(component, "aria-orientation", value)
}

///
///
pub fn aria_pressed(component: HtmlElement, value: Bool) -> Nil {
  element.set_attribute(component, "aria-pressed", case value {
    True -> "true"
    False -> "false"
  })
}

///
///
pub fn aria_selected(component: HtmlElement, value: Bool) -> Nil {
  element.set_attribute(component, "aria-selected", case value {
    True -> "true"
    False -> "false"
  })
}

///
///
pub fn id(component: HtmlElement, value: String) -> Nil {
  element.set_attribute(component, "id", value)
}

///
///
pub fn popovertarget(component: HtmlElement, value: String) -> Nil {
  element.set_attribute(component, "popovertarget", value)
}

///
///
pub fn tabindex(component: HtmlElement, value: Int) -> Nil {
  element.set_attribute(component, "tabindex", int.to_string(value))
}

// EFFECTS ---------------------------------------------------------------------

///
///
pub fn before_paint(
  run: fn(fn(message) -> Nil, Dynamic, HtmlElement) -> Nil,
) -> Effect(message) {
  use dispatch, shadow_root <- effect.before_paint
  let component = get_component_element(shadow_root)

  run(dispatch, shadow_root, component)
}

///
///
pub fn after_paint(
  run: fn(fn(message) -> Nil, Dynamic, HtmlElement) -> Nil,
) -> Effect(message) {
  use dispatch, shadow_root <- effect.after_paint
  let component = get_component_element(shadow_root)

  run(dispatch, shadow_root, component)
}

@external(javascript, "./web_component.ffi.mjs", "getComponentElement")
fn get_component_element(shadow_root: Dynamic) -> HtmlElement

///
///
pub fn toggle_psuedo_state(name: String, on: Bool) -> Effect(message) {
  case on {
    True -> component.set_pseudo_state(name)
    False -> component.remove_pseudo_state(name)
  }
}
