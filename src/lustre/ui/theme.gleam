// IMPORTS ---------------------------------------------------------------------

import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam_community/colour.{type Colour}
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/colours.{type Colours}

// TYPES -----------------------------------------------------------------------

///
///
pub opaque type Theme {
  Theme(
    id: String,
    font: Fonts,
    radius: Sizes,
    space: Sizes,
    base: Colours,
    primary: Colours,
    secondary: Colours,
    info: Colours,
    success: Colours,
    warning: Colours,
    error: Colours,
  )
}

///
///
pub type Fonts {
  Fonts(heading: String, body: String, code: String)
}

///
///
pub type Sizes {
  Sizes(
    xs: Float,
    sm: Float,
    md: Float,
    lg: Float,
    xl: Float,
    xl_2: Float,
    xl_3: Float,
  )
}

pub type DarkModeSource {
  UseSystemPreferences
  UseSelector(String)
}

// CONSTANTS -------------------------------------------------------------------

const sans = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\""

const code = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"

const prefix = "lustre-ui"

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn light() -> Theme {
  let id = "lustre-ui-default-light"
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = Sizes(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = Sizes(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  Theme(
    id,
    font,
    radius,
    space,
    base: colours.slate(),
    primary: colours.pink(),
    secondary: colours.cyan(),
    info: colours.blue(),
    success: colours.green(),
    warning: colours.yellow(),
    error: colours.red(),
  )
}

///
///
pub fn dark() -> Theme {
  let id = "lustre-ui-default-dark"
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = Sizes(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = Sizes(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  Theme(
    id,
    font,
    radius,
    space,
    base: colours.slate_dark(),
    primary: colours.pink_dark(),
    secondary: colours.cyan_dark(),
    info: colours.blue_dark(),
    success: colours.green_dark(),
    warning: colours.yellow_dark(),
    error: colours.red_dark(),
  )
}

// MANIPULATIONS ---------------------------------------------------------------

///
///
pub fn with_heading_font(font: String, theme: Theme) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, heading: font))
}

///
///
pub fn with_body_font(font: String, theme: Theme) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, body: font))
}

///
///
pub fn with_code_font(font: String, theme: Theme) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, code: font))
}

///
///
pub fn with_radius(scale: Sizes, theme: Theme) -> Theme {
  Theme(..theme, radius: scale)
}

///
///
pub fn with_space(scale: Sizes, theme: Theme) -> Theme {
  Theme(..theme, space: scale)
}

///
///
pub fn with_base_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, base: colours)
}

///
///
pub fn with_primary_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, primary: colours)
}

///
///
pub fn with_secondary_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, secondary: colours)
}

///
///
pub fn with_info_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, info: colours)
}

///
///
pub fn with_success_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, success: colours)
}

///
///
pub fn with_warning_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, warning: colours)
}

///
///
pub fn with_error_colours(colours: Colours, theme: Theme) -> Theme {
  Theme(..theme, error: colours)
}

// CONVERSIONS -----------------------------------------------------------------

///
///
pub fn to_stylesheet(
  theme: Theme,
  selector: Option(String),
  dark: Option(#(Theme, DarkModeSource)),
) -> String {
  todo
}

///
///
pub fn to_styles(
  theme: Theme,
  selector: Option(String),
  dark: Option(#(Theme, DarkModeSource)),
) -> Element(msg) {
  let data_attribute = case theme.id {
    "" -> attribute.none()
    id ->
      attribute(
        "data-lustre-ui-theme",
        string.trim(id) |> string.replace(" ", "-"),
      )
  }

  html.style([data_attribute], to_stylesheet(theme, selector, dark))
}

///
///
pub fn to_global_styles(theme: Theme) -> Element(msg) {
  to_styles(theme, None, None)
}

///
///
pub fn to_class_styles(theme: Theme, class: String) -> Element(msg) {
  to_styles(theme, Some("." <> class), None)
}

fn to_css_variables(theme: Theme) -> List(#(String, String)) {
  list.concat([
    [
      #(var("font-heading"), theme.font.heading),
      #(var("font-body"), theme.font.body),
      #(var("font-code"), theme.font.code),
      #(var("radius-xs"), float.to_string(theme.radius.xs) <> "rem"),
      #(var("radius-sm"), float.to_string(theme.radius.sm) <> "rem"),
      #(var("radius-md"), float.to_string(theme.radius.md) <> "rem"),
      #(var("radius-lg"), float.to_string(theme.radius.lg) <> "rem"),
      #(var("radius-xl"), float.to_string(theme.radius.xl) <> "rem"),
      #(var("radius-xl-2"), float.to_string(theme.radius.xl_2) <> "rem"),
      #(var("radius-xl-3"), float.to_string(theme.radius.xl_3) <> "rem"),
      #(var("space-xs"), float.to_string(theme.space.xs) <> "rem"),
      #(var("space-sm"), float.to_string(theme.space.sm) <> "rem"),
      #(var("space-md"), float.to_string(theme.space.md) <> "rem"),
      #(var("space-lg"), float.to_string(theme.space.lg) <> "rem"),
      #(var("space-xl"), float.to_string(theme.space.xl) <> "rem"),
      #(var("space-xl-2"), float.to_string(theme.space.xl_2) <> "rem"),
      #(var("space-xl-3"), float.to_string(theme.space.xl_3) <> "rem"),
    ],
    to_colours_variables(theme.base, "base"),
    to_colours_variables(theme.primary, "primary"),
    to_colours_variables(theme.secondary, "secondary"),
    to_colours_variables(theme.info, "info"),
    to_colours_variables(theme.success, "success"),
    to_colours_variables(theme.warning, "warning"),
    to_colours_variables(theme.error, "error"),
  ])
}

fn to_colours_variables(
  colours: Colours,
  name: String,
) -> List(#(String, String)) {
  [
    #(var(name <> "-bg"), to_rgb_segments(colours.bg)),
    #(var(name <> "-bg-subtle"), to_rgb_segments(colours.bg_subtle)),
    #(var(name <> "-tint"), to_rgb_segments(colours.tint)),
    #(var(name <> "-tint-subtle"), to_rgb_segments(colours.tint_subtle)),
    #(var(name <> "-tint-strong"), to_rgb_segments(colours.tint_strong)),
    #(var(name <> "-accent"), to_rgb_segments(colours.accent)),
    #(var(name <> "-accent-subtle"), to_rgb_segments(colours.accent_subtle)),
    #(var(name <> "-accent-strong"), to_rgb_segments(colours.accent_strong)),
    #(var(name <> "-solid"), to_rgb_segments(colours.solid)),
    #(var(name <> "-solid-subtle"), to_rgb_segments(colours.solid_subtle)),
    #(var(name <> "-solid-strong"), to_rgb_segments(colours.solid_strong)),
    #(var(name <> "-solid-text"), to_rgb_segments(colours.solid_text)),
    #(var(name <> "-text"), to_rgb_segments(colours.text)),
    #(var(name <> "-text-subtle"), to_rgb_segments(colours.text_subtle)),
  ]
}

fn to_rgb_segments(colour: Colour) -> String {
  let #(r, g, b, _) = colour.to_rgba(colour)
  let r = float.round(r *. 255.0) |> int.to_string
  let g = float.round(g *. 255.0) |> int.to_string
  let b = float.round(b *. 255.0) |> int.to_string

  r <> " " <> g <> " " <> b
}

fn var(name: String) -> String {
  "--" <> prefix <> "-" <> name
}
