// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type DecodeError, type Dynamic, DecodeError}
import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
import gleam/string
import gleam_community/colour.{type Colour} as gleam_community_colour
import lustre/attribute.{attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/colour.{type ColourPalette, type ColourScale, ColourPalette}

// TYPES -----------------------------------------------------------------------

/// A Lustre UI theme dictates the visual style of an application. It defines a
/// number of design tokens to set common styles such as fonts, colours, and
/// spacing.
///
/// These design tokens can be used in your own components and styles to ensure
/// a consistent look and feel in your application. For example you might want
/// to colour a span of text with the primary colour of your theme by doing:
///
/// ```gleam
/// html.span([attribute.style([#("color", theme.primary.solid_text)])], [
///   html.text("Hello, world!")
/// ])
/// ```
///
/// You can construct a blank theme using the [`new`](#new) function, or start
/// with a sensible default using the Lustre UI's [`default`](#default) theme.
///
/// A theme can be further customised using the various `with_` functions, such
/// as [`with_primary_scale`](#with_primary_scale), [`with_space`](#with_space),
/// or [`with_dark_palette`](#with_dark_palette).
///
pub opaque type Theme {
  Theme(
    id: String,
    selector: Selector,
    //
    font: Fonts,
    radius: SizeScale,
    space: SizeScale,
    //
    light: ColourPalette,
    dark: Option(#(Selector, ColourPalette)),
  )
}

/// Configuration for the different fonts that can be used in a themed application.
/// Each font `String` should match the format you would write in a CSS `font-family`
/// rule.
///
/// If you are using custom fonts, remember to make sure the font is loaded in your
/// app, either through a `<link>` tag, or a CSS `@import`.
///
pub type Fonts {
  Fonts(heading: String, body: String, code: String)
}

/// Configuration for the different size values that can be used for different
/// parts of a themed application. Both a theme's `space` scale as well as the
/// different options for border `radius` are configured by a `SizeScale`.
///
/// Each field is a value in `rem` units. So a value of `12.0` would be `12.0rem`
/// in CSS, **not** `12.0px`. This means your space scale remains adaptive even
/// if the user configures their browser to render smaller or larger text (for
/// example when zooming or for accessibility reasons.)
///
pub type SizeScale {
  SizeScale(
    xs: Float,
    sm: Float,
    md: Float,
    lg: Float,
    xl: Float,
    xl_2: Float,
    xl_3: Float,
  )
}

/// Configures the CSS selector used when applying a theme or a theme's dark
/// mode.
///
pub type Selector {
  Global
  Class(String)
  DataAttribute(String, String)
}

// CONSTANTS -------------------------------------------------------------------

const sans = "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\""

const code = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"

// CONSTRUCTORS ----------------------------------------------------------------

/// Construct an empty theme with the given id and selector. The theme will have
/// a sensible default configuration for fonts, radius, and space, but the colour
/// palette will be empty.
///
/// You can customise the theme further using the various `with_` functions, such
/// as [`with_primary_scale`](#with_primary_scale), [`with_space`](#with_space),
/// [`with_dark_palette`](#with_dark_palette), etc.
///
pub fn new(id: String, selector: Selector) -> Theme {
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = SizeScale(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = SizeScale(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  let light =
    ColourPalette(
      base: colour.slate(),
      primary: colour.slate(),
      secondary: colour.slate(),
      success: colour.slate(),
      warning: colour.slate(),
      danger: colour.slate(),
    )

  Theme(
    id: case id {
      "" -> "default"
      id -> id
    },
    selector: selector,
    //
    font: font,
    radius: radius,
    space: space,
    //
    light: light,
    dark: None,
  )
}

/// Construct Lustre UI's default theme. This theme defines some sensible defaults
/// for fonts, radius, and space, and provides both a light and dark mode palette.
/// The light mode palette applies globally, and the dark mode palette applies if
/// the user has enabled dark mode in their operating system or browser, or if you
/// manually set the `"dark"` class on an element.
///
/// You can customise the theme further using the various `with_` functions, such
/// as [`with_primary_scale`](#with_primary_scale), [`with_space`](#with_space),
/// [`with_dark_palette`](#with_dark_palette), etc.
///
pub fn default() -> Theme {
  let id = "lustre-ui-default"
  let font = Fonts(heading: sans, body: sans, code: code)
  let radius = SizeScale(0.125, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5)
  let space = SizeScale(0.25, 0.5, 0.75, 1.0, 1.5, 2.5, 4.0)

  let light = colour.default_light_palette()
  let dark = colour.default_dark_palette()

  Theme(
    id: id,
    selector: Global,
    font: font,
    radius: radius,
    space: space,
    light: light,
    dark: Some(#(Class("dark"), dark)),
  )
}

// MANIPULATIONS ---------------------------------------------------------------

/// Set all of the fonts in a theme at once.
///
pub fn with_fonts(theme: Theme, fonts: Fonts) -> Theme {
  Theme(..theme, font: fonts)
}

/// Replace the heading font in a theme with a new value. The provided string
/// should match the kind of font stack you might write in a CSS `font-family`
/// rule.
///
/// The heading font is typically used in the title and section headings in prose,
/// but can also be used in heroes and other prominent sections.
///
pub fn with_heading_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, heading: font))
}

/// Replace the body font in a theme with a new value. The provided string
/// should match the kind of font stack you might write in a CSS `font-family`
/// rule.
///
/// The body font is typically used throughout an interface as the primary font
/// in all copy.
///
pub fn with_body_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, body: font))
}

