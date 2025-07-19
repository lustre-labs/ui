// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/string
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ffi/dom

// TYPES -----------------------------------------------------------------------

pub type Anchor {
  TopLeft
  TopMiddle
  TopRight
  RightTop
  RightMiddle
  RightBottom
  BottomLeft
  BottomMiddle
  BottomRight
  LeftTop
  LeftMiddle
  LeftBottom
}

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-popover"

pub fn register() -> Result(Nil, lustre.Error) {
  let app =
    lustre.component(init, update, view, [
      component.adopt_styles(True),
      component.on_attribute_change("aria-expanded", fn(value) {
        case value {
          "true" | "" -> Ok(ParentSetOpen(True))
          "false" -> Ok(ParentSetOpen(False))
          _ -> Error(Nil)
        }
      }),
    ])

  lustre.register(app, name)
}

pub fn element(
  attributes: List(Attribute(msg)),
  trigger trigger: Element(msg),
  content content: Element(msg),
) -> Element(msg) {
  element.element(name, attributes, [
    html.div([attribute("slot", "trigger")], [trigger]),
    html.div([attribute("slot", "popover")], [content]),
  ])
}

// ATTRIBUTES ------------------------------------------------------------------

/// The `popover` primitive is a "controlled" component. That means it doesn't
/// manage its own state but instead relies on a parent component to manage the
/// open/closed state.
///
pub fn open(is_open: Bool) -> Attribute(msg) {
  attribute("aria-expanded", bool.to_string(is_open) |> string.lowercase)
}

///
///
pub fn anchor(direction: Anchor) -> Attribute(msg) {
  attribute("anchor", case direction {
    TopLeft -> "top-left"
    TopMiddle -> "top-middle"
    TopRight -> "top-right"
    RightTop -> "right-top"
    RightMiddle -> "right-middle"
    RightBottom -> "right-bottom"
    BottomLeft -> "bottom-left"
    BottomMiddle -> "bottom-middle"
    BottomRight -> "bottom-right"
    LeftTop -> "left-top"
    LeftMiddle -> "left-middle"
    LeftBottom -> "left-bottom"
  })
}

/// By default, the popover's content is sized intrinsically. This means the content
/// can be smaller or larger than the trigger element based on what's inside it.
///
/// Setting the `equal_width` attribute will make the popover's content match the
/// width of the trigger element. This is useful for elements like comboboxes and
/// selects where the user typically expects the popover to be the same width as
/// the trigger.
///
pub fn equal_width() -> Attribute(msg) {
  attribute("equal-width", "")
}

// STYLES ----------------------------------------------------------------------

/// By default, the `popover` primitive has a small gap between the trigger and
/// the popover content based on your theme configuration. You can use this function
/// to override that gap, or remove it entirely.
///
pub fn gap(value: String) -> Attribute(msg) {
  attribute.style("--gap", value)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_change(handler: fn(Bool) -> msg) -> Attribute(msg) {
  event.on("change", {
    use is_open <- decode.subfield(["detail", "open"], decode.bool)

    decode.success(handler(is_open))
  })
}

pub fn on_open(handler: msg) -> Attribute(msg) {
  event.on("open", decode.success(handler))
}

pub fn on_close(handler: msg) -> Attribute(msg) {
  event.on("close", decode.success(handler))
}

// MODEL -----------------------------------------------------------------------

type Model {
  WillExpand
  Expanded
  WillCollapse
  Collapsing
  Collapsed
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = Collapsed
  let effect = effect.batch([component.set_pseudo_state("collapsed")])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {

  ParentSetOpen(Bool)
  SchedulerDidTick
  TransitionDidEnd
  UserPressedTrigger(event: Dynamic)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case echo msg, model {
    ParentSetOpen(True), WillCollapse | ParentSetOpen(True), Collapsed -> #(
      WillExpand,
      effect.batch([tick(), component.set_pseudo_state("will-expand")]),
    )

    ParentSetOpen(True), _ -> #(model, effect.none())

    ParentSetOpen(False), WillExpand | ParentSetOpen(False), Expanded -> #(
      WillCollapse,
      effect.batch([tick(), component.set_pseudo_state("will-collapse")]),
    )

    ParentSetOpen(False), _ -> #(model, effect.none())

    SchedulerDidTick, WillExpand -> #(
      Expanded,
      component.set_pseudo_state("expanded"),
    )

    SchedulerDidTick, WillCollapse -> #(
      Collapsing,
      component.set_pseudo_state("collapsing"),
    )

    SchedulerDidTick, _ -> #(model, effect.none())

    TransitionDidEnd, Collapsing -> #(
      Collapsed,
      component.set_pseudo_state("collapsed"),
    )

    TransitionDidEnd, _ -> #(model, effect.none())

    UserPressedTrigger(event:), WillExpand
    | UserPressedTrigger(event:), Expanded
    -> #(
      model,
      effect.batch([
        event.emit("close", json.null()),
        event.emit("change", json.object([#("open", json.bool(False))])),
        dom.prevent_default(event),
      ]),
    )

    UserPressedTrigger(event:), WillCollapse
    | UserPressedTrigger(event:), Collapsing
    | UserPressedTrigger(event:), Collapsed
    -> #(
      model,
      effect.batch([
        event.emit("open", json.null()),
        event.emit("change", json.object([#("open", json.bool(True))])),
        dom.prevent_default(event),
      ]),
    )
  }
}

// EFFECTS ---------------------------------------------------------------------

fn tick() -> Effect(Msg) {
  use dispatch, _ <- effect.after_paint

  dispatch(SchedulerDidTick)
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.style("position", "relative")], [
    view_trigger(),
    view_popover(model),
  ])
}

fn view_trigger() -> Element(Msg) {
  html.slot(
    [
      attribute.name("trigger"),
      event.on("click", decode.map(decode.dynamic, UserPressedTrigger)),
      event.on("keydown", handle_keydown()),
    ],
    [],
  )
}

fn handle_keydown() -> Decoder(Msg) {
  use event <- decode.then(decode.dynamic)
  use key <- decode.field("key", decode.string)

  case key {
    "Enter" | " " -> decode.success(UserPressedTrigger(event:))
    _ -> decode.failure(UserPressedTrigger(event:), "")
  }
}

fn view_popover(model: Model) -> Element(Msg) {
  use <- bool.guard(model == Collapsed, html.text(""))

  html.div(
    [
      attribute("part", "popover-content"),
      event.on("transitionend", decode.success(TransitionDidEnd)),
    ],
    [html.slot([attribute.name("popover")], [])],
  )
}
