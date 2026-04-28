// IMPORTS ---------------------------------------------------------------------

import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/tooltip
import lustre/ui/tooltip/popover

// CONSTANTS -------------------------------------------------------------------

const button = "inline-flex justify-center items-center rounded size-8
  hover:bg-gray-100
  focus-visible:outline focus-visible:outline-2 focus-visible:outline-blue-500
"

const popover = "flex flex-col px-2 py-1 rounded-md bg-black text-white text-xs shadow
  opacity-0 scale-99 [:state(open)]:opacity-100 [:state(open)]:scale-100

  [:state(top)]:left-(--tooltip-popover-x) [:state(top)]:top-[calc(var(--tooltip-popover-y)+10px)] [:state(top)]:transition-[top_opacity_transform]
  [:state(top):state(open)]:top-(--tooltip-popover-y)

  [:state(bottom)]:left-(--tooltip-popover-x) [:state(bottom)]:top-[calc(var(--tooltip-popover-y)-10px)] [:state(bottom)]:transition-[top_opacity_transform]
  [:state(bottom):state(open)]:top-(--tooltip-popover-y)

  [:state(left)]:top-(--tooltip-popover-y) [:state(left)]:left-[calc(var(--tooltip-popover-x)+10px)] [:state(left)]:transition-[left_opacity_transform]
  [:state(left):state(open)]:left-(--tooltip-popover-x)

  [:state(right)]:top-(--tooltip-popover-y) [:state(right)]:left-[calc(var(--tooltip-popover-x)-10px)] [:state(right)]:transition-[left_opacity_transform]
  [:state(right):state(open)]:left-(--tooltip-popover-x)
"

// STORIES ---------------------------------------------------------------------

pub fn basic_story() {
  let _ = tooltip.register()

  use <- fable.story("tooltip/basic")
  use side <- fable.select("side", [
    #("top", "top"),
    #("right", "right"),
    #("bottom", "bottom"),
    #("left", "left"),
  ])

  use align <- fable.select("align", [
    #("start", "start"),
    #("center", "center"),
    #("end", "end"),
  ])

  use props <- fable.scene

  let placement = fable.get(props, side) |> popover.side
  let align = fable.get(props, align) |> popover.align
  let offset = popover.offset(10.0)

  tooltip.view(
    [tooltip.delay(50)],
    popover: tooltip.popover(
      [attribute.class(popover), placement, offset, align],
      [html.text("Bold")],
    ),
    trigger: tooltip.trigger([], [
      html.button([attribute.class(button)], [html.text("B")]),
    ]),
  )
}

pub fn controlled_story() {
  let _ = tooltip.register()

  use <- fable.story("tooltip/controlled")
  use _ <- fable.scene

  tooltip.view(
    [tooltip.delay(50)],
    popover: tooltip.popover([attribute.class(popover), tooltip.open(True)], [
      html.text("Bold"),
    ]),
    trigger: tooltip.trigger([], [
      html.button([attribute.class(button)], [html.text("B")]),
    ]),
  )
}