/// Replace the code font in a theme with a new value. The provided string
/// should match the kind of font stack you might write in a CSS `font-family`
/// rule.
///
/// The code font is typically a monospaced font used for code snippets in prose,
/// but may also be used as an alternative heading font or otherwise used as an
/// alternative to the body font.
///
pub fn with_code_font(theme: Theme, font: String) -> Theme {
  Theme(..theme, font: Fonts(..theme.font, code: font))
}

/// Set the size scale used for border radius in a theme. The radius scale determines
/// how rounded the elements in your application UI appear.
///
pub fn with_radius(theme: Theme, scale: SizeScale) -> Theme {
  Theme(..theme, radius: scale)
}

/// Set the space scale in a theme. The space scale determines how much visual
/// space there is in your UI. It is used both within elements as padding and
/// between elements to separate them in a collection.
///
pub fn with_space(theme: Theme, scale: SizeScale) -> Theme {
  Theme(..theme, space: scale)
}

/// Set a theme's default colour palette with a new one.
///
pub fn with_light_palette(theme: Theme, light: ColourPalette) -> Theme {
  Theme(..theme, light: light)
}

/// Replace the base colour scale of a theme's default colour palette with a new
/// one.
///
pub fn with_base_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, base: scale))
}

/// Replace the primary colour scale of a theme's default colour palette with a
/// new one.
///
pub fn with_primary_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, primary: scale))
}

/// Replace the secondary colour scale of a theme's default colour palette with a
/// new one.
///
pub fn with_secondary_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, secondary: scale))
}

/// Replace the success colour scale of a theme's default colour palette with a
/// new one.
///
pub fn with_success_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, success: scale))
}

/// Replace the warning colour scale of a theme's default colour palette with a
/// new one.
///
pub fn with_warning_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, warning: scale))
}

/// Replace the danger colour scale of a theme's default colour palette with a
/// new one.
///
pub fn with_danger_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(..theme, light: ColourPalette(..theme.light, danger: scale))
}

/// Add a new dark mode colour palette or replace a theme's existing palette with
/// a new one.
///
/// The [`Selector`](#Selector) used to apply a theme will switch over to the
/// dark mode colour palette if a user has indicated through their OS settings
/// that they prefer a dark colour scheme. Additionally, a selector _other than
/// `Global`_ can be used to enable dark mode for a specific part of the UI.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_palette(
  theme: Theme,
  selector: Selector,
  palette: ColourPalette,
) -> Theme {
  Theme(..theme, dark: Some(#(selector, palette)))
}

/// Replace the base colour scale of a theme's dark mode colour palette with a
/// new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_base_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, base: scale)
    })),
  )
}

