// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/accordion

// CONSTANTS -------------------------------------------------------------------

const accordion = "w-lg"

const accordion_item = "border-b"

const accordion_trigger = "block w-full bg-gray-50 p-2 text-left
  hover:bg-gray-100
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-800"

const accordion_panel = "h-(--accordion-panel-height) overflow-hidden transition-[height] ease-out"

const items = [
  #(
    "What is lustre/ui?",
    "Lustre/ui is a collection of unstyled Lustre components developed with a
    focus on accessibility and usability.",
  ),
  #(
    "What does accessibility mean?",
    "Accessibility means that Lustre components are built to be usable by as many
    people as possible. We follow WAI-ARIA guidelines to ensure these components
    are accessible to keyboard and screen reader users.",
  ),
  #(
    "How do I use lustre/ui?",
    "You can install lustre/ui through Gleam's package manager and import the
    components you need in your Lustre application. The package also includes
    bundles for each component so they can be used in server-rendered or static
    HTML documents.",
  ),
]

// STORIES ---------------------------------------------------------------------

pub fn basic_story() {
  let _ = accordion.register()

  use <- fable.story("accordion/basic")
  use _ <- fable.scene

  accordion.view([attribute.class(accordion)], {
    use #(question, answer), index <- list.index_map(items)

    accordion.item(
      name: "item-" <> int.to_string(index),
      attributes: [attribute.class(accordion_item)],
      heading: accordion.heading(
        [],
        accordion.trigger([attribute.class(accordion_trigger)], [
          html.text(question),
        ]),
      ),
      panel: accordion.panel([attribute.class(accordion_panel)], [
        html.p([attribute.class("p-2")], [
          html.text(answer),
          html.button([attribute.tabindex(0)], [html.text("wibble")]),
        ]),
      ]),
    )
  })
}

pub fn default_open_story() {
  let _ = accordion.register()

  use <- fable.story("accordion/default-open")
  use _ <- fable.scene

  accordion.view([attribute.class(accordion)], {
    use #(question, answer), index <- list.index_map(items)

    accordion.item(
      name: "item-" <> int.to_string(index),
      attributes: [
        attribute.class(accordion_item),
        accordion.default_open(index == 1),
      ],
      heading: accordion.heading(
        [],
        accordion.trigger([attribute.class(accordion_trigger)], [
          html.text(question),
        ]),
      ),
      panel: accordion.panel([attribute.class(accordion_panel)], [
        html.p([attribute.class("p-2")], [
          html.text(answer),
        ]),
      ]),
    )
  })
}

pub fn playground_story() {
  let _ = accordion.register()

  use <- fable.story("accordion/playground")
  use multiple <- fable.checkbox("multiple")
  use loop <- fable.checkbox("loop")
  use controls <- fable.scene

  let mode = case fable.get(controls, multiple) {
    True -> accordion.multiple()
    False -> accordion.single()
  }

  let loop = accordion.loop(fable.get(controls, loop))

  accordion.view([attribute.class(accordion), mode, loop], {
    use #(question, answer), index <- list.index_map(items)

    accordion.item(
      name: "item-" <> int.to_string(index),
      attributes: [attribute.class(accordion_item)],
      heading: accordion.heading(
        [],
        accordion.trigger([attribute.class(accordion_trigger)], [
          html.text(question),
        ]),
      ),
      panel: accordion.panel([attribute.class(accordion_panel)], [
        html.p([attribute.class("p-2")], [
          html.text(answer),
        ]),
      ]),
    )
  })
}
