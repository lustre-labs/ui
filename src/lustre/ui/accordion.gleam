//// The [`accordion`](#accordion) element is an interactive component that allows
//// users to show and hide grouped sections of content. Each section has a panel
//// containing additional content that can be shown or hidden.
////
//// Common uses for accordions include:
////
//// - Organizing content into collapsible sections to reduce cognitive load.
////
//// - Creating FAQ sections where questions expand to show their answers.
////
//// ## Anatomy
////
//// <image src="/assets/diagram-accordion.svg" alt="" width="100%">
////
//// An accordion is made up of two different parts:
////
//// - The main [`accordion`](#accordion) container used to organize content into
////   collapsible sections. (**required**)
////
//// - One or more [`item`](#item) elements representing each expandable section,
////   containing a label and content. (**required**)
////
//// ## Recipes
////
//// Below are some recipes that show common uses of the `accordion` element.
////
//// ### A basic FAQ accordion:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/accordion.{accordion}
////
//// pub fn faq() {
////   accordion([], [
////     accordion.item(
////       value: "q1",
////       label: "What is an accordion?",
////       content: [html.text("An interactive element for showing/hiding content")]
////     ),
////     accordion.item(
////       value: "q2",
////       label: "When should I use one?",
////       content: [html.text("When you want to organize content into sections")]
////     )
////   ])
//// }
//// ```
////
//// ### An accordion with `exactly_one` mode:
////
//// ```gleam
//// import lustre/element/html
//// import lustre/ui/accordion.{accordion}
////
//// pub fn settings() {
////   accordion([accordion.exactly_one()], [
////     accordion.item(
////       value: "general",
////       label: "General",
////       content: [html.text("General settings content")]
////     ),
////     accordion.item(
////       value: "privacy",
////       label: "Privacy",
////       content: [html.text("Privacy settings content")]
////     )
////   ])
//// }
//// ```
////
//// ## Customisation
////
//// The behaviour of an accordion can be controlled by setting the `mode` attribute
//// using one of the following functions:
////
//// - [`at_most_one`](#at_most_one)
//// - [`exactly_one`](#exactly_one)
//// - [`multi`](#multi)
////
//// It is possible to control some aspects of an accordion's styling through CSS
//// variables. You may want to do this in cases where you are integrating lustre/ui
//// into an existing design system and you want the `accordion` element to match
//// elements outside of this package.
////
//// The following CSS variables can set in your own stylesheets or by using the
//// corresponding attribute functions in this module:
////
//// - [`--border`](#border)
//// - [`--border-focus`](#border_focus)
//// - [`--padding-x`](#padding_x)
//// - [`--padding-y`](#padding_y)
//// - [`--radius`](#radius)
//// - [`--text`](#text)
////

// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic.{type DecodeError, type Decoder, type Dynamic, dynamic}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import lustre
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/ui/data/bidict.{type Bidict}
import lustre/ui/icon
import lustre/ui/primitives/collapse.{collapse}

// TYPES -----------------------------------------------------------------------

/// Represents a single item in accordion, including both the title and the
/// content that is shown when the item is expanded. To construct an `Item`,
/// you should use the [`item`](#item) function.
///
///
pub opaque type Item(msg) {
  Item(value: String, label: String, content: List(Element(msg)))
}

// ELEMENTS --------------------------------------------------------------------

/// The name of the custom element as rendered in the DOM - "lustre-ui-accordion".
///
pub const name: String = "lustre-ui-accordion"

/// Register the accordion component with the tag name "lustre-ui-accordion". In
/// a Lustre SPA you **must** do this before the component will properly render;
/// most-commonly this is done before you start your Lustre app:
///
/// ```gleam
/// import lustre
/// import lustre/ui/accordion
///
/// pub fn main() {
///   let assert Ok(_) = accordion.register()
///
///   let app = lustre.application(init, update, view)
///   let assert Ok(_) = lustre.start(app, "#app", Nil)
///
///   ...
/// }
/// ```
///
/// Another option is to register the component in as an effect:
///
/// ```gleam
/// import lustre/effect.{type Effect}
/// import lustre/ui/accordion
///
/// fn register_components(on_error: fn(lustre.Error) -> msg) -> Effect(msg) {
///   use dispatch <- effect.from
///
///   case accordion.register() {
///     Ok(_) -> Nil
///     Error(error) -> on_error(error) |> dispatch
///   }
/// }
/// ```
///
pub fn register() -> Result(Nil, lustre.Error) {
  case collapse.register() {
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app = lustre.component(init, update, view, on_attribute_change())
      lustre.register(app, name)
    }
    error -> error
  }
}

