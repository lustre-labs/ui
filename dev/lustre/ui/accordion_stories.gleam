// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/element/html
import lustre/ui/accordion
import lustre/ui/theme

// STORIES ---------------------------------------------------------------------

pub fn all() {
  fable.chapter("Accordion", [faq_story()])
}

fn faq_story() {
  use <- fable.story("FAQ")
  use _ <- fable.scene
  use <- theme.inject(theme.default() |> theme.with_scope(theme.Host))

  accordion.element([], [
    accordion.item(value: "q1", label: "What is an accordion?", content: [
      html.text("An interactive element for showing/hiding content"),
    ]),
    accordion.item(value: "q2", label: "When should I use one?", content: [
      html.text("When you want to organize content into sections"),
    ]),
  ])
}
