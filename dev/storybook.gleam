import lustre/dev/fable
import storybook/lustre/ui/accordion
import storybook/lustre/ui/tabs
import storybook/lustre/ui/toggle

pub fn main() {
  let assert Ok(_) =
    fable.book("lustre/ui", [
      fable.external_stylesheet("/storybook.css"),
      fable.chapter("accordion", [
        accordion.basic_story(),
        accordion.default_open_story(),
        accordion.playground_story(),
      ]),

      fable.chapter("tabs", [
        tabs.basic_story(),
      ]),

      fable.chapter("toggle", [
        toggle.basic_story(),
        toggle.group_story(),
        toggle.form_story(),
      ]),
    ])
    |> fable.start
}