/// The `accordion` element is an interactive component that allows users to show
/// and hide grouped sections of content. Each section has a panel containing
/// additional content that can be shown or hidden.
///
/// Common uses for accordions include:
///
/// - Organizing content into collapsible sections to reduce cognitive load.
///
/// - Creating FAQ sections where questions expand to show their answers.
///
/// You set the content of the accordion by passing a list of [`item`](#item)
/// elements as children.
///
/// By default, the `accordion` component allows allows only one item to be
/// expanded at a time. You can change this behaviour by setting the `mode`
/// attribute using one of the following functions:
///
/// - [`at_most_one`](#at_most_one): only zero or one item can be expanded at
///   a time. (**default**)
///
/// - [`exactly_one`](#exactly_one): exactly one item must be expanded at all
///   times. By default, the first item is expanded.
///
/// - [`multi`](#multi): any number of items can be expanded at a time.
///
/// <!-- @element -->
///
pub fn accordion(
  attributes: List(Attribute(msg)),
  children: List(Item(msg)),
) -> Element(msg) {
  element.keyed(element(name, attributes, _), {
    use Item(value, label, content) <- list.flat_map(children)
    use <- bool.guard(value == "", [])

    let item =
      element("lustre-ui-accordion-item", [attribute.value(value)], [
        html.text(label),
      ])
    let content = html.div([attribute("slot", value)], content)

    [#(value, item), #(value <> "-content", content)]
  })
}

/// An `item` element represents a single expandable section in an accordion. It
/// contains a label that is always visible and a content area that is shown or
/// hidden when the accordion item is toggled.
///
/// The `value` attribute is used to uniquely identify the item in the accordion
/// and should not clash with an other items in the same accordion. If the `value`
/// attribute is an empty string, the item will not be rendered.
///
/// <!-- @element -->
///
pub fn item(
  value value: String,
  label label: String,
  content content: List(Element(msg)),
) -> Item(msg) {
  Item(value:, label:, content:)
}

// ATTRIBUTES ------------------------------------------------------------------

/// Set the `mode` attribute of an accordion to allow zero or one item to be
/// expanded at a time. This is the default mode.
///
/// <!-- @attribute -->
///
pub fn at_most_one() -> Attribute(msg) {
  attribute("mode", "at-most-one")
}

/// Set the `mode` attribute of an accordion to allow exactly one item to be
/// expanded at all times. If no item is expanded when this attribute is set,
/// the first item will be automatically expanded.
///
/// <!-- @attribute -->
///
pub fn exactly_one() -> Attribute(msg) {
  attribute("mode", "exactly-one")
}

/// Set the `mode` attribute of an accordion to allow any number of items to be
/// expanded at a time.
///
/// <!-- @attribute -->
///
pub fn multi() -> Attribute(msg) {
  attribute("mode", "multi")
}

// VARIABLES -------------------------------------------------------------------

///
/// <!-- @css-variable -->
///
pub fn padding(x x: String, y y: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", x), #("--padding-y", y)])
}

///
/// <!-- @css-variable -->
///
pub fn padding_x(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-x", value)])
}

///
/// <!-- @css-variable -->
///
pub fn padding_y(value: String) -> Attribute(msg) {
  attribute.style([#("--padding-y", value)])
}

///
/// <!-- @css-variable -->
///
pub fn border(value: String) -> Attribute(msg) {
  attribute.style([#("--border", value)])
}

///
/// <!-- @css-variable -->
///
pub fn border_focus(value: String) -> Attribute(msg) {
  attribute.style([#("--border-focus", value)])
}

///
/// <!-- @css-variable -->
///
pub fn border_width(value: String) -> Attribute(msg) {
  attribute.style([#("--border-width", value)])
}

///
/// <!-- @css-variable -->
///
pub fn text(value: String) -> Attribute(msg) {
  attribute.style([#("--text", value)])
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(options: Options, expanded: Set(String), mode: Mode)
}

type Mode {
  AtMostOne
  ExactlyOne
  Multi
}

type Options {
  Options(
    all: List(#(String, String)),
    lookup_label: Bidict(String, String),
    lookup_index: Bidict(String, Int),
  )
}

fn init(_) -> #(Model, Effect(Msg)) {
  let options =
    Options(all: [], lookup_label: bidict.new(), lookup_index: bidict.new())
  let model = Model(options:, expanded: set.new(), mode: AtMostOne)
  let effect = effect.none()

  #(model, effect)
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  ParentChangedChildren(List(#(String, String)))
  ParentSetMode(Mode)
  UserPressedDown(String)
  UserPressedEnd
  UserPressedHome
  UserPressedUp(String)
  UserToggledItem(String)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ParentChangedChildren(all) -> {
      let lookup_label = bidict.from_list(all)
      let lookup_index = bidict.indexed(list.map(all, pair.first))
      let options = Options(all:, lookup_label:, lookup_index:)
      let expanded = set.filter(model.expanded, bidict.has(lookup_label, _))
      let keys = list.map(all, pair.first)
      let expanded = case model.mode, set.size(expanded) {
        AtMostOne, 0 | AtMostOne, 1 -> expanded
        AtMostOne, _ ->
          list.find(keys, set.contains(expanded, _))
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        ExactlyOne, 0 ->
          list.first(keys)
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        ExactlyOne, 1 -> expanded
        ExactlyOne, _ ->
          list.find(keys, set.contains(expanded, _))
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        Multi, _ -> expanded
      }
      let model = Model(..model, options:, expanded:)
      let effect = effect.none()

      #(model, effect)
    }

    ParentSetMode(mode) -> {
      let keys = list.map(model.options.all, pair.first)
      let expanded = case mode, set.size(model.expanded) {
        AtMostOne, 0 | AtMostOne, 1 -> model.expanded
        AtMostOne, _ ->
          list.find(keys, set.contains(model.expanded, _))
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        ExactlyOne, 0 ->
          list.first(keys)
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        ExactlyOne, 1 -> model.expanded
        ExactlyOne, _ ->
          list.find(keys, set.contains(model.expanded, _))
          |> result.map(fn(key) { set.from_list([key]) })
          |> result.unwrap(set.new())
        Multi, _ -> model.expanded
      }
      let model = Model(..model, mode:, expanded:)
      let effect = effect.none()

      #(model, effect)
    }

    UserPressedDown(key) -> {
      let effect = {
        use index <- result.try(bidict.get(model.options.lookup_index, key))
        use next <- result.map(bidict.get_inverse(
          model.options.lookup_index,
          index + 1,
        ))

        focus_trigger(next)
      }

      #(model, effect |> result.unwrap(effect.none()))
    }

    UserPressedEnd -> {
      let effect = {
        use last <- result.map(bidict.max_inverse(
          model.options.lookup_index,
          int.compare,
        ))

        focus_trigger(last)
      }

      #(model, effect |> result.unwrap(effect.none()))
    }

    UserPressedHome -> {
      let effect = {
        use first <- result.map(bidict.min_inverse(
          model.options.lookup_index,
          int.compare,
        ))

        focus_trigger(first)
      }

      #(model, effect |> result.unwrap(effect.none()))
    }

    UserPressedUp(key) -> {
      let effect = {
        use index <- result.try(bidict.get(model.options.lookup_index, key))
        use prev <- result.map(bidict.get_inverse(
          model.options.lookup_index,
          index - 1,
        ))

        focus_trigger(prev)
      }

      #(model, effect |> result.unwrap(effect.none()))
    }

    UserToggledItem(value) -> {
      let expanded = case set.contains(model.expanded, value), model.mode {
        True, AtMostOne -> set.new()
        False, AtMostOne -> set.from_list([value])
        True, ExactlyOne -> model.expanded
        False, ExactlyOne -> set.from_list([value])
        True, Multi -> set.delete(model.expanded, value)
        False, Multi -> set.insert(model.expanded, value)
      }

      let model = Model(..model, expanded:)
      let effect = effect.none()

      #(model, effect)
    }
  }
}

fn on_attribute_change() -> Dict(String, Decoder(Msg)) {
  dict.from_list([
    #("mode", fn(value) {
      dynamic.string(value)
      |> result.then(fn(mode) {
        case mode {
          "at-most-one" -> Ok(AtMostOne)
          "exactly-one" -> Ok(ExactlyOne)
          "multi" -> Ok(Multi)
          _ -> Error([])
        }
      })
      |> result.unwrap(AtMostOne)
      |> ParentSetMode
      |> Ok
    }),
  ])
}

// EFFECTS ---------------------------------------------------------------------

fn focus_trigger(key: String) -> Effect(msg) {
  use _, root <- element.get_root()
  let selector = "[data-lustre-key=" <> key <> "] button[part=trigger]"

  case get_element(selector)(root) {
    Ok(trigger) -> focus(trigger)
    Error(_) -> Nil
  }
}

@external(javascript, "../../dom.ffi.mjs", "get_element")
fn get_element(selector: String) -> Decoder(Dynamic)

@external(javascript, "../../dom.ffi.mjs", "focus")
fn focus(element: Dynamic) -> Nil

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.slot([
      attribute.style([#("display", "none")]),
      event.on("slotchange", handle_slot_change),
    ]),
    element.keyed(element.fragment, {
      use #(key, label) <- list.map(model.options.all)
      let is_expanded = set.contains(model.expanded, key)
      let item =
        collapse(
          [
            collapse.expanded(is_expanded),
            collapse.on_change(fn(_) { UserToggledItem(key) }),
          ],
          trigger: html.button(
            [
              attribute("part", "accordion-trigger"),
              attribute("tabindex", "0"),
              event.on("keydown", handle_keydown(key, _)),
            ],
            [
              html.p([attribute("part", "accordion-trigger-label")], [
                html.text(label),
              ]),
              icon.chevron_down([
                attribute("part", case is_expanded {
                  True -> "accordion-trigger-icon expanded"
                  False -> "accordion-trigger-icon"
                }),
              ]),
            ],
          ),
          content: html.slot([
            attribute("part", "accordion-content"),
            attribute.name(key),
          ]),
        )

      #(key, item)
    }),
  ])
}

fn handle_slot_change(event: Dynamic) -> Result(Msg, List(DecodeError)) {
  use children <- result.try(dynamic.field("target", assigned_elements)(event))
  use options <- result.try(
    dynamic.list(fn(el) {
      dynamic.decode3(
        fn(name, value, label) { #(name, value, label) },
        dynamic.field("tagName", dynamic.string),
        get_attribute("value"),
        dynamic.field("textContent", dynamic.string),
      )(el)
    })(children),
  )

  options
  |> list.fold_right(#([], set.new()), fn(acc, option) {
    let #(tag, value, label) = option

    use <- bool.guard(tag != "LUSTRE-UI-ACCORDION-ITEM", acc)
    use <- bool.guard(set.contains(acc.1, value), acc)
    let seen = set.insert(acc.1, value)
    let options = [#(value, label), ..acc.0]

    #(options, seen)
  })
  |> pair.first
  |> ParentChangedChildren
  |> Ok
}

@external(javascript, "../../dom.ffi.mjs", "assigned_elements")
fn assigned_elements(_slot: Dynamic) -> Result(Dynamic, List(DecodeError))

@external(javascript, "../../dom.ffi.mjs", "get_attribute")
fn get_attribute(name: String) -> Decoder(String)

fn handle_keydown(
  value: String,
  event: Dynamic,
) -> Result(Msg, List(DecodeError)) {
  use key <- result.try(dynamic.field("key", dynamic.string)(event))

  case key {
    "ArrowDown" -> {
      event.prevent_default(event)
      Ok(UserPressedDown(value))
    }
    "ArrowUp" -> {
      event.prevent_default(event)
      Ok(UserPressedUp(value))
    }
    "End" -> Ok(UserPressedEnd)
    "Home" -> Ok(UserPressedHome)
    _ -> Error([])
  }
}
