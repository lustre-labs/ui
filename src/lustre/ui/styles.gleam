// IMPORTS ---------------------------------------------------------------------

import gleam/map.{type Map}
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui.{type Theme}
import lustre/ui/colour.{type Scale} as _
import gleam_community/colour
import gleam/string

// ELEMENTS --------------------------------------------------------------------

/// Render a `<style />` element that sets up all the CSS variables derived from
/// a theme. You *need* to include this element in your app for any of the elements
/// to work and look correct.
/// 
pub fn theme(theme: Theme) -> Element(msg) {
  theme_to_map(theme)
  |> map.fold(theme_css, string.replace)
  |> html.style([], _)
}

/// Render a `<style />` element that sets up the styles for all the elements
/// provided by this library. If you prefer, this stylesheet is also provided
/// as a static CSS file in the `priv` directory of this package.
/// 
pub fn elements() -> Element(msg) {
  html.style([], element_css)
}

// UTILS -----------------------------------------------------------------------

fn theme_to_map(theme: Theme) -> Map(String, String) {
  map.new()
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

// CONSTANTS -------------------------------------------------------------------

const theme_css: String = "
:root {
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

  --text-xs: calc(var(--text-sm) / 1.25);
  --text-sm: calc(var(--text-md) / 1.25);
  --text-md: 14px;
  --text-lg: calc(var(--text-md) * 1.25);
  --text-xl: calc(var(--text-lg) * 1.25);
  --text-2xl: calc(var(--text-xl) * 1.25);
  --text-3xl: calc(var(--text-2xl) * 1.25);
  --text-4xl: calc(var(--text-3xl) * 1.25);
  --text-5xl: calc(var(--text-4xl) * 1.25);

  font-size: var(--text-md);

  --space-xs: calc(0.5 * 1rem);
  --space-sm: calc(0.75 * 1rem);
  --space-md: 1rem;
  --space-lg: calc(1.25 * 1rem);
  --space-xl: calc(2 * 1rem);
  --space-2xl: calc(3.25 * 1rem);
  --space-3xl: calc(5.25 * 1rem);
  --space-4xl: calc(8.5 * 1rem);
  --space-5xl: calc(13.75 * 1rem);

  --font-base: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, \"Noto Sans\", sans-serif,
    \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\", \"Noto Color Emoji\";
  --font-alt: ui-serif, Georgia, Cambria, \"Times New Roman\", Times, serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    \"Liberation Mono\", \"Courier New\", monospace;

  --border-radius: 4px;

  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 20px 25px -5px rgb(0 0 0 / 0.1),
    0 8px 10px -6px rgb(0 0 0 / 0.1);

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
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

  color: var(--text-high-contrast);
}
"

const element_css: String = "
*,:after,:before{border:0 solid;box-sizing:border-box}html{-webkit-text-size-adjust:100%;font-feature-settings:normal;font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,Noto Sans,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol,Noto Color Emoji;font-variation-settings:normal;line-height:1.5;-moz-tab-size:4;-o-tab-size:4;tab-size:4}body{line-height:inherit;margin:0}hr{border-top-width:1px;color:inherit;height:0}abbr:where([title]){-webkit-text-decoration:underline dotted;text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{color:inherit;text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,pre,samp{font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,Liberation Mono,Courier New,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}table{border-collapse:collapse;border-color:inherit;text-indent:0}button,input,optgroup,select,textarea{font-feature-settings:inherit;color:inherit;font-family:inherit;font-size:100%;font-variation-settings:inherit;font-weight:inherit;line-height:inherit;margin:0;padding:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button;background-color:transparent;background-image:none}:-moz-focusring{outline:auto}:-moz-ui-invalid{box-shadow:none}progress{vertical-align:baseline}::-webkit-inner-spin-button,::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}blockquote,dd,dl,figure,h1,h2,h3,h4,h5,h6,hr,p,pre{margin:0}fieldset{margin:0}fieldset,legend{padding:0}menu,ol,ul{list-style:none;margin:0;padding:0}dialog{padding:0}textarea{resize:vertical}input::-moz-placeholder,textarea::-moz-placeholder{color:#9ca3af;opacity:1}input::placeholder,textarea::placeholder{color:#9ca3af;opacity:1}[role=button],button{cursor:pointer}:disabled{cursor:default}audio,canvas,embed,iframe,img,object,svg,video{display:block;vertical-align:middle}img,video{height:auto;max-width:100%}[hidden]{display:none}.lustre-ui-aside{--align:start;--gap:var(--space-md);--dir:row;--wrap:wrap;--min:60%;align-items:var(--align);display:flex;flex-direction:var(--dir);flex-wrap:var(--wrap);gap:var(--gap)}.lustre-ui-aside.content-first{--dir:row;--wrap:wrap}.lustre-ui-aside.content-last{--dir:row-reverse;--wrap:wrap-reverse}.lustre-ui-aside.align-start{--align:start}.lustre-ui-aside.align-center,.lustre-ui-aside.align-centre{--align:center}.lustre-ui-aside.align-end{--align:end}.lustre-ui-aside.stretch{--align:stretch}.lustre-ui-aside.packed{--gap:0}.lustre-ui-aside.tight{--gap:var(--space-xs)}.lustre-ui-aside.relaxed{--gap:var(--space-md)}.lustre-ui-aside.loose{--gap:var(--space-lg)}.lustre-ui-aside>:first-child{flex-basis:0;flex-grow:999;min-inline-size:var(--min)}.lustre-ui-aside>:last-child{flex-grow:1;max-height:-moz-max-content;max-height:max-content}.lustre-ui-box{--gap:var(--space-sm);padding:var(--gap)}.lustre-ui-box.packed{--gap:0}.lustre-ui-box.tight{--gap:var(--space-xs)}.lustre-ui-box.relaxed{--gap:var(--space-md)}.lustre-ui-box.loose{--gap:var(--space-lg)}.lustre-ui-button{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast);background-color:var(--bg);border:1px solid var(--border,var(--bg),var(--element-border-subtle));border-radius:var(--border-radius);color:var(--text);padding:var(--space-xs) var(--space-sm)}.lustre-ui-button:focus-within,.lustre-ui-button:hover{background-color:var(--bg-hover)}.lustre-ui-button:focus-within:active,.lustre-ui-button:hover:active{background-color:var(--bg-active);border-color:var(--border-active)}.lustre-ui-button.solid{--bg-active:var(--solid-background-hover);--bg-hover:var(--solid-background-hover);--bg:var(--solid-background);--border-active:var(--solid-background-hover);--border:var(--solid-background);--text:#fff}.lustre-ui-button.solid:focus-within:active,.lustre-ui-button.solid:hover:active{--bg-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000);--border-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000)}.lustre-ui-button.soft{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast)}.lustre-ui-button.outline{--bg:unset;--border:var(--element-border-subtle)}.lustre-ui-cluster{--gap:var(--space-md);--dir:flex-start;align-items:center;display:flex;flex-wrap:wrap;gap:var(--gap);justify-content:var(--dir)}.lustre-ui-cluster.packed{--gap:0}.lustre-ui-cluster.tight{--gap:var(--space-xs)}.lustre-ui-cluster.relaxed{--gap:var(--space-md)}.lustre-ui-cluster.loose{--gap:var(--space-lg)}.lustre-ui-cluster.from-start{--dir:flex-start}.lustre-ui-cluster.from-end{--dir:flex-end}.lustre-ui-icon{--size:1em;height:var(--size);width:var(--size)}.lustre-ui-sequence{--gap:var(--space-md);--break:30rem;display:flex;flex-wrap:wrap;gap:var(--gap)}.lustre-ui-sequence.packed{--gap:0}.lustre-ui-sequence.tight{--gap:var(--space-xs)}.lustre-ui-sequence.relaxed{--gap:var(--space-md)}.lustre-ui-sequence.loose{--gap:var(--space-lg)}.lustre-ui-sequence[data-split-at=\"10\"]>:nth-last-child(n+10),.lustre-ui-sequence[data-split-at=\"10\"]>:nth-last-child(n+10)~*,.lustre-ui-sequence[data-split-at=\"3\"]>:nth-last-child(n+3),.lustre-ui-sequence[data-split-at=\"3\"]>:nth-last-child(n+3)~*,.lustre-ui-sequence[data-split-at=\"4\"]>:nth-last-child(n+4),.lustre-ui-sequence[data-split-at=\"4\"]>:nth-last-child(n+4)~*,.lustre-ui-sequence[data-split-at=\"5\"]>:nth-last-child(n+5),.lustre-ui-sequence[data-split-at=\"5\"]>:nth-last-child(n+5)~*,.lustre-ui-sequence[data-split-at=\"6\"]>:nth-last-child(n+6),.lustre-ui-sequence[data-split-at=\"6\"]>:nth-last-child(n+6)~*,.lustre-ui-sequence[data-split-at=\"7\"]>:nth-last-child(n+7),.lustre-ui-sequence[data-split-at=\"7\"]>:nth-last-child(n+7)~*,.lustre-ui-sequence[data-split-at=\"8\"]>:nth-last-child(n+8),.lustre-ui-sequence[data-split-at=\"8\"]>:nth-last-child(n+8)~*,.lustre-ui-sequence[data-split-at=\"9\"]>:nth-last-child(n+9),.lustre-ui-sequence[data-split-at=\"9\"]>:nth-last-child(n+9)~*{flex-basis:100%}.lustre-ui-sequence>*{flex-basis:calc((var(--break) - 100%)*999);flex-grow:1}.lustre-ui-stack{--gap:var(--space-md);display:flex;flex-direction:column;gap:var(--gap);justify-content:flex-start}.lustre-ui-stack.packed{--gap:0}.lustre-ui-stack.tight{--gap:var(--space-xs)}.lustre-ui-stack.relaxed{--gap:var(--space-md)}.lustre-ui-stack.loose{--gap:var(--space-lg)}
"
