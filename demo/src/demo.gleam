import gleam/int
import gleam/float
import gleam/result
import lustre
import lustre/attribute.{attribute}
import lustre/element.{type Element, text}
import lustre/element/html
import lustre/event
import lustre/ui.{type Theme, Px, Rem, Size, Theme}
import lustre/ui/alert
import lustre/ui/breadcrumbs
import lustre/ui/button
import lustre/ui/field
import lustre/ui/icon
import lustre/ui/input
import lustre/ui/layout/aside
import lustre/ui/layout/cluster
import lustre/ui/prose
import lustre/ui/util/colour
import lustre/ui/util/styles

// MAIN ------------------------------------------------------------------------

pub fn main() {
  lustre.simple(init, update, view)
}

fn init(_) -> Theme {
  Theme(
    space: Size(base: Rem(1.5), ratio: 1.618),
    text: Size(base: Rem(1.125), ratio: 1.215),
    radius: Px(4.0),
    primary: colour.iris(),
    greyscale: colour.slate(),
    error: colour.red(),
    success: colour.green(),
    warning: colour.yellow(),
    info: colour.blue(),
  )
}

pub type Msg {
  UserChangedSpaceBase(Float)
  UserChangedSpaceRatio(Float)
  UserChangedTextBase(Float)
  UserChangedTextRatio(Float)
  UserChangedRadius(Float)
}

fn update(theme: Theme, msg: Msg) -> Theme {
  case msg {
    UserChangedSpaceBase(value) ->
      Theme(..theme, space: Size(..theme.space, base: Rem(value)))
    UserChangedSpaceRatio(value) ->
      Theme(..theme, space: Size(..theme.space, ratio: value))
    UserChangedTextBase(value) ->
      Theme(..theme, text: Size(..theme.text, base: Rem(value)))
    UserChangedTextRatio(value) ->
      Theme(..theme, text: Size(..theme.text, ratio: value))
    UserChangedRadius(value) -> Theme(..theme, radius: Px(value))
  }
}

// VIEW ------------------------------------------------------------------------

