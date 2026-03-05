// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/string
import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/element/keyed
import lustre/event
import lustre/ui/toggle

// CONSTANTS -------------------------------------------------------------------

const toggle = "
  inline-flex justify-center items-center rounded size-8
  hover:bg-gray-100
  [:state(pressed)]:bg-blue-50 [:state(pressed)]:text-blue-500
  [:state(disabled)]:opacity-50 [:state(disabled)]:cursor-not-allowed
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-500
"

const group = "
  flex border border-gray-300 rounded
  *:rounded-none *:first:rounded-l *:last:rounded-r *:focus:z-10
"

const items = [
  #("B", "bold", False, False),
  #("I", "italic", True, False),
  #("U", "underline", False, True),
]

// STORIES ---------------------------------------------------------------------

pub fn basic_story() {
  let _ = toggle.register()

  use <- fable.story("toggle/basic")
  use _ <- fable.scene

  keyed.div([attribute.class("flex gap-2 items-center")], {
    use #(label, _, pressed, disabled) <- list.map(items)
    let html =
      toggle.view(
        [
          attribute.class(toggle),
          toggle.default_pressed(pressed),
          toggle.disabled(disabled),
        ],
        [html.text(label)],
      )

    #(label, html)
  })
}

pub fn group_story() {
  let _ = toggle.register()

  use <- fable.story("toggle/group")
  use _ <- fable.scene

  html.div([attribute.class("flex gap-4")], [
    toggle.group([attribute.class(group), toggle.loop(True)], {
      use #(label, value, _, _) <- list.map(items)

      toggle.item(value, [attribute.class(toggle)], [
        html.text(label),
      ])
    }),
  ])
}

pub fn form_story() {
  let _ = toggle.register()

  use <- fable.story("toggle/form")
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
      toggle.group([attribute.class(group), attribute.name("wibble")], {
        use #(label, value, _, _) <- list.map(items)

        toggle.item(value, [attribute.class(toggle)], [
          html.text(label),
        ])
      }),
      keyed.div([attribute.class("flex gap-2 items-center")], {
        use #(label, name, pressed, disabled) <- list.map(items)
        let html =
          toggle.view(
            [
              attribute.class(toggle),
              attribute.name("format"),
              toggle.value(name),
              toggle.default_pressed(pressed),
              toggle.disabled(disabled),
            ],
            [html.text(label)],
          )

        #(label, html)
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
