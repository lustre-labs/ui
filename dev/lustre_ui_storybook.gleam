// IMPORTS ---------------------------------------------------------------------

import lustre/dev/fable
import lustre/ui
import lustre/ui/menu_stories
import lustre/ui/otp_stories

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let book =
    fable.book("Lustre UI", [
      fable.external_stylesheet("/storybook.css"),
      fable.chapter("Menu", [
        menu_stories.edit_menu_story(),
        menu_stories.discord_server_menu(),
      ]),
      fable.chapter("OTP input", [
        otp_stories.default_story(),
        otp_stories.six_digits_story(),
        otp_stories.with_separator_story(),
        otp_stories.letters_story(),
        otp_stories.letters_and_digits_story(),
      ]),
    ])

  let assert Ok(_) = ui.register()
  let assert Ok(_) = fable.start(book)
}