fn view(theme: Theme) -> Element(Msg) {
  let styles = [#("width", "80ch"), #("margin", "0 auto"), #("padding", "2rem")]

  html.div([], [
    styles.elements(),
    styles.scoped(theme, "#container"),
    ui.stack([attribute.id("container"), attribute.style(styles)], [
      ui.aside(
        [aside.content_last()],
        html.input([
          attribute("type", "range"),
          attribute("min", "0.5"),
          attribute("max", "3.0"),
          attribute("step", "0.01"),
          attribute("value", {
            let assert Rem(value) = theme.space.base
            float.to_string(value)
          }),
          event.on("input", fn(event) {
            let assert Ok(value) = event.value(event)
            let assert Ok(value) =
              float.parse(value)
              |> result.lazy_or(fn() {
                int.parse(value)
                |> result.map(int.to_float)
              })

            Ok(UserChangedSpaceBase(value))
          }),
        ]),
        html.span([], [html.text("Space base: ")]),
      ),
      ui.aside(
        [aside.content_last()],
        html.input([
          attribute("type", "range"),
          attribute("min", "1.125"),
          attribute("max", "3.0"),
          attribute("step", "0.01"),
          attribute("value", { float.to_string(theme.space.ratio) }),
          event.on("input", fn(event) {
            let assert Ok(value) = event.value(event)
            let assert Ok(value) =
              float.parse(value)
              |> result.lazy_or(fn() {
                int.parse(value)
                |> result.map(int.to_float)
              })

            Ok(UserChangedSpaceRatio(value))
          }),
        ]),
        html.span([], [html.text("Space ratio: ")]),
      ),
      ui.aside(
        [aside.content_last()],
        html.input([
          attribute("type", "range"),
          attribute("min", "0.5"),
          attribute("max", "3.0"),
          attribute("step", "0.01"),
          attribute("value", {
            let assert Rem(value) = theme.text.base
            float.to_string(value)
          }),
          event.on("input", fn(event) {
            let assert Ok(value) = event.value(event)
            let assert Ok(value) =
              float.parse(value)
              |> result.lazy_or(fn() {
                int.parse(value)
                |> result.map(int.to_float)
              })

            Ok(UserChangedTextBase(value))
          }),
        ]),
        html.span([], [html.text("Text base: ")]),
      ),
      ui.aside(
        [aside.content_last()],
        html.input([
          attribute("type", "range"),
          attribute("min", "1.125"),
          attribute("max", "3.0"),
          attribute("step", "0.01"),
          attribute("value", { float.to_string(theme.text.ratio) }),
          event.on("input", fn(event) {
            let assert Ok(value) = event.value(event)
            let assert Ok(value) =
              float.parse(value)
              |> result.lazy_or(fn() {
                int.parse(value)
                |> result.map(int.to_float)
              })

            Ok(UserChangedTextRatio(value))
          }),
        ]),
        html.span([], [html.text("Text ratio: ")]),
      ),
      ui.aside(
        [aside.content_last()],
        html.input([
          attribute("type", "range"),
          attribute("min", "0.0"),
          attribute("max", "20.0"),
          attribute("step", "0.01"),
          attribute("value", {
            let assert Px(value) = theme.radius
            float.to_string(value)
          }),
          event.on("input", fn(event) {
            let assert Ok(value) = event.value(event)
            let assert Ok(value) =
              float.parse(value)
              |> result.lazy_or(fn() {
                int.parse(value)
                |> result.map(int.to_float)
              })

            Ok(UserChangedRadius(value))
          }),
        ]),
        html.span([], [html.text("Radius: ")]),
      ),
      html.p([], [text("Buttons:")]),
      ui.cluster([cluster.stretch()], [
        ui.button([button.clear()], [text("these")]),
        ui.button([button.soft()], [text("are")]),
        ui.button([button.solid()], [text("some")]),
        ui.button([button.error()], [text("buttons")]),
        ui.button([button.success()], [ui.centre([], icon.share([]))]),
      ]),
      html.p([], [text("Button groups:")]),
      ui.group([], [
        ui.button([], [text("these")]),
        ui.button([], [text("are")]),
        ui.button([], [text("some")]),
        ui.button([], [text("buttons")]),
      ]),
      html.p([], [text("Tags:")]),
      ui.cluster([], [
        ui.tag([], [text("erlang")]),
        ui.tag([], [text("elixir")]),
        ui.tag([attribute("tabindex", "0")], [text("gleam"), icon.cross([])]),
        ui.tag([], [text("javascript")]),
      ]),
      html.p([], [text("Breadcrumbs:")]),
      ui.breadcrumbs([], icon.caret_right([]), [
        html.span([], [text("Implicit active")]),
        html.a([], [text("Page A")]),
        html.a([], [text("Page B")]),
        html.a([], [text("Page C")]),
      ]),
      ui.breadcrumbs([], icon.caret_right([]), [
        html.span([], [text("Explicit .active class")]),
        html.a([], [text("Page A")]),
        html.a([breadcrumbs.active()], [text("Page B")]),
        html.a([], [text("Page C")]),
      ]),
      html.p([], [text("Inputs:")]),
      ui.input([]),
      html.p([], [text("...with placeholder")]),
      ui.input([input.error(), attribute.placeholder("Hi")]),
      html.p([], [text("...disabled")]),
      ui.input([
        input.error(),
        attribute.placeholder("Hi"),
        attribute.disabled(True),
      ]),
      html.p([], [text("...clear variant")]),
      ui.input([input.clear(), attribute.placeholder("Hi")]),
      html.p([], [text("Fields:")]),
      ui.field([], [text("Name")], ui.input([]), [text("0/200")]),
      ui.field(
        [field.error(), field.label_centre(), field.message_start()],
        [text("Name")],
        ui.input([attribute.disabled(True)]),
        [text("0/200")],
      ),
      html.p([], [text("Icons:")]),
      ui.cluster([], [
        icon.font_style([]),
        icon.font_italic([]),
        icon.font_roman([]),
        icon.font_bold([]),
        icon.font_letter_uppercase([]),
        icon.font_letter_capitalcase([]),
        icon.font_letter_lowercase([]),
        icon.font_letter_case_toggle([]),
        icon.letter_spacing([]),
        icon.align_baseline([]),
        icon.font_size([]),
        icon.font_family([]),
        icon.heading([]),
        icon.text([]),
        icon.text_none([]),
        icon.line_height([]),
        icon.underline([]),
        icon.strikethrough([]),
        icon.overline([]),
        icon.pilcrow([]),
        icon.text_align_left([]),
        icon.text_align_centre([]),
        icon.text_align_right([]),
        icon.text_align_justify([]),
        icon.text_align_top([]),
        icon.text_align_middle([]),
        icon.text_align_bottom([]),
        icon.dash([]),
        icon.arrow_left([]),
        icon.arrow_right([]),
        icon.arrow_up([]),
        icon.arrow_down([]),
        icon.arrow_top_left([]),
        icon.arrow_top_right([]),
        icon.arrow_bottom_left([]),
        icon.arrow_bottom_right([]),
        icon.chevron_down([]),
        icon.chevron_left([]),
        icon.chevron_right([]),
        icon.chevron_up([]),
        icon.double_arrow_down([]),
        icon.double_arrow_left([]),
        icon.double_arrow_right([]),
        icon.double_arrow_up([]),
        icon.thick_arrow_left([]),
        icon.thick_arrow_right([]),
        icon.thick_arrow_up([]),
        icon.thick_arrow_down([]),
        icon.triangle_left([]),
        icon.triangle_right([]),
        icon.triangle_up([]),
        icon.triangle_down([]),
        icon.caret_left([]),
        icon.caret_right([]),
        icon.caret_up([]),
        icon.caret_down([]),
        icon.caret_sort([]),
        icon.width([]),
        icon.height([]),
        icon.size([]),
        icon.move([]),
        icon.all_sides([]),
        icon.frame([]),
        icon.crop([]),
        icon.layers([]),
        icon.stack([]),
        icon.tokens([]),
        icon.component([]),
        icon.component_alt([]),
        icon.symbol([]),
        icon.component_instance([]),
        icon.component_none([]),
        icon.component_boolean([]),
        icon.component_placeholder([]),
        icon.opacity([]),
        icon.blending_mode([]),
        icon.mask_on([]),
        icon.mask_off([]),
        icon.colour_wheel([]),
        icon.shadow([]),
        icon.shadow_none([]),
        icon.shadow_inner([]),
        icon.shadow_outer([]),
        icon.value([]),
        icon.value_none([]),
        icon.zoom_in([]),
        icon.zoom_out([]),
        icon.transparency_grid([]),
        icon.group([]),
        icon.dimensions([]),
        icon.rotate_counter_clockwise([]),
        icon.columns([]),
        icon.rows([]),
        icon.transform([]),
        icon.box_model([]),
        icon.padding([]),
        icon.margin([]),
        icon.angle([]),
        icon.cursor_arrow([]),
        icon.cursor_text([]),
        icon.column_spacing([]),
        icon.row_spacing([]),
        icon.play([]),
        icon.resume([]),
        icon.pause([]),
        icon.stop([]),
        icon.track_previous([]),
        icon.track_next([]),
        icon.loop([]),
        icon.shuffle([]),
        icon.speaker_loud([]),
        icon.speaker_moderate([]),
        icon.speaker_quiet([]),
        icon.speaker_off([]),
        icon.hamburger_menu([]),
        icon.close([]),
        icon.dots_horizontal([]),
        icon.dots_vertical([]),
        icon.plus([]),
        icon.minus([]),
        icon.check([]),
        icon.cross([]),
        icon.check_circled([]),
        icon.cross_circled([]),
        icon.plus_circled([]),
        icon.minus_circled([]),
        icon.question_mark([]),
        icon.question_mark_circled([]),
        icon.info_circled([]),
        icon.accessibility([]),
        icon.exclamation_triangle([]),
        icon.share([]),
        icon.share_alt([]),
        icon.external_link([]),
        icon.open_in_new_window([]),
        icon.enter([]),
        icon.exit([]),
        icon.download([]),
        icon.upload([]),
        icon.reset([]),
        icon.reload([]),
        icon.update([]),
        icon.enter_full_screen([]),
        icon.exit_full_screen([]),
        icon.drag_handle_vertical([]),
        icon.drag_handle_horizontal([]),
        icon.drag_handle_dots_alt([]),
        icon.dot([]),
        icon.dot_filled([]),
        icon.commit([]),
        icon.slash([]),
        icon.circle([]),
        icon.circle_backslash([]),
        icon.half([]),
        icon.half_alt([]),
        icon.view_vertical([]),
        icon.view_horizontal([]),
        icon.view_grid([]),
        icon.view_none([]),
        icon.square([]),
        icon.copy([]),
        icon.magnifying_glass([]),
        icon.gear([]),
        icon.bell([]),
        icon.home([]),
        icon.lock_closed([]),
        icon.lock_open([]),
        icon.lock_open_alt([]),
        icon.backpack([]),
        icon.camera([]),
        icon.paper_plane([]),
        icon.rocket([]),
        icon.envelope_closed([]),
        icon.envelope_open([]),
        icon.chat_bubble([]),
        icon.link([]),
        icon.link_none([]),
        icon.link_break([]),
        icon.link_alt([]),
        icon.link_none_alt([]),
        icon.link_break_alt([]),
        icon.trash([]),
        icon.pencil([]),
        icon.pencil_alt([]),
        icon.bookmark([]),
        icon.bookmark_filled([]),
        icon.drawing_pin([]),
        icon.drawing_pin_filled([]),
        icon.sewing_pin([]),
        icon.sewing_pin_filled([]),
        icon.cube([]),
        icon.archive([]),
        icon.crumpled_paper([]),
        icon.mix([]),
        icon.mixer_horizontal([]),
        icon.mixer_vertical([]),
        icon.file([]),
        icon.file_text([]),
        icon.file_plus([]),
        icon.file_minus([]),
        icon.reader([]),
        icon.card_stack([]),
        icon.card_stack_plus([]),
        icon.card_stack_minus([]),
        icon.id_card([]),
        icon.crosshair([]),
        icon.crosshair_alt([]),
        icon.target([]),
        icon.disc([]),
        icon.globe([]),
        icon.sun([]),
        icon.moon([]),
        icon.clock([]),
        icon.timer([]),
        icon.counter_clockwise_clock([]),
        icon.countdown_timer([]),
        icon.stopwatch([]),
        icon.lap_timer([]),
        icon.lightning_bolt([]),
        icon.magic_wand([]),
        icon.face([]),
        icon.person([]),
        icon.eye_open([]),
        icon.eye_none([]),
        icon.eye_closed([]),
        icon.hand([]),
        icon.ruler_horizontal([]),
        icon.ruler_square([]),
        icon.clipboard([]),
        icon.clipboard_copy([]),
        icon.desktop([]),
        icon.laptop([]),
        icon.mobile([]),
        icon.keyboard([]),
        icon.star([]),
        icon.star_filled([]),
        icon.heart([]),
        icon.heart_filled([]),
        icon.scissors([]),
        icon.hobby_knife([]),
        icon.eraser([]),
        icon.cookie([]),
        icon.box([]),
        icon.aspect_ratio([]),
        icon.container([]),
        icon.section([]),
        icon.layout([]),
        icon.grid([]),
        icon.table([]),
        icon.image([]),
        icon.switch([]),
        icon.checkbox([]),
        icon.radiobutton([]),
        icon.avatar([]),
        icon.button([]),
        icon.badge([]),
        icon.input([]),
        icon.slider([]),
        icon.quote([]),
        icon.code([]),
        icon.list_bullet([]),
        icon.dropdown_menu([]),
        icon.video([]),
        icon.pie_chart([]),
        icon.calendar([]),
        icon.dashboard([]),
        icon.activity_log([]),
        icon.bar_chart([]),
        icon.divider_vertical([]),
        icon.divider_horizontal([]),
        icon.modulz_logo([]),
        icon.switches_logo([]),
        icon.figma_logo([]),
        icon.framer_logo([]),
        icon.sketch_logo([]),
        icon.twitter_logo([]),
        icon.iconjar_logo([]),
        icon.github_logo([]),
        icon.vercel_logo([]),
        icon.codesandbox_logo([]),
        icon.notion_logo([]),
        icon.discord_logo([]),
        icon.instagram_logo([]),
        icon.linkedin_logo([]),
        icon.border_all([]),
        icon.border_split([]),
        icon.border_left([]),
        icon.border_right([]),
        icon.border_top([]),
        icon.border_bottom([]),
        icon.corners([]),
        icon.corner_top_left([]),
        icon.corner_top_right([]),
        icon.corner_bottom_left([]),
        icon.corner_bottom_right([]),
        icon.border_style([]),
        icon.border_solid([]),
        icon.border_dashed([]),
        icon.border_dotted([]),
        icon.alignment_top([]),
        icon.alignment_centre_vertically([]),
        icon.alignment_bottom([]),
        icon.stretch_vertically([]),
        icon.alignment_left([]),
        icon.alignment_centre_horizontally([]),
        icon.alignment_right([]),
        icon.stretch_horizontally([]),
        icon.space_between_horizontally([]),
        icon.space_even_horizontally([]),
        icon.space_between_vertically([]),
        icon.space_even_vertically([]),
        icon.pin_left([]),
        icon.pin_right([]),
        icon.pin_top([]),
        icon.pin_bottom([]),
      ]),
      ui.alert([], [
        ui.aside(
          [aside.content_last(), aside.align_centre()],
          html.p([], [text("This is an alert!")]),
          icon.info_circled([]),
        ),
      ]),
      ui.alert([alert.error(), alert.clear()], [
        ui.aside(
          [aside.content_last(), aside.align_centre()],
          html.p([], [text("Ooo this one is scary.")]),
          icon.exclamation_triangle([]),
        ),
      ]),
      ui.prose([prose.full()], [
        html.h1([], [text("Prose:")]),
        html.h2([], [text("A demo")]),
        html.p([], [
          text(
            "This is a demo of the 'lustre-ui-prose' class. Bare HTML tags that
          are descendants of elements with this class are styled to make them
          nice to consume in content-heavy situations like rendering a blog post
          or formatting user-generated content.",
          ),
        ]),
        html.p([], [
          text(
            "Here's a second paragraph to see how multiple blocks of content look
          stacked together. As you can see, there is spacing between them.",
          ),
        ]),
        html.h3([], [text("It even supports lists!")]),
        html.ul([], [
          html.li([], [text("Unordered list item 1")]),
          html.li([], [text("Unordered list item 2")]),
          html.li([], [text("Unordered list item 3")]),
        ]),
        html.p([], [
          text(
            "And of course, it supports ordered lists too. Here's a list of
          programming languages in order of preference:",
          ),
        ]),
        html.ol([], [
          html.li([], [text("Gleam")]),
          html.li([], [text("Elm")]),
          html.li([], [text("JavaScript")]),
        ]),
        html.h3([], [text("Inline elements")]),
        html.p([], [
          text("Inline elements like "),
          html.a([attribute.href("https://www.google.com")], [text("links")]),
          text(" and "),
          html.em([], [text("emphasis")]),
          text(" are also styled nicely. "),
          html.strong([], [text("Strong")]),
          text(" text is also supported, as is "),
          html.code([], [text("code")]),
          text(" and "),
          html.kbd([], [text("keyboard")]),
          text(" text."),
        ]),
        html.h3([], [text("Blockquotes")]),
        html.p([], [
          text(
            "Blockquotes are also supported. Here's a quote from the Gleam website:",
          ),
        ]),
        html.blockquote([], [
          html.p([], [
            text(
              "The power of a type system, the expressiveness of functional
            programming, and the reliability of the highly concurrent, fault
            tolerant Erlang runtime, with a familiar and modern syntax.",
            ),
          ]),
        ]),
        html.h3([], [text("Code blocks")]),
        html.p([], [
          text(
            "Code blocks are also supported. Here's a code block with syntax
          highlighting:",
          ),
        ]),
        html.pre([], [
          html.code([], [
            text(
              "export const compile_css = async (css, next) => {
  const to = join(cwd(), \"./priv/styles.css\");
  const { css: out } = await compiler.process(css, { from: undefined, to });
  await writeFile(to, out, { encoding: \"utf8\" });

  next(out);
};
",
            ),
          ]),
        ]),
        html.h3([], [text("Images")]),
        html.img([attribute.src("https://source.unsplash.com/random")]),
      ]),
    ]),
  ])
}
