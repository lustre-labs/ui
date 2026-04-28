// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/json
import gleam/list
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
import lustre/ui/tooltip/context.{type Context, Context}
import lustre_ui/dom/element.{type HtmlElement} as html_element
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

pub fn offset(amount: Float) -> Attribute(message) {
  attribute("offset", float.to_string(amount))
}

pub fn side(value: String) -> Attribute(message) {
  attribute("side", value)
}

pub fn align(value: String) -> Attribute(message) {
  attribute("align", value)
}

pub fn default_open(value: Bool) -> Attribute(message) {
  case value {
    True -> attribute("value", "true")
    False -> attribute("value", "false")
  }
}

pub fn open(value: Bool) -> Attribute(message) {
  case lustre.is_browser() {
    True -> attribute.property("open", json.bool(value))
    False -> default_open(value)
  }
}

// EVENTS ----------------------------------------------------------------------

pub fn on_identify(handler: fn(String) -> message) -> Attribute(message) {
  event.on("tooltip/popover:identify", {
    use id <- decode.field("detail", decode.string)

    decode.success(handler(id))
  })
}

fn emit_identify(id: String) -> Effect(message) {
  event.emit("tooltip/popover:identify", json.string(id))
}

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-tooltip-popover"

///
///
pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      context.on_change(TooltipProvidedContext),
      component.on_attribute_change("id", fn(value) { Ok(ParentSetId(value:)) }),
      component.on_attribute_change("offset", fn(value) {
        let number =
          int.parse(value)
          |> result.map(int.to_float)
          |> result.lazy_or(fn() { float.parse(value) })

        case number {
          Ok(value) -> Ok(ParentSetOffset(value:))
          Error(_) -> Ok(ParentResetOffset)
        }
      }),

      component.on_attribute_change("side", fn(value) {
        case value {
          "top" | "right" | "bottom" | "left" -> Ok(ParentSetSide(value))
          _ -> Ok(ParentResetSide)
        }
      }),

      component.on_attribute_change("align", fn(value) {
        case value {
          "start" | "end" -> Ok(ParentSetAlign(value))
          _ -> Ok(ParentResetAlign)
        }
      }),

      component.on_attribute_change("open", fn(value) {
        case value {
          "" -> Ok(ParentToggledDefaultOpen)
          _ -> Ok(ParentSetDefaultOpen)
        }
      }),

      component.on_property_change("open", {
        decode.bool
        |> decode.map(ParentSetOpen)
      }),
    ])

  lustre.register(component, tag)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    open: Prop(Bool),
    x: Float,
    y: Float,
    offset: Float,
    side: String,
    align: Option(String),
  )
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(
      open: prop.new(False),
      x: 0.0,
      y: 0.0,
      offset: 0.0,
      side: "top",
      align: None,
    )

  let effect =
    effect.batch([
      recalculate_position(model.offset, model.side, model.align),
      set_placement_pseudo_state(model.side, model.align),
      web_component.before_paint(fn(_, _, component) {
        web_component.ensure_id(component)
        web_component.role(component, "tooltip")

        html_element.set_attribute(component, "popover", "hint")
      }),
    ])

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  DomCalculatedPosition(x: Float, y: Float)
  ParentResetAlign
  ParentResetOffset
  ParentResetSide
  ParentSetAlign(value: String)
  ParentSetDefaultOpen
  ParentSetId(value: String)
  ParentSetOffset(value: Float)
  ParentSetOpen(value: Bool)
  ParentSetSide(value: String)
  ParentToggledDefaultOpen
  TooltipProvidedContext(value: Context)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    DomCalculatedPosition(x:, y:) -> {
      echo #(x, y)
      let model = Model(..model, x:, y:)
      let effect = case model.open.value {
        True -> component.set_pseudo_state("open")
        False -> effect.none()
      }

      #(model, effect)
    }

    ParentResetAlign -> {
      let model = Model(..model, align: None)
      let effect =
        effect.batch([
          recalculate_position(model.offset, model.side, model.align),
          set_placement_pseudo_state(model.side, model.align),
        ])

      #(model, effect)
    }

    ParentResetOffset -> {
      let model = Model(..model, offset: 0.0)
      let effect = recalculate_position(model.offset, model.side, model.align)

      #(model, effect)
    }

    ParentResetSide -> {
      let model = Model(..model, side: "top")
      let effect =
        effect.batch([
          recalculate_position(model.offset, model.side, model.align),
          set_placement_pseudo_state(model.side, model.align),
        ])

      #(model, effect)
    }

    ParentSetAlign(value:) -> {
      let model = Model(..model, align: Some(value))
      let effect =
        effect.batch([
          recalculate_position(model.offset, model.side, model.align),
          set_placement_pseudo_state(model.side, model.align),
        ])

      #(model, effect)
    }

    ParentSetDefaultOpen -> {
      use <- bool.guard(model.open.controlled, #(model, effect.none()))
      use <- bool.guard(model.open.touched, #(model, effect.none()))
      use <- bool.guard(model.open.value, #(model, effect.none()))

      let open = prop.default(model.open, True)
      let model = Model(..model, open:)
      let effect =
        effect.batch(case open.value {
          True -> [show_popover(model.offset, model.side, model.align)]
          False -> [hide_popover(), component.remove_pseudo_state("open")]
        })

      #(model, effect)
    }

    ParentSetId(value: "") -> {
      let effect =
        web_component.before_paint(fn(_, _, component) {
          web_component.ensure_id(component)
        })

      #(model, effect)
    }

    ParentSetId(value:) -> {
      let effect = emit_identify(value)

      #(model, effect)
    }

    ParentSetOffset(value:) -> {
      let model = Model(..model, offset: value)
      let effect = recalculate_position(model.offset, model.side, model.align)

      #(model, effect)
    }

    ParentSetOpen(value:) -> {
      let prev = model.open.value
      let open = prop.control(model.open, value)
      let model = Model(..model, open:)
      use <- bool.guard(prev == open.value, #(model, effect.none()))

      let effect =
        effect.batch(case open.value {
          True -> [show_popover(model.offset, model.side, model.align)]
          False -> [hide_popover(), component.remove_pseudo_state("open")]
        })

      #(model, effect)
    }

    ParentSetSide(value:) -> {
      let model = Model(..model, side: value)
      let effect =
        effect.batch([
          recalculate_position(model.offset, model.side, model.align),
          set_placement_pseudo_state(model.side, model.align),
        ])

      #(model, effect)
    }

    ParentToggledDefaultOpen -> {
      use <- bool.guard(model.open.controlled, #(model, effect.none()))
      use <- bool.guard(model.open.touched, #(model, effect.none()))

      let open = prop.default(model.open, !model.open.value)
      let model = Model(..model, open:)
      let effect =
        effect.batch(case open.value {
          True -> [show_popover(model.offset, model.side, model.align)]
          False -> [hide_popover(), component.remove_pseudo_state("open")]
        })

      #(model, effect)
    }

    TooltipProvidedContext(value: Context(open:, ..)) -> {
      use <- bool.guard(model.open.controlled, #(model, effect.none()))
      use <- bool.guard(open == model.open.value, #(model, effect.none()))

      let model = Model(..model, open: prop.touch(model.open, open))
      let effect =
        effect.batch(case open {
          True -> [show_popover(model.offset, model.side, model.align)]
          False -> [hide_popover(), component.remove_pseudo_state("open")]
        })

      #(model, effect)
    }
  }
}

const sides = ["top", "right", "bottom", "left"]

const alignments = ["start", "end"]

fn set_placement_pseudo_state(
  side: String,
  align: Option(String),
) -> Effect(message) {
  effect.batch([
    component.set_pseudo_state(side),
    case align {
      Some(align) -> component.set_pseudo_state(align)
      None -> effect.none()
    },
    remove_pseudo_states(side, align),
  ])
}

fn remove_pseudo_states(
  side: String,
  alignment: Option(String),
) -> Effect(message) {
  effect.batch([
    sides
      |> list.filter(fn(s) { s != side })
      |> list.map(component.remove_pseudo_state)
      |> effect.batch,
    alignments
      |> list.filter(fn(a) { Some(a) != alignment })
      |> list.map(component.remove_pseudo_state)
      |> effect.batch,
  ])
}

fn show_popover(
  offset offset: Float,
  side side: String,
  align align: Option(String),
) -> Effect(Message) {
  use dispatch, _, component <- web_component.before_paint
  use x, y <- do_show_popover(
    floating: component,
    offset:,
    side:,
    align: option.unwrap(align, ""),
  )

  dispatch(DomCalculatedPosition(x:, y:))
}

@external(javascript, "./popover.ffi.mjs", "showPopover")
fn do_show_popover(
  floating component: HtmlElement,
  offset offset: Float,
  side side: String,
  align align: String,
  callback callback: fn(Float, Float) -> Nil,
) -> Nil

fn recalculate_position(
  offset offset: Float,
  side side: String,
  align align: Option(String),
) -> Effect(Message) {
  use dispatch, _, component <- web_component.before_paint
  use x, y <- do_recalculate_position(
    floating: component,
    offset:,
    side:,
    align: option.unwrap(align, ""),
  )

  dispatch(DomCalculatedPosition(x:, y:))
}

@external(javascript, "./popover.ffi.mjs", "calculatePosition")
fn do_recalculate_position(
  floating component: HtmlElement,
  offset offset: Float,
  side side: String,
  align align: String,
  callback callback: fn(Float, Float) -> Nil,
) -> Nil

fn hide_popover() -> Effect(Message) {
  use _, _, component <- web_component.after_paint

  do_hide_popover(component)
}

@external(javascript, "./popover.ffi.mjs", "hidePopover")
fn do_hide_popover(component: HtmlElement) -> Nil

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        --tooltip-popover-x: ${x}px;
        --tooltip-popover-y: ${y}px;

        display: ${display};
      }
      "
      |> string.replace("${x}", float.to_string(model.x))
      |> string.replace("${y}", float.to_string(model.y))
      |> string.replace("${display}", case model.open.value {
        True -> "inline"
        False -> "none"
      })
    }),

    component.default_slot([attribute.inert(True)], []),
  ])
}
