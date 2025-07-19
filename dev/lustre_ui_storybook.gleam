// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/dev/fable
import lustre/element
import lustre/element/html
import lustre/ui/accordion_stories
import lustre/ui/alert_stories
import lustre/ui/badge_stories
import lustre/ui/breadcrumb_stories
import lustre/ui/button_stories
import lustre/ui/card_stories
import lustre/ui/combobox
import lustre/ui/combobox_stories
import lustre/ui/divider_stories

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let book =
    fable.book("Lustre UI", [
      accordion_stories.all(),
      alert_stories.all(),
      badge_stories.all(),
      breadcrumb_stories.all(),
      button_stories.all(),
      card_stories.all(),
      combobox_stories.all(),
      divider_stories.all(),
      fable.external_stylesheet("/priv/static/lustre_ui.css"),
    ])

  fable.start(book)
}
