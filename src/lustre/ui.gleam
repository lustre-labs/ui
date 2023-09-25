// IMPORTS ---------------------------------------------------------------------

import gleam_community/colour
import gleam/map.{Map}
import gleam/string
import gleam/int
import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html
import lustre/ui/colours.{Scale}
import lustre/ui/listbox

// CONSTANTS -------------------------------------------------------------------

pub const app_background: String = "--app-background"

pub const app_background_subtle: String = "--app-background-subtle"

pub const app_border: String = "--app-border"

pub const element_background: String = "--element-background"

pub const element_background_hover: String = "--element-background-hover"

pub const element_background_strong: String = "--element-background-strong"

pub const element_border_subtle: String = "--element-border-subtle"

pub const element_border_strong: String = "--element-border-strong"

pub const solid_background: String = "--solid-background"

pub const solid_background_hover: String = "--solid-background-hover"

pub const text_high_contrast: String = "--text-high-contrast"

pub const text_low_contrast: String = "--text-low-contrast"

pub const text_xs: String = "--text-xs"

pub const text_sm: String = "--text-sm"

pub const text_base: String = "--text-base"

pub const text_md: String = "--text-md"

pub const text_lg: String = "--text-lg"

pub const text_xl: String = "--text-xl"

pub const text_2xl: String = "--text-2xl"

pub const text_3xl: String = "--text-3xl"

pub const text_4xl: String = "--text-4xl"

pub const space_xs: String = "--space-xs"

pub const space_sm: String = "--space-sm"

pub const space_base: String = "--space-base"

pub const space_md: String = "--space-md"

pub const space_lg: String = "--space-lg"

pub const space_xl: String = "--space-xl"

pub const space_2xl: String = "--space-2xl"

pub const space_3xl: String = "--space-3xl"

pub const space_4xl: String = "--space-4xl"

pub const font_base: String = "--font-base"

pub const font_alt: String = "--font-alt"

pub const font_mono: String = "--font-mono"

pub const border_radius: String = "--border-radius"

// TYPES -----------------------------------------------------------------------

///
/// 
pub type Theme {
  Theme(
    base_text: Int,
    border_radius: Int,
    primary: Scale,
    greyscale: Scale,
    error: Scale,
    warning: Scale,
    success: Scale,
    info: Scale,
  )
}

///
/// 
pub type Variant {
  Primary
  Greyscale
  Error
  Warning
  Success
  Info
}

// ELEMENTS --------------------------------------------------------------------

/// Lustre_ui's simple CSS reset, rendered as a `<style>` element.
/// 
pub fn reset() -> Element(a) {
  "
  *, *::before, *::after {
    box-sizing: border-box;
  }

  * {
    margin: 0;
  }

  body {
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
  }

  img, picture, video, canvas, svg {
    display: block;
    max-width: 100%;
  }

  input, button, textarea, select {
    font: inherit;
  }

  p, h1, h2, h3, h4, h5, h6 {
    overflow-wrap: break-word;
  }

  #root, [data-lustre-app] {
    isolation: isolate;
  }
  "
  |> html.style([], _)
}

/// Lustre_ui's base theme.
/// 
pub fn base() -> Element(a) {
  custom(Theme(
    base_text: 16,
    border_radius: 2,
    primary: colours.iris(),
    greyscale: colours.slate(),
    error: colours.red(),
    success: colours.green(),
    warning: colours.yellow(),
    info: colours.blue(),
  ))
}

