import lustre
import lustre/attribute.{attribute}
import lustre/element
import lustre/element/html
import lustre/ui/badge
import lustre/ui/button
import lustre/ui/card
import lustre/ui/divider
import lustre/ui/primitives/collapse.{collapse}
import lustre/ui/theme

pub fn main() {
  let assert Ok(_) = collapse.register()

  let theme = theme.default()

  let app =
    lustre.simple(fn(_) { False }, fn(_, expanded) { expanded }, fn(expanded) {
      element.fragment([
        theme.to_style(theme),
        html.div(
          [
            attribute.class(
              "flex items-center gap-w-sm max-w-5xl mx-auto p-w-lg",
            ),
          ],
          [badge.solid([], [html.text("hello")])],
        ),
        // ---------------------------------------------------------------------
        // Divider
        // ---------------------------------------------------------------------

        divider.divider([], []),
        html.div([attribute.class("p-w-lg flex items-center")], [
          html.div([attribute.class("grow")], [
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("hayleigh"),
            ]),
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("and georges"),
            ]),
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("sitting on a tree"),
            ]),
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("fighting over api's"),
            ]),
            divider.divider([divider.margin(theme.spacing.md), divider.thin()], [
              html.span([attribute.class("text-w-text-subtle italic")], [
                html.text("this actually rhymes in portuguese"),
              ]),
            ]),
          ]),
          divider.divider(
            [divider.vertical(), divider.margin(theme.spacing.md)],
            [html.text("or")],
          ),
          html.div([attribute.class("grow")], [
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("how to stop worrying"),
            ]),
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("and love"),
            ]),
            divider.divider(
              [divider.margin(theme.spacing.md), divider.colour("#FF10F0")],
              [
                html.span([attribute.class("text-w-text-subtle italic")], [
                  html.text("niamh and janine"),
                ]),
              ],
            ),
            divider.divider([divider.margin(theme.spacing.md)], [
              html.text("as they are wise and beautiful"),
            ]),
          ]),
        ]),
        divider.divider([], []),
        // ---------------------------------------------------------------------

        html.div(
          [
            attribute.class(
              "flex items-center gap-w-sm max-w-5xl mx-auto p-w-lg",
            ),
          ],
          [
            card.with_header(
              [attribute.class("flex-1 rounded")],
              header: [
                card.title([], [html.text("Card title")]),
                card.description([attribute.class("text-sm")], [
                  html.text("Card description"),
                ]),
              ],
              content: [
                html.img([
                  attribute.class("aspect-square shadow rounded"),
                  attribute.src("https://picsum.photos/400/400"),
                ]),
              ],
            ),
            card.custom([attribute.class("flex-1 rounded")], [
              collapse(
                [
                  collapse.expanded(expanded),
                  collapse.on_change(fn(expanded) { expanded }),
                  collapse.duration(400),
                ],
                trigger: card.header([], [
                  card.title([], [html.text("Card title")]),
                  card.description([attribute.class("text-sm")], [
                    html.text("Card description"),
                  ]),
                ]),
                content: element.fragment([
                  card.content([], [
                    html.img([
                      attribute.class("aspect-square shadow rounded"),
                      attribute.src("https://picsum.photos/400/400"),
                    ]),
                  ]),
                  card.footer([], [
                    button.solid(
                      [
                        button.small(),
                        button.round(),
                        button.primary(),
                        attribute.class("w-full"),
                      ],
                      [html.text("Post")],
                    ),
                  ]),
                ]),
              ),
            ]),
            card.with_footer(
              [attribute.class("flex-1 rounded")],
              content: [
                html.img([
                  attribute.class("aspect-square shadow rounded"),
                  attribute.src("https://picsum.photos/400/400"),
                ]),
              ],
              footer: [
                button.solid(
                  [
                    button.small(),
                    button.round(),
                    button.primary(),
                    attribute.class("w-full"),
                  ],
                  [html.text("Post")],
                ),
              ],
            ),
          ],
        ),
      ])
    })

  let assert Ok(_) = lustre.start(app, "#app", Nil)
}
