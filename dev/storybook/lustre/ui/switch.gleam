// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/string
import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/element/keyed
import lustre/event
import lustre/ui/switch

// CONSTANTS -------------------------------------------------------------------

const switch =
  "group inline-flex items-center shrink-0 rounded-full w-10 h-6 p-0.5
  bg-gray-300 transition-colors
  [:state(checked)]:bg-blue-500
  [:state(disabled)]:opacity-50 [:state(disabled)]:cursor-not-allowed
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2
  focus-visible:outline-blue-500
"

const thumb =
  "size-5 rounded-full bg-white shadow transition-transform
  group-[:state(checked)]:translate-x-4
"

const label = "flex gap-2 items-center"

const items = [
  #("Wibble", "wibble", False, False),
  #("Wobble", "wobble", True, False),
  #("Wubble", "wubble", False, True),
]

// STORIES ---------------------------------------------------------------------

pub fn basic_story() {
  let _ = switch.register()

  use <- fable.story("switch/basic")
  use _ <- fable.scene

  html.label([attribute.class(label)], [
    switch.view([attribute.class(switch)], [
      html.span([attribute.class(thumb)], []),
    ]),
    html.text("Wibble"),
  ])
}

pub fn disabled_story() {
  let _ = switch.register()

  use <- fable.story("switch/disabled")
  use _ <- fable.scene

  keyed.div([attribute.class("flex gap-4 items-center")], {
    use #(text, _, checked, _) <- list.map(items)
    let html =
      html.label([attribute.class(label)], [
        switch.view(
          [
            attribute.class(switch),
            switch.default_checked(checked),
            switch.disabled(True),
          ],
          [html.span([attribute.class(thumb)], [])],
        ),
        html.text(text),
      ])

    #(text, html)
  })
}

pub fn form_story() {
  let _ = switch.register()

  use <- fable.story("switch/form")
  use fields <- fable.input("form", "")
  use _ <- fable.scene

  let handle_submit = fn(values) {
    values
    |> string.inspect
    |> fable.set(fields, _)
  }

  html.form(
    [attribute.class("flex gap-4 items-center"), event.on_submit(handle_submit)],
    [
      keyed.div([attribute.class("flex gap-4 items-center")], {
        use #(text, name, checked, disabled) <- list.map(items)
        let html =
          html.label([attribute.class(label)], [
            switch.view(
              [
                attribute.class(switch),
                attribute.name("settings"),
                switch.value(name),
                switch.default_checked(checked),
                switch.disabled(disabled),
              ],
              [html.span([attribute.class(thumb)], [])],
            ),
            html.text(text),
          ])

        #(text, html)
      }),
      html.button(
        [
          attribute.type_("submit"),
          attribute.class("py-1 px-4 text-white bg-blue-500 rounded"),
        ],
        [
          html.text("Submit"),
        ],
      ),
    ],
  )
}
