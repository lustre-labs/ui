import gleam/list
import gleam/option
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/heading
import lustre/ui/theme

//
//
fn components() {
  [
    #("lustre/ui/heading", [
      heading.view([heading.extra_small()], [html.text("Heading")]),
      heading.view([heading.small()], [html.text("Heading")]),
      heading.view([], [html.text("Heading")]),
      heading.view([heading.large()], [html.text("Heading")]),
      heading.view([heading.extra_large()], [html.text("Heading")]),
    ]),
  ]
}

//  
//
fn view_component(component: #(String, List(Element(msg)))) {
  let #(name, children) = component

  html.article([], [
    html.header([attribute.style([#("padding", theme.spacing.md)])], [
      heading.view([heading.small(), heading.subtle()], [html.text(name)]),
    ]),
    html.ul(
      [],
      children
        |> list.map(fn(child) {
          html.li([attribute.style([#("padding", "0 " <> theme.spacing.md)])], [
            child,
          ])
        }),
    ),
  ])
}

// We're using the default light and dark themes.
// The dark theme can be set using the provided class,
// this way we can show both side by side.
fn theme_styles() {
  element.fragment([
    theme.css_reset(),
    theme.base_styles(),
    theme.base_classes(),
    theme.theme_styles(
      theme: theme.light_theme(),
      class: option.None,
      dark_theme: option.Some(theme.dark_theme()),
      dark_theme_class: option.Some("ui-theme-dark"),
    ),
  ])
}

// Layout examples so they are split between two columns.
// One using the default light theme, the other using the default dark theme.
fn view_examples(children: List(Element(msg))) {
  html.div(
    [
      attribute.style([
        #("display", "grid"),
        #("min-height", "100vh"),
        #("grid-template-columns", "repeat(2, minmax(0, 1fr))"),
      ]),
    ],
    [
      html.div([], children),
      html.div(
        [
          attribute.class("ui-theme-dark"),
          attribute.style([#("background", theme.base.bg)]),
        ],
        children,
      ),
    ],
  )
}

pub fn main() {
  element.fragment([
    theme_styles(),
    view_examples(list.map(components(), view_component)),
  ])
  |> lustre.element()
  |> lustre.start("#app", Nil)
}