/// Replace the primary colour scale of a theme's dark mode colour palette with
/// a new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_primary_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, primary: scale)
    })),
  )
}

/// Replace the secondary colour scale of a theme's dark mode colour palette with
/// a new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_secondary_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, secondary: scale)
    })),
  )
}

/// Replace the success colour scale of a theme's dark mode colour palette with
/// a new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_success_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, success: scale)
    })),
  )
}

/// Replace the warning colour scale of a theme's dark mode colour palette with
/// a new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_warning_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, warning: scale)
    })),
  )
}

/// Replace the danger colour scale of a theme's dark mode colour palette with
/// a new one. If the theme does not have a dark mode registered, calling this
/// function will do nothing.
///
/// All of the colour scales in the [colours module](./colour.html) have
/// corresponding dark mode variants
///
pub fn with_dark_danger_scale(theme: Theme, scale: ColourScale) -> Theme {
  Theme(
    ..theme,
    dark: option.map(theme.dark, pair.map_second(_, fn(dark) {
      ColourPalette(..dark, danger: scale)
    })),
  )
}

// CONVERSIONS -----------------------------------------------------------------

/// Render a `Theme` as a `<style>` tag.
///
pub fn to_style(theme theme: Theme) -> Element(msg) {
  let data_attr = attribute("data-lustre-ui-theme", theme.id)

  case theme.selector, theme.dark {
    Global, None ->
      stylesheet_global_light_no_dark
      |> string.replace("${rules}", to_css_variables(theme))
      |> html.style([data_attr], _)

    Global, Some(#(Global, dark_palette)) ->
      stylesheet_global_light_global_dark
      |> string.replace("${rules}", to_css_variables(theme))
      |> string.replace(
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark"),
      )
      |> html.style([data_attr], _)

    Global, Some(#(dark_selector, dark_palette)) ->
      stylesheet_global_light_scoped_dark
      |> string.replace("${rules}", to_css_variables(theme))
      |> string.replace("${dark_selector}", to_css_selector(dark_selector))
      |> string.replace(
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark"),
      )
      |> html.style([data_attr], _)

    selector, None ->
      stylesheet_scoped_light_no_dark
      |> string.replace("${selector}", to_css_selector(selector))
      |> string.replace("${rules}", to_css_variables(theme))
      |> html.style([data_attr], _)

    selector, Some(#(Global, dark_palette)) ->
      stylesheet_scoped_light_global_dark
      |> string.replace("${selector}", to_css_selector(selector))
      |> string.replace("${rules}", to_css_variables(theme))
      |> string.replace(
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark"),
      )
      |> html.style([data_attr], _)

    selector, Some(#(dark_selector, dark_palette)) ->
      stylesheet_scoped_light_scoped_dark
      |> string.replace("${selector}", to_css_selector(selector))
      |> string.replace("${rules}", to_css_variables(theme))
      |> string.replace("${dark_selector}", to_css_selector(dark_selector))
      |> string.replace(
        "${dark_rules}",
        to_color_palette_variables(dark_palette, "dark"),
      )
      |> html.style([data_attr], _)
  }
}

const stylesheet_global_light_no_dark = "
body {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}
"

const stylesheet_global_light_global_dark = "
body {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}

@media (prefers-color-scheme: dark) {
  body {
    ${dark_rules}
  }
}
"

const stylesheet_global_light_scoped_dark = "
body {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}

body${dark_selector}, body ${dark_selector} {
  ${dark_rules}
}

@media (prefers-color-scheme: dark) {
  body {
    ${dark_rules}
  }
}
"

const stylesheet_scoped_light_no_dark = "
${selector} {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}
"

const stylesheet_scoped_light_global_dark = "
${selector} {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}

@media (prefers-color-scheme: dark) {
  ${selector} {
    ${dark_rules}
  }
}
"

const stylesheet_scoped_light_scoped_dark = "
${selector} {
  ${rules}

  background-color: rgb(var(--lustre-ui-bg));
  color: rgb(var(--lustre-ui-text));
}

${selector}${dark_selector}, ${selector} ${dark_selector} {
  ${dark_rules}
}

@media (prefers-color-scheme: dark) {
  ${selector} {
    ${dark_rules}
  }
}
"

fn to_css_selector(selector: Selector) -> String {
  case selector {
    Global -> ""
    Class(class) -> "." <> class
    DataAttribute(name, "") -> "[data-" <> name <> "]"
    DataAttribute(name, value) -> "[data-" <> name <> "=" <> value <> "]"
  }
}

fn to_css_variables(theme: Theme) -> String {
  string.concat([
    to_css_variable("id", theme.id),
    to_css_variable("font-heading", theme.font.heading),
    to_css_variable("font-body", theme.font.body),
    to_css_variable("font-code", theme.font.code),
    to_css_variable("radius-xs", float.to_string(theme.radius.xs) <> "rem"),
    to_css_variable("radius-sm", float.to_string(theme.radius.sm) <> "rem"),
    to_css_variable("radius-md", float.to_string(theme.radius.md) <> "rem"),
    to_css_variable("radius-lg", float.to_string(theme.radius.lg) <> "rem"),
    to_css_variable("radius-xl", float.to_string(theme.radius.xl) <> "rem"),
    to_css_variable("radius-xl-2", float.to_string(theme.radius.xl_2) <> "rem"),
    to_css_variable("radius-xl-3", float.to_string(theme.radius.xl_3) <> "rem"),
    to_css_variable("spacing-xs", float.to_string(theme.space.xs) <> "rem"),
    to_css_variable("spacing-sm", float.to_string(theme.space.sm) <> "rem"),
    to_css_variable("spacing-md", float.to_string(theme.space.md) <> "rem"),
    to_css_variable("spacing-lg", float.to_string(theme.space.lg) <> "rem"),
    to_css_variable("spacing-xl", float.to_string(theme.space.xl) <> "rem"),
    to_css_variable("spacing-xl-2", float.to_string(theme.space.xl_2) <> "rem"),
    to_css_variable("spacing-xl-3", float.to_string(theme.space.xl_3) <> "rem"),
    to_color_palette_variables(theme.light, "light"),
  ])
}

fn to_color_palette_variables(palette: ColourPalette, scheme: String) -> String {
  string.concat([
    to_css_variable("color-scheme", scheme),
    //
    to_colour_scale_variables(palette.base, "base"),
    to_colour_scale_variables(palette.primary, "primary"),
    to_colour_scale_variables(palette.secondary, "secondary"),
    to_colour_scale_variables(palette.success, "success"),
    to_colour_scale_variables(palette.warning, "warning"),
    to_colour_scale_variables(palette.danger, "danger"),
    //
    "--lustre-ui-bg: var(--lustre-ui-base-bg);",
    "--lustre-ui-bg-subtle: var(--lustre-ui-base-bg-subtle);",
    "--lustre-ui-tint: var(--lustre-ui-base-tint);",
    "--lustre-ui-tint-subtle: var(--lustre-ui-base-tint-subtle);",
    "--lustre-ui-tint-strong: var(--lustre-ui-base-tint-strong);",
    "--lustre-ui-accent: var(--lustre-ui-base-accent);",
    "--lustre-ui-accent-subtle: var(--lustre-ui-base-accent-subtle);",
    "--lustre-ui-accent-strong: var(--lustre-ui-base-accent-strong);",
    "--lustre-ui-solid: var(--lustre-ui-base-solid);",
    "--lustre-ui-solid-subtle: var(--lustre-ui-base-solid-subtle);",
    "--lustre-ui-solid-strong: var(--lustre-ui-base-solid-strong);",
    "--lustre-ui-solid-text: var(--lustre-ui-base-solid-text);",
    "--lustre-ui-text: var(--lustre-ui-base-text);",
    "--lustre-ui-text-subtle: var(--lustre-ui-base-text-subtle);",
  ])
}

fn to_colour_scale_variables(scale: ColourScale, name: String) -> String {
  string.concat([
    to_css_variable(name <> "-bg", to_css_rgb(scale.bg)),
    to_css_variable(name <> "-bg-subtle", to_css_rgb(scale.bg_subtle)),
    to_css_variable(name <> "-tint", to_css_rgb(scale.tint)),
    to_css_variable(name <> "-tint-subtle", to_css_rgb(scale.tint_subtle)),
    to_css_variable(name <> "-tint-strong", to_css_rgb(scale.tint_strong)),
    to_css_variable(name <> "-accent", to_css_rgb(scale.accent)),
    to_css_variable(name <> "-accent-subtle", to_css_rgb(scale.accent_subtle)),
    to_css_variable(name <> "-accent-strong", to_css_rgb(scale.accent_strong)),
    to_css_variable(name <> "-solid", to_css_rgb(scale.solid)),
    to_css_variable(name <> "-solid-subtle", to_css_rgb(scale.solid_subtle)),
    to_css_variable(name <> "-solid-strong", to_css_rgb(scale.solid_strong)),
    to_css_variable(name <> "-solid-text", to_css_rgb(scale.solid_text)),
    to_css_variable(name <> "-text", to_css_rgb(scale.text)),
    to_css_variable(name <> "-text-subtle", to_css_rgb(scale.text_subtle)),
  ])
}

fn to_css_rgb(colour: Colour) -> String {
  let #(r, g, b, _) = gleam_community_colour.to_rgba(colour)
  let r = float.round(r *. 255.0) |> int.to_string
  let g = float.round(g *. 255.0) |> int.to_string
  let b = float.round(b *. 255.0) |> int.to_string

  r <> " " <> g <> " " <> b
}

fn to_css_variable(name: String, value: String) {
  var(name) <> ":" <> value <> ";"
}

fn var(name: String) -> String {
  "--lustre-ui-" <> name
}

// JSON ------------------------------------------------------------------------

pub fn encode(theme: Theme) -> Json {
  json.object([
    #("id", json.string(theme.id)),
    #("selector", encode_selector(theme.selector)),
    #("font", encode_fonts(theme.font)),
    #("radius", encode_sizes(theme.radius)),
    #("space", encode_sizes(theme.space)),
    #("light", colour.encode_palette(theme.light)),
    #("dark", case theme.dark {
      Some(#(selector, dark)) ->
        json.preprocessed_array([
          encode_selector(selector),
          colour.encode_palette(dark),
        ])
      None -> json.null()
    }),
  ])
}

fn encode_selector(selector: Selector) -> Json {
  case selector {
    Global -> json.object([#("kind", json.string("Global"))])
    Class(class) ->
      json.object([
        #("kind", json.string("Class")),
        #("class", json.string(class)),
      ])
    DataAttribute(name, value) ->
      json.object([
        #("kind", json.string("DataAttribute")),
        #("name", json.string(name)),
        #("value", json.string(value)),
      ])
  }
}

fn encode_fonts(fonts: Fonts) -> Json {
  json.object([
    #("heading", json.string(fonts.heading)),
    #("body", json.string(fonts.body)),
    #("code", json.string(fonts.code)),
  ])
}

fn encode_sizes(sizes: SizeScale) -> Json {
  json.object([
    #("xs", json.float(sizes.xs)),
    #("sm", json.float(sizes.sm)),
    #("md", json.float(sizes.md)),
    #("lg", json.float(sizes.lg)),
    #("xl", json.float(sizes.xl)),
    #("xl-2", json.float(sizes.xl_2)),
    #("xl-3", json.float(sizes.xl_3)),
  ])
}

pub fn decoder(json: Dynamic) -> Result(Theme, List(DecodeError)) {
  dynamic.decode7(
    Theme,
    dynamic.field("id", dynamic.string),
    dynamic.field("selector", selector_decoder),
    dynamic.field("font", fonts_decoder),
    dynamic.field("radius", sizes_decoder),
    dynamic.field("space", sizes_decoder),
    dynamic.field("light", colour.palette_decoder),
    dynamic.field(
      "dark",
      dynamic.optional(dynamic.tuple2(selector_decoder, colour.palette_decoder)),
    ),
  )(json)
}

fn selector_decoder(json: Dynamic) -> Result(Selector, List(DecodeError)) {
  use kind <- result.try(dynamic.field("kind", dynamic.string)(json))

  case kind {
    "Global" -> Ok(Global)
    "Class" ->
      json |> dynamic.decode1(Class, dynamic.field("class", dynamic.string))
    "DataAttribute" ->
      json
      |> dynamic.decode2(
        DataAttribute,
        dynamic.field("name", dynamic.string),
        dynamic.field("value", dynamic.string),
      )
    _ ->
      Error([
        DecodeError(
          expected: "'Global' | 'Class' | 'DataAttribute'",
          found: kind,
          path: ["kind"],
        ),
      ])
  }
}

fn fonts_decoder(json: Dynamic) -> Result(Fonts, List(DecodeError)) {
  dynamic.decode3(
    Fonts,
    dynamic.field("heading", dynamic.string),
    dynamic.field("body", dynamic.string),
    dynamic.field("code", dynamic.string),
  )(json)
}

fn sizes_decoder(json: Dynamic) -> Result(SizeScale, List(DecodeError)) {
  dynamic.decode7(
    SizeScale,
    dynamic.field("xs", dynamic.float),
    dynamic.field("sm", dynamic.float),
    dynamic.field("md", dynamic.float),
    dynamic.field("lg", dynamic.float),
    dynamic.field("xl", dynamic.float),
    dynamic.field("xl-2", dynamic.float),
    dynamic.field("xl-3", dynamic.float),
  )(json)
}

// THEME TOKENS ---------------------------------------------------------------

///
///
pub type FontVariables {
  FontVariables(heading: String, body: String, code: String)
}

///
///
pub type SizeVariables {
  SizeVariables(
    xs: String,
    sm: String,
    md: String,
    lg: String,
    xl: String,
    xl_2: String,
    xl_3: String,
  )
}

///
///
pub type ColourScaleVariables {
  ColourScaleVariables(
    bg: String,
    bg_subtle: String,
    //
    tint: String,
    tint_subtle: String,
    tint_strong: String,
    //
    accent: String,
    accent_subtle: String,
    accent_strong: String,
    //
    solid: String,
    solid_subtle: String,
    solid_strong: String,
    solid_text: String,
    //
    text: String,
    text_subtle: String,
  )
}

/// A record that lets you access theme tokens related to fonts. You could use
/// these when styling elements yourself either with the `style` attribute or
/// with [sketch](https://hexdocs.pm/sketch/), a CSS-in-Gleam library.
///
pub const font = FontVariables(
  heading: "var(--lustre-ui-font-heading)",
  body: "var(--lustre-ui-body-heading)",
  code: "var(--lustre-ui-code-heading)",
)

/// A record that lets you access theme tokens related to spacing. You could use
/// these when styling elements yourself either with the `style` attribute or
/// with [sketch](https://hexdocs.pm/sketch/), a CSS-in-Gleam library.
///
/// These spacing variables are typically used to add margin or a gap between
/// elements in a layout, or to add padding to an element.
///
pub const spacing = SizeVariables(
  xs: "var(--lustre-ui-spacing-xs)",
  sm: "var(--lustre-ui-spacing-sm)",
  md: "var(--lustre-ui-spacing-md)",
  lg: "var(--lustre-ui-spacing-lg)",
  xl: "var(--lustre-ui-spacing-xl)",
  xl_2: "var(--lustre-ui-spacing-xl_2)",
  xl_3: "var(--lustre-ui-spacing-xl_3)",
)

/// A record that lets you access theme tokens related to border radius. You
/// could use these when styling elements yourself either with the `style`
/// attribute or with [sketch](https://hexdocs.pm/sketch/), a CSS-in-Gleam
/// library.
///
/// These border radius variables are typically used to round the corners of an
/// element.
///
pub const radius = SizeVariables(
  xs: "var(--lustre-ui-radius-xs)",
  sm: "var(--lustre-ui-radius-sm)",
  md: "var(--lustre-ui-radius-md)",
  lg: "var(--lustre-ui-radius-lg)",
  xl: "var(--lustre-ui-radius-xl)",
  xl_2: "var(--lustre-ui-radius-xl_2)",
  xl_3: "var(--lustre-ui-radius-xl_3)",
)

/// A record that lets you access theme tokens related to the current colour
/// scale. The current colour scale is _context-dependent_ and depends on the
/// CSS cascade: if a parent element higher up the tree sets the `data-scale`
/// attribute or applies a class like `.lustre-ui-primary`, these tokens will
/// match the colours from that scale.
///
pub const colour = ColourScaleVariables(
  bg: "var(--lustre-ui-bg)",
  bg_subtle: "var(--lustre-ui-bg-subtle)",
  tint: "var(--lustre-ui-tint)",
  tint_subtle: "var(--lustre-ui-tint-subtle)",
  tint_strong: "var(--lustre-ui-tint-strong)",
  accent: "var(--lustre-ui-accent)",
  accent_subtle: "var(--lustre-ui-accent-subtle)",
  accent_strong: "var(--lustre-ui-accent-strong)",
  solid: "var(--lustre-ui-solid)",
  solid_subtle: "var(--lustre-ui-solid-subtle)",
  solid_strong: "var(--lustre-ui-solid-strong)",
  solid_text: "var(--lustre-ui-solid-text)",
  text: "var(--lustre-ui-text)",
  text_subtle: "var(--lustre-ui-text-subtle)",
)

/// A record that lets you access theme tokens for the base colour scale of the
/// theme. The base colour scale is typically a greyscale or neutral scale.
///
pub const base = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-base-bg))",
  bg_subtle: "rgb(var(--lustre-ui-base-bg-subtle))",
  tint: "rgb(var(--lustre-ui-base-tint))",
  tint_subtle: "rgb(var(--lustre-ui-base-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-base-tint-strong))",
  accent: "rgb(var(--lustre-ui-base-accent))",
  accent_subtle: "rgb(var(--lustre-ui-base-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-base-accent-strong))",
  solid: "rgb(var(--lustre-ui-base-solid))",
  solid_subtle: "rgb(var(--lustre-ui-base-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-base-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-base-solid-text))",
  text: "rgb(var(--lustre-ui-base-text))",
  text_subtle: "rgb(var(--lustre-ui-base-text_subtle))",
)

/// A record that lets you access theme tokens for the primary colour scale of
/// the theme. The primary colour scale is typically your brand colour.
///
pub const primary = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-primary-bg))",
  bg_subtle: "rgb(var(--lustre-ui-primary-bg-subtle))",
  tint: "rgb(var(--lustre-ui-primary-tint))",
  tint_subtle: "rgb(var(--lustre-ui-primary-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-primary-tint-strong))",
  accent: "rgb(var(--lustre-ui-primary-accent))",
  accent_subtle: "rgb(var(--lustre-ui-primary-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-primary-accent-strong))",
  solid: "rgb(var(--lustre-ui-primary-solid))",
  solid_subtle: "rgb(var(--lustre-ui-primary-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-primary-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-primary-solid-text))",
  text: "rgb(var(--lustre-ui-primary-text))",
  text_subtle: "rgb(var(--lustre-ui-primary-text_subtle))",
)

