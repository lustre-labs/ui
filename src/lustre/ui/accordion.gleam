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

pub opaque type Item(msg) {
  Item(value: String, label: String, content: List(Element(msg)))
}

// ELEMENTS --------------------------------------------------------------------

pub const name: String = "lustre-ui-accordion"

pub fn component() -> lustre.App(Nil, Model, Msg) {
  lustre.component(init, update, view, on_attribute_change())
}

pub fn register() -> Result(Nil, lustre.Error) {
  case collapse.register() {
    Ok(Nil) | Error(lustre.ComponentAlreadyRegistered(_)) -> {
      let app = lustre.component(init, update, view, on_attribute_change())
      lustre.register(app, name)
    }
    error -> error
  }
}

pub fn accordion(
  attributes: List(Attribute(msg)),
  children: List(Item(msg)),
) -> Element(msg) {
  element(name, attributes, {
    use Item(value, label, content) <- list.flat_map(children)
    let item =
      element("lustre-ui-accordion-item", [attribute.value(value)], [
        html.text(label),
      ])
    let content = html.div([attribute("slot", value)], content)

    [item, content]
  })
}

pub fn item(
  value value: String,
  label label: String,
  content content: List(Element(msg)),
) -> Item(msg) {
  Item(value:, label:, content:)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn at_most_one() -> Attribute(msg) {
  attribute("mode", "at-most-one")
}

pub fn exactly_one() -> Attribute(msg) {
  attribute("mode", "exactly-one")
}

pub fn multi() -> Attribute(msg) {
  attribute("mode", "multi")
}

// MODEL -----------------------------------------------------------------------

pub opaque type Model {
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

pub opaque type Msg {
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
