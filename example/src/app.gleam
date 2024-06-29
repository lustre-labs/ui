import gleam/option
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/theme

fn theme_styles() {
  theme.theme_styles(
    theme: theme.light_theme(),
    class: option.None,
    dark_theme: option.Some(theme.dark_theme()),
    dark_theme_class: option.Some("ui-theme-dark"),
  )
}

fn view_examples(children: List(Element(msg))) {
  html.div([attribute.class("ui-flex")], [
    html.div([], children),
    html.div([attribute.class("ui-theme-dark")], children),
  ])
}

pub fn main() {
  element.fragment([
    theme_styles(),
    view_examples([
      html.p(
        [
          attribute.style([
            #("color", theme.primary.text),
            #("background", theme.base.bg),
          ]),
        ],
        [html.text("hi")],
      ),
    ]),
  ])
  |> lustre.element()
  |> lustre.start("#app", Nil)
}