pub fn custom(theme: Theme) -> Element(a) {
  ":root {
    --app-background: $(primary.app_background);
    --app-background-subtle: $(primary.app_background_subtle);
    --app-border: $(primary.app_border);

    --element-background: $(primary.element_background);
    --element-background-hover: $(primary.element_background_hover);
    --element-background-strong: $(primary.element_background_strong);

    --element-border-subtle: $(primary.element_border_subtle);
    --element-border-strong: $(primary.element_border_strong);

    --solid-background: $(primary.solid_background);
    --solid-background-hover: $(primary.solid_background_hover);
    
    --text-high-contrast: $(primary.text_high_contrast);
    --text-low-contrast: $(primary.text_low_contrast);

    --text-xs: calc(1em / pow(1.2, 2));
    --text-sm: calc(1em / 1.2);
    --text-base: $(base_text)px;;
    --text-md: calc(1em * 1.2);
    --text-lg: calc(1em * pow(1.2, 2));
    --text-xl: calc(1em * pow(1.2, 3));
    --text-2xl: calc(1em * pow(1.2, 4));
    --text-3xl: calc(1em * pow(1.2, 5));
    --text-4xl: calc(1em * pow(1.2, 6));
  
    --space-xs: calc(0.5 * 1em);
    --space-sm: calc(0.75 * 1em);
    --space-base: 1em;
    --space-md: calc(1.25 * 1em);
    --space-lg: calc(2 * 1em);
    --space-xl: calc(3.25 * 1em);
    --space-2xl: calc(5.25 * 1em);
    --space-3xl: calc(8.5 * 1em);
    --space-4xl: calc(13.75 * 1em);

    --font-base: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
    --font-alt:  ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif;
    --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;
  
    --border-radius: $(border_radius)px;

    --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
    --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
    --shadow-lg: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  }

  [data-variant=\"primary\"] {
    --app-background: $(primary.app_background);
    --app-background-subtle: $(primary.app_background_subtle);
    --app-border: $(primary.app_border);

    --element-background: $(primary.element_background);
    --element-background-hover: $(primary.element_background_hover);
    --element-background-strong: $(primary.element_background_strong);

    --element-border-subtle: $(primary.element_border_subtle);
    --element-border-strong: $(primary.element_border_strong);

    --solid-background: $(primary.solid_background);
    --solid-background-hover: $(primary.solid_background_hover);

    --text-high-contrast: $(primary.text_high_contrast);
    --text-low-contrast: $(primary.text_low_contrast);
  }

  [data-variant=\"greyscale\"] {
    --app-background: $(greyscale.app_background);
    --app-background-subtle: $(greyscale.app_background_subtle);
    --app-border: $(greyscale.app_border);
    
    --element-background: $(greyscale.element_background);
    --element-background-hover: $(greyscale.element_background_hover);
    --element-background-strong: $(greyscale.element_background_strong);

    --element-border-subtle: $(greyscale.element_border_subtle);
    --element-border-strong: $(greyscale.element_border_strong);

    --solid-background: $(greyscale.solid_background);
    --solid-background-hover: $(greyscale.solid_background_hover);

    --text-high-contrast: $(greyscale.text_high_contrast);
    --text-low-contrast: $(greyscale.text_low_contrast);
  }

  [data-variant=\"error\"] {
    --app-background: $(error.app_background);
    --app-background-subtle: $(error.app_background_subtle);
    --app-border: $(error.app_border);
    
    --element-background: $(error.element_background);
    --element-background-hover: $(error.element_background_hover);
    --element-background-strong: $(error.element_background_strong);

    --element-border-subtle: $(error.element_border_subtle);
    --element-border-strong: $(error.element_border_strong);

    --solid-background: $(error.solid_background);
    --solid-background-hover: $(error.solid_background_hover);

    --text-high-contrast: $(error.text_high_contrast);
    --text-low-contrast: $(error.text_low_contrast);
  }

  [data-variant=\"success\"] {
    --app-background: $(success.app_background);
    --app-background-subtle: $(success.app_background_subtle);
    --app-border: $(success.app_border);
    
    --element-background: $(success.element_background);
    --element-background-hover: $(success.element_background_hover);
    --element-background-strong: $(success.element_background_strong);

    --element-border-subtle: $(success.element_border_subtle);
    --element-border-strong: $(success.element_border_strong);

    --solid-background: $(success.solid_background);
    --solid-background-hover: $(success.solid_background_hover);

    --text-high-contrast: $(success.text_high_contrast);
    --text-low-contrast: $(success.text_low_contrast);
  }

  [data-variant=\"warning\"] {
    --app-background: $(warning.app_background);
    --app-background-subtle: $(warning.app_background_subtle);
    --app-border: $(warning.app_border);
    
    --element-background: $(warning.element_background);
    --element-background-hover: $(warning.element_background_hover);
    --element-background-strong: $(warning.element_background_strong);

    --element-border-subtle: $(warning.element_border_subtle);
    --element-border-strong: $(warning.element_border_strong);

    --solid-background: $(warning.solid_background);
    --solid-background-hover: $(warning.solid_background_hover);

    --text-high-contrast: $(warning.text_high_contrast);
    --text-low-contrast: $(warning.text_low_contrast);
  }

  [data-variant=\"info\"] {
    --app-background: $(info.app_background);
    --app-background-subtle: $(info.app_background_subtle);
    --app-border: $(info.app_border);
    
    --element-background: $(info.element_background);
    --element-background-hover: $(info.element_background_hover);
    --element-background-strong: $(info.element_background_strong);

    --element-border-subtle: $(info.element_border_subtle);
    --element-border-strong: $(info.element_border_strong);

    --solid-background: $(info.solid_background);
    --solid-background-hover: $(info.solid_background_hover);

    --text-high-contrast: $(info.text_high_contrast);
    --text-low-contrast: $(info.text_low_contrast);
  }

  body {
    background: var(--app-background);
    color: var(--text-high-contrast);
    font-family: var(--font-base);
    font-size: var(--text-base-size);
    line-height: 1.4;
  }

  h1, h2, h3, h4, h5, h6 {
    font-family: var(--font-alt);
    line-height: 1.2;
  }

  h1 {
    font-size: var(--text-2xl);
  }

  h2 {
    font-size: var(--text-xl);
  }

  h3 {
    font-size: var(--text-lg);
  }

  h4 {
    font-size: var(--text-md);
  }

  pre, code, kbd, samp {
    font-family: var(--font-mono);
  }
  "
  |> string.append(listbox.styles)
  |> map.fold(theme_to_map(theme), _, string.replace)
  |> html.style([], _)
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn variant(variant: Variant) -> Attribute(a) {
  attribute(
    "data-variant",
    case variant {
      Primary -> "primary"
      Greyscale -> "greyscale"
      Error -> "error"
      Warning -> "warning"
      Success -> "success"
      Info -> "info"
    },
  )
}

