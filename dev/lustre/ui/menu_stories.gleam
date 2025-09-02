import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/checkbox
import lustre/ui/menu

pub fn edit_menu_story() {
  use <- fable.story("Edit menu")
  use selected <- fable.input("Selected value", "")
  use _ <- fable.scene()

  let item_tw =
    "px-2 py-1 rounded [&:state(active)]:bg-blue-50 [&:state(active)]:text-blue-500"

  let separator_tw = "my-1 h-px bg-gray-100"

  menu.root(
    [
      attribute.class("flex flex-col p-1 rounded border border-gray-100"),
      menu.on_select(fable.set(selected, _)),
    ],
    [
      menu.item("cut", [attribute.class(item_tw)], [
        html.text("Cut"),
      ]),
      menu.item("copy", [attribute.class(item_tw)], [
        html.text("Copy"),
      ]),
      menu.item("paste", [attribute.class(item_tw)], [
        html.text("Paste"),
      ]),
      menu.separator([attribute.class(separator_tw)], []),
      menu.group([], [
        html.p([attribute.class("ml-2 text-xs font-semibold text-gray-400")], [
          html.text("Search"),
        ]),
        menu.item("find", [attribute.class(item_tw)], [
          html.text("Find"),
        ]),
        menu.item("find-in-project", [attribute.class(item_tw)], [
          html.text("Find in project"),
        ]),
      ]),
    ],
  )
}

pub fn discord_server_menu() {
  use <- fable.story("Discord server menu")
  use _ <- fable.scene()

  let menu_tw = "bg-zinc-900 text-zinc-200 flex flex-col p-1 rounded"

  let item_tw = "px-2 py-1 rounded [&:state(active)]:bg-zinc-700"

  let checkbox_tw = "grid grid-cols-[1fr_1rem] gap-2"

  let separator_tw = "my-1 h-px bg-zinc-700"

  menu.root([attribute.class(menu_tw)], [
    menu.item("mark-as-read", [attribute.class(item_tw)], [
      html.text("Mark as read"),
    ]),
    menu.separator([attribute.class(separator_tw)], []),
    menu.item("invite-people", [attribute.class(item_tw)], [
      html.text("Invite people"),
    ]),
    menu.separator([attribute.class(separator_tw)], []),
    menu.checkbox(
      "hide-muted",
      [attribute.class(item_tw), attribute.class(checkbox_tw)],
      [html.text("Hide muted channels"), checkbox.indicator([html.text("💕")])],
    ),
    menu.checkbox(
      "show-all",
      [attribute.class(item_tw), attribute.class(checkbox_tw)],
      [html.text("Show all channels"), checkbox.indicator([html.text("😘")])],
    ),
  ])
}