/// A record that lets you access theme tokens for the secondary colour scale of
/// the theme. The secondary colour scale is typically used as an accent or
/// compliment to your primary colour.
///
pub const secondary = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-secondary-bg))",
  bg_subtle: "rgb(var(--lustre-ui-secondary-bg-subtle))",
  tint: "rgb(var(--lustre-ui-secondary-tint))",
  tint_subtle: "rgb(var(--lustre-ui-secondary-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-secondary-tint-strong))",
  accent: "rgb(var(--lustre-ui-secondary-accent))",
  accent_subtle: "rgb(var(--lustre-ui-secondary-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-secondary-accent-strong))",
  solid: "rgb(var(--lustre-ui-secondary-solid))",
  solid_subtle: "rgb(var(--lustre-ui-secondary-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-secondary-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-secondary-solid-text))",
  text: "rgb(var(--lustre-ui-secondary-text))",
  text_subtle: "rgb(var(--lustre-ui-secondary-text_subtle))",
)

/// A record that lets you access theme tokens for the success colour scale of
/// the theme. The success colour scale is typically used in parts of your UI
/// that indicate an action was successful.
///
pub const success = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-success-bg))",
  bg_subtle: "rgb(var(--lustre-ui-success-bg-subtle))",
  tint: "rgb(var(--lustre-ui-success-tint))",
  tint_subtle: "rgb(var(--lustre-ui-success-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-success-tint-strong))",
  accent: "rgb(var(--lustre-ui-success-accent))",
  accent_subtle: "rgb(var(--lustre-ui-success-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-success-accent-strong))",
  solid: "rgb(var(--lustre-ui-success-solid))",
  solid_subtle: "rgb(var(--lustre-ui-success-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-success-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-success-solid-text))",
  text: "rgb(var(--lustre-ui-success-text))",
  text_subtle: "rgb(var(--lustre-ui-success-text_subtle))",
)

