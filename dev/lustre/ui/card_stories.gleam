// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/element/html
import lustre/ui/button
import lustre/ui/card
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Card", [basic_card_story(), dialog_card_story()])
}

fn basic_card_story() {
  use <- fable.story("Basic Content Card with Header and Content")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  card.element([], [
    card.header([], [html.h2([], [html.text("Easy Chocolate Chip Cookies")])]),
    card.content([], [
      html.p([], [
        html.text(
          "A simple recipe for delicious chocolate chip cookies that are crisp at the edges and chewy in the middle.",
        ),
      ]),
    ]),
  ])
}

fn dialog_card_story() {
  use <- fable.story("Dialog-Style Card with Footer Actions")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  card.element([], [
    card.header([], [html.text("Delete recipe?")]),
    card.content([], [
      html.p([], [
        html.text("Are you sure that you want to delete this recipe?"),
      ]),
    ]),
    card.footer([], [
      button.element([button.clear()], [html.text("Cancel")]),
      button.element([button.solid(), button.danger()], [html.text("Delete")]),
    ]),
  ])
}