// UTILS -----------------------------------------------------------------------

pub fn var(name: String) -> String {
  case string.starts_with(name, "--") {
    True -> "var(" <> name <> ")"
    False -> "var(--" <> name <> ")"
  }
}

fn theme_to_map(theme: Theme) -> Map(String, String) {
  map.from_list([
    #("$(base_text)", int.to_string(theme.base_text)),
    #("$(border_radius)", int.to_string(theme.border_radius)),
  ])
  |> map.merge(scale_to_map(theme.primary, "primary"))
  |> map.merge(scale_to_map(theme.greyscale, "greyscale"))
  |> map.merge(scale_to_map(theme.error, "error"))
  |> map.merge(scale_to_map(theme.success, "success"))
  |> map.merge(scale_to_map(theme.warning, "warning"))
  |> map.merge(scale_to_map(theme.info, "info"))
}

fn scale_to_map(scale: Scale, prefix: String) -> Map(String, String) {
  map.from_list([
    #(
      "$(" <> prefix <> ".app_background)",
      colour.to_css_rgba_string(scale.app_background),
    ),
    #(
      "$(" <> prefix <> ".app_background_subtle)",
      colour.to_css_rgba_string(scale.app_background_subtle),
    ),
    #(
      "$(" <> prefix <> ".app_border)",
      colour.to_css_rgba_string(scale.app_border),
    ),
    #(
      "$(" <> prefix <> ".element_background)",
      colour.to_css_rgba_string(scale.element_background),
    ),
    #(
      "$(" <> prefix <> ".element_background_hover)",
      colour.to_css_rgba_string(scale.element_background_hover),
    ),
    #(
      "$(" <> prefix <> ".element_background_strong)",
      colour.to_css_rgba_string(scale.element_background_strong),
    ),
    #(
      "$(" <> prefix <> ".element_border_subtle)",
      colour.to_css_rgba_string(scale.element_border_subtle),
    ),
    #(
      "$(" <> prefix <> ".element_border_strong)",
      colour.to_css_rgba_string(scale.element_border_strong),
    ),
    #(
      "$(" <> prefix <> ".solid_background)",
      colour.to_css_rgba_string(scale.solid_background),
    ),
    #(
      "$(" <> prefix <> ".solid_background_hover)",
      colour.to_css_rgba_string(scale.solid_background_hover),
    ),
    #(
      "$(" <> prefix <> ".text_high_contrast)",
      colour.to_css_rgba_string(scale.text_high_contrast),
    ),
    #(
      "$(" <> prefix <> ".text_low_contrast)",
      colour.to_css_rgba_string(scale.text_low_contrast),
    ),
  ])
}
