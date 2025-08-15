// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/ui
import lustre/ui/otp_stories

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let book =
    fable.book("Lustre UI", [
      fable.external_stylesheet("/priv/static/lustre_ui_storybook.css"),
      fable.chapter("OTP input", [
        otp_stories.default_story(),
        otp_stories.six_digits_story(),
        otp_stories.with_separator_story(),
      ]),
    ])

  let assert Ok(_) = ui.register()
  let assert Ok(_) = fable.start(book)
}
