// IMPORTS ---------------------------------------------------------------------

import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/badge
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Badge", [online_avatar_story()])
}

fn online_avatar_story() {
  use <- fable.story("Online Avatar Indicator")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  html.div([attribute.class("inline-block relative")], [
    html.img([
      attribute.class("h-10 w-10 rounded-full"),
      attribute.src("https://placehold.co/100"),
      attribute.alt("Avatar"),
    ]),
    badge.element(
      [
        badge.background("green"),
        badge.solid(),
        attribute.class("absolute top-0 right-0"),
        attribute.title("online"),
      ],
      [],
    ),
  ])
}