/// A record that lets you access theme tokens for the warning colour scale of
/// the theme. The warning colour scale is typically used in parts of your UI
/// to indicate non-critical information or notify users that an action may have
/// non-destructive consequences.
///
pub const warning = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-warning-bg))",
  bg_subtle: "rgb(var(--lustre-ui-warning-bg-subtle))",
  tint: "rgb(var(--lustre-ui-warning-tint))",
  tint_subtle: "rgb(var(--lustre-ui-warning-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-warning-tint-strong))",
  accent: "rgb(var(--lustre-ui-warning-accent))",
  accent_subtle: "rgb(var(--lustre-ui-warning-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-warning-accent-strong))",
  solid: "rgb(var(--lustre-ui-warning-solid))",
  solid_subtle: "rgb(var(--lustre-ui-warning-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-warning-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-warning-solid-text))",
  text: "rgb(var(--lustre-ui-warning-text))",
  text_subtle: "rgb(var(--lustre-ui-warning-text_subtle))",
)

/// A record that lets you access theme tokens for the danger colour scale of
/// the theme. The danger colour scale is typically used in parts of your UI
/// that indicate critical information or notify users that an action will have
/// destructive consequences.
///
pub const danger = ColourScaleVariables(
  bg: "rgb(var(--lustre-ui-danger-bg))",
  bg_subtle: "rgb(var(--lustre-ui-danger-bg-subtle))",
  tint: "rgb(var(--lustre-ui-danger-tint))",
  tint_subtle: "rgb(var(--lustre-ui-danger-tint-subtle))",
  tint_strong: "rgb(var(--lustre-ui-danger-tint-strong))",
  accent: "rgb(var(--lustre-ui-danger-accent))",
  accent_subtle: "rgb(var(--lustre-ui-danger-accent-subtle))",
  accent_strong: "rgb(var(--lustre-ui-danger-accent-strong))",
  solid: "rgb(var(--lustre-ui-danger-solid))",
  solid_subtle: "rgb(var(--lustre-ui-danger-solid-subtle))",
  solid_strong: "rgb(var(--lustre-ui-danger-solid-strong))",
  solid_text: "rgb(var(--lustre-ui-danger-solid-text))",
  text: "rgb(var(--lustre-ui-danger-text))",
  text_subtle: "rgb(var(--lustre-ui-danger-text_subtle))",
)
