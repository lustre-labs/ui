import lustre/attribute
import lustre/dev/fable
import lustre/element/html
import lustre/ui/checkbox
import lustre/ui/menu

pub fn edit_menu_story() {
  use <- fable.story("Edit menu")
  use selected <- fable.input("Selected value", "")
  use _ <- fable.scene()

  let item_tw = "menu-item"

  let separator_tw = "menu-separator"

  menu.root(
    [
      attribute.class("menu-root"),
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
        html.p([attribute.class("menu-group-label")], [
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

  let menu_tw = "menu-dark"

  let item_tw = "menu-item"

  let checkbox_tw = "checkbox-grid"

  let separator_tw = "menu-separator"

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
