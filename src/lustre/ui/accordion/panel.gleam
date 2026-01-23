// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json
import gleam/string
import lustre
import lustre/attribute.{type Attribute}
import lustre/component
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre_ui/dom/element as html_element
import lustre_ui/dom/web_component
import lustre_ui/shortid

// COMPONENT -------------------------------------------------------------------

pub const tag: String = "lustre-accordion-panel"

pub fn register() -> Result(Nil, lustre.Error) {
  let component =
    lustre.component(init:, update:, view:, options: [
      component.adopt_styles(False),
      component.on_context_change("accordion/item", {
        use name <- decode.field("name", decode.string)
        use open <- decode.field("open", decode.bool)

        decode.success(AccordionItemProvidedContext(name:, open:))
      }),

      component.on_attribute_change("id", fn(value) { Ok(ParentSetId(value:)) }),
    ])

  lustre.register(component, tag)
}

// ELEMENTS --------------------------------------------------------------------

pub fn element(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  element.element(tag, attributes, children)
}

// EVENTS ----------------------------------------------------------------------

pub fn on_identify(handler: fn(String) -> message) -> Attribute(message) {
  event.on("accordion/panel:identify", {
    use id <- decode.field("detail", decode.string)

    decode.success(handler(id))
  })
}

fn emit_identify(id: String) -> Effect(message) {
  event.emit("accordion/panel:identify", json.string(id))
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    id: String,
    open: ExpandedState,
    force_mount: Bool,
    width: String,
    height: String,
  )
}

type ExpandedState {
  Collapsed
  Indeterminate
  Expanded
}

fn init(_) -> #(Model, Effect(Message)) {
  let model =
    Model(
      id: "",
      open: Indeterminate,
      force_mount: False,
      width: "0px",
      height: "0px",
    )

  let effect =
    // Modify our own `id` attribute iff the parent didn't set one when they
    // rendered this component. This will trigger the `on_attribute_change` handler
    // we defined to emit our identity to the parent accordion item.
    //
    // We do it this way to avoid double-setting the `id` attribute if the parent
    // already set one and also to sidestep any issues around trampling on user-set
    // values.
    web_component.before_paint(fn(_, _, element) {
      web_component.role(element, "region")

      case html_element.attribute(element, "id") {
        Ok("") | Error(_) -> web_component.id(element, shortid.new(6))
        Ok(_) -> Nil
      }
    })

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Message {
  AccordionItemProvidedContext(name: String, open: Bool)
  PanelMeasuredDimensions(width: String, height: String)
  ParentSetId(value: String)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    AccordionItemProvidedContext(name: _, open: True) ->
      case model.open {
        Collapsed -> {
          let model = Model(..model, open: Expanded)
          let effect =
            effect.batch([
              component.set_pseudo_state("open"),
              animate(True),
            ])

          #(model, effect)
        }

        Indeterminate -> {
          let model =
            Model(..model, open: Expanded, width: "auto", height: "auto")
          let effect = component.set_pseudo_state("open")

          #(model, effect)
        }

        Expanded -> #(model, effect.none())
      }

    AccordionItemProvidedContext(name: _, open: False) ->
      case model.open {
        Expanded -> {
          let model = Model(..model, open: Collapsed)
          let effect =
            effect.batch([
              component.remove_pseudo_state("open"),
              animate(False),
            ])

          #(model, effect)
        }

        Indeterminate -> {
          let model =
            Model(..model, open: Collapsed, width: "0px", height: "0px")
          let effect = component.remove_pseudo_state("open")

          #(model, effect)
        }

        Collapsed -> #(model, effect.none())
      }

    PanelMeasuredDimensions(width:, height:) -> {
      let model = Model(..model, width:, height:)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetId(value:) -> {
      let model = Model(..model, id: value)
      let effect = emit_identify(model.id)

      #(model, effect)
    }
  }
}

fn animate(open: Bool) -> Effect(Message) {
  use dispatch, shadow_root <- effect.before_paint
  use #(width, height) <- do_animate(shadow_root, open)

  dispatch(PanelMeasuredDimensions(width:, height:))
}

@external(javascript, "./panel.ffi.mjs", "animate")
fn do_animate(
  shadow_root: Dynamic,
  open: Bool,
  dispatch: fn(#(String, String)) -> Nil,
) -> Nil

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Message) {
  element.fragment([
    html.style([], {
      "
      :host {
        --accordion-panel-width: ${width};
        --accordion-panel-height: ${height};

        display: block;
      }
      "
      |> string.replace("${width}", model.width)
      |> string.replace("${height}", model.height)
    }),
    component.default_slot([attribute.inert(model.open == Collapsed)], []),
  ])
}
