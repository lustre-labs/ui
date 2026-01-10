import lustre/dev/fable
import storybook/lustre/ui/accordion

pub fn main() {
  fable.book("lustre/ui", [
    fable.external_stylesheet("/storybook.css"),
    fable.chapter("accordion", [
      accordion.basic_story(),
      accordion.default_open_story(),
      accordion.playground_story(),
    ]),
  ])
  |> fable.start
}
