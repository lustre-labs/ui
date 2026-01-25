// IMPORTS ---------------------------------------------------------------------

import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/tabs

// CONSTANTS -------------------------------------------------------------------

const tabs = "rounded-md border border-gray-200"

const tabs_list = "relative z-0 flex items-center gap-1 p-1 shadow-[inset_0_-1px] shadow-gray-200"

const tabs_trigger = "flex h-6 items-center justify-center px-2 text-sm text-gray-400
  transition-colors duration-300
  outline-none
  hover:text-gray-900
  [:state(active)]:text-blue-700
"

const tabs_indicator = "absolute -z-10 left-0 top-0 h-(--indicator-height) w-(--indicator-width) translate-x-(--indicator-x) translate-y-(--indicator-y)
  rounded-sm bg-blue-50 transition-[width_height_transform] duration-300 ease-in-out
  border-b border-transparent
  has-[~lustre-tabs-trigger:focus]:border-blue-800 has-[~lustre-tabs-trigger:focus]:rounded-b-none

  "

const tabs_content = "h-32"

const tabs_panel = "relative flex h-full items-center justify-center -outline-offset-1 outline-blue-800
  focus-visible:rounded-b-md focus-visible:outline focus-visible:outline-2"

// STORIES ---------------------------------------------------------------------

pub fn basic_story() {
  let _ = tabs.register()

  use <- fable.story("tabs/basic")
  use _ <- fable.scene

  tabs.view(
    [attribute.class(tabs)],
    tabs.list([attribute.class(tabs_list)], [
      tabs.indicator([attribute.class(tabs_indicator)], []),
      tabs.trigger("wibble", [attribute.class(tabs_trigger)], [
        html.text("Wibble"),
      ]),
      tabs.trigger("wobble", [attribute.class(tabs_trigger)], [
        html.text("Woooooooobble"),
      ]),
    ]),
    tabs.content([attribute.class(tabs_content)], [
      tabs.panel("wibble", [attribute.class(tabs_panel)], [
        html.text("wibble."),
      ]),
      tabs.panel("wobble", [attribute.class(tabs_panel)], [
        html.text("wobble."),
      ]),
    ]),
  )
}
