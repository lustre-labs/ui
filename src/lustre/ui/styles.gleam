// IMPORTS ---------------------------------------------------------------------

import gleam/dict.{type Dict}
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
  theme_to_dict(theme)
  |> dict.fold(theme_css, string.replace)
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

fn theme_to_dict(theme: Theme) -> Dict(String, String) {
  dict.new()
  |> dict.merge(scale_to_dict(theme.primary, "primary"))
  |> dict.merge(scale_to_dict(theme.greyscale, "greyscale"))
  |> dict.merge(scale_to_dict(theme.error, "error"))
  |> dict.merge(scale_to_dict(theme.success, "success"))
  |> dict.merge(scale_to_dict(theme.warning, "warning"))
  |> dict.merge(scale_to_dict(theme.info, "info"))
}

fn scale_to_dict(scale: Scale, prefix: String) -> Dict(String, String) {
  dict.from_list([
    #(
      "$("
      <> prefix
      <> ".app_background)",
      colour.to_css_rgba_string(scale.app_background),
    ),
    #(
      "$("
      <> prefix
      <> ".app_background_subtle)",
      colour.to_css_rgba_string(scale.app_background_subtle),
    ),
    #(
      "$("
      <> prefix
      <> ".app_border)",
      colour.to_css_rgba_string(scale.app_border),
    ),
    #(
      "$("
      <> prefix
      <> ".element_background)",
      colour.to_css_rgba_string(scale.element_background),
    ),
    #(
      "$("
      <> prefix
      <> ".element_background_hover)",
      colour.to_css_rgba_string(scale.element_background_hover),
    ),
    #(
      "$("
      <> prefix
      <> ".element_background_strong)",
      colour.to_css_rgba_string(scale.element_background_strong),
    ),
    #(
      "$("
      <> prefix
      <> ".element_border_subtle)",
      colour.to_css_rgba_string(scale.element_border_subtle),
    ),
    #(
      "$("
      <> prefix
      <> ".element_border_strong)",
      colour.to_css_rgba_string(scale.element_border_strong),
    ),
    #(
      "$("
      <> prefix
      <> ".solid_background)",
      colour.to_css_rgba_string(scale.solid_background),
    ),
    #(
      "$("
      <> prefix
      <> ".solid_background_hover)",
      colour.to_css_rgba_string(scale.solid_background_hover),
    ),
    #(
      "$("
      <> prefix
      <> ".text_high_contrast)",
      colour.to_css_rgba_string(scale.text_high_contrast),
    ),
    #(
      "$("
      <> prefix
      <> ".text_low_contrast)",
      colour.to_css_rgba_string(scale.text_low_contrast),
    ),
  ])
}

// CONSTANTS -------------------------------------------------------------------

const theme_css: String = "
:root {
  --primary-app-background: $(primary.app_background);
  --primary-app-background-subtle: $(primary.app_background_subtle);
  --primary-app-border: $(primary.app_border);
  --primary-element-background: $(primary.element_background);
  --primary-element-background-hover: $(primary.element_background_hover);
  --primary-element-background-strong: $(primary.element_background_strong);
  --primary-element-border-subtle: $(primary.element_border_subtle);
  --primary-element-border-strong: $(primary.element_border_strong);
  --primary-solid-background: $(primary.solid_background);
  --primary-solid-background-hover: $(primary.solid_background_hover);
  --primary-text-high-contrast: $(primary.text_high_contrast);
  --primary-text-low-contrast: $(primary.text_low_contrast);

  --greyscale-app-background: $(greyscale.app_background);
  --greyscale-app-background-subtle: $(greyscale.app_background_subtle);
  --greyscale-app-border: $(greyscale.app_border);
  --greyscale-element-background: $(greyscale.element_background);
  --greyscale-element-background-hover: $(greyscale.element_background_hover);
  --greyscale-element-background-strong: $(greyscale.element_background_strong);
  --greyscale-element-border-subtle: $(greyscale.element_border_subtle);
  --greyscale-element-border-strong: $(greyscale.element_border_strong);
  --greyscale-solid-background: $(greyscale.solid_background);
  --greyscale-solid-background-hover: $(greyscale.solid_background_hover);
  --greyscale-text-high-contrast: $(greyscale.text_high_contrast);
  --greyscale-text-low-contrast: $(greyscale.text_low_contrast);

  --error-app-background: $(error.app_background);
  --error-app-background-subtle: $(error.app_background_subtle);
  --error-app-border: $(error.app_border);
  --error-element-background: $(error.element_background);
  --error-element-background-hover: $(error.element_background_hover);
  --error-element-background-strong: $(error.element_background_strong);
  --error-element-border-subtle: $(error.element_border_subtle);
  --error-element-border-strong: $(error.element_border_strong);
  --error-solid-background: $(error.solid_background);
  --error-solid-background-hover: $(error.solid_background_hover);
  --error-text-high-contrast: $(error.text_high_contrast);
  --error-text-low-contrast: $(error.text_low_contrast);

  --success-app-background: $(success.app_background);
  --success-app-background-subtle: $(success.app_background_subtle);
  --success-app-border: $(success.app_border);
  --success-element-background: $(success.element_background);
  --success-element-background-hover: $(success.element_background_hover);
  --success-element-background-strong: $(success.element_background_strong);
  --success-element-border-subtle: $(success.element_border_subtle);
  --success-element-border-strong: $(success.element_border_strong);
  --success-solid-background: $(success.solid_background);
  --success-solid-background-hover: $(success.solid_background_hover);
  --success-text-high-contrast: $(success.text_high_contrast);
  --success-text-low-contrast: $(success.text_low_contrast);

  --warning-app-background: $(warning.app_background);
  --warning-app-background-subtle: $(warning.app_background_subtle);
  --warning-app-border: $(warning.app_border);
  --warning-element-background: $(warning.element_background);
  --warning-element-background-hover: $(warning.element_background_hover);
  --warning-element-background-strong: $(warning.element_background_strong);
  --warning-element-border-subtle: $(warning.element_border_subtle);
  --warning-element-border-strong: $(warning.element_border_strong);
  --warning-solid-background: $(warning.solid_background);
  --warning-solid-background-hover: $(warning.solid_background_hover);
  --warning-text-high-contrast: $(warning.text_high_contrast);
  --warning-text-low-contrast: $(warning.text_low_contrast);

  --info-app-background: $(info.app_background);
  --info-app-background-subtle: $(info.app_background_subtle);
  --info-app-border: $(info.app_border);
  --info-element-background: $(info.element_background);
  --info-element-background-hover: $(info.element_background_hover);
  --info-element-background-strong: $(info.element_background_strong);
  --info-element-border-subtle: $(info.element_border_subtle);
  --info-element-border-strong: $(info.element_border_strong);
  --info-solid-background: $(info.solid_background);
  --info-solid-background-hover: $(info.solid_background_hover);
  --info-text-high-contrast: $(info.text_high_contrast);
  --info-text-low-contrast: $(info.text_low_contrast);
}
"

const element_css: String = "
*,:after,:before{border:0 solid;box-sizing:border-box}html{-webkit-text-size-adjust:100%;font-feature-settings:normal;font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica Neue,Arial,Noto Sans,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol,Noto Color Emoji;font-variation-settings:normal;line-height:1.5;-moz-tab-size:4;-o-tab-size:4;tab-size:4}body{line-height:inherit;margin:0}hr{border-top-width:1px;color:inherit;height:0}abbr:where([title]){-webkit-text-decoration:underline dotted;text-decoration:underline dotted}h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}a{color:inherit;text-decoration:inherit}b,strong{font-weight:bolder}code,kbd,pre,samp{font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,Liberation Mono,Courier New,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}table{border-collapse:collapse;border-color:inherit;text-indent:0}button,input,optgroup,select,textarea{font-feature-settings:inherit;color:inherit;font-family:inherit;font-size:100%;font-variation-settings:inherit;font-weight:inherit;line-height:inherit;margin:0;padding:0}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button;background-color:transparent;background-image:none}:-moz-focusring{outline:auto}:-moz-ui-invalid{box-shadow:none}progress{vertical-align:baseline}::-webkit-inner-spin-button,::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}summary{display:list-item}blockquote,dd,dl,figure,h1,h2,h3,h4,h5,h6,hr,p,pre{margin:0}fieldset{margin:0}fieldset,legend{padding:0}menu,ol,ul{list-style:none;margin:0;padding:0}dialog{padding:0}textarea{resize:vertical}input::-moz-placeholder,textarea::-moz-placeholder{color:#9ca3af;opacity:1}input::placeholder,textarea::placeholder{color:#9ca3af;opacity:1}[role=button],button{cursor:pointer}:disabled{cursor:default}audio,canvas,embed,iframe,img,object,svg,video{display:block;vertical-align:middle}img,video{height:auto;max-width:100%}[hidden]{display:none}:root{--primary-app-background:#fdfdff;--primary-app-background-subtle:#fafaff;--primary-app-border:#d0d0fa;--primary-element-background:#f3f3ff;--primary-element-background-hover:#ebebfe;--primary-element-background-strong:#e0e0fd;--primary-element-border-subtle:#babbf5;--primary-element-border-strong:#9b9ef0;--primary-solid-background:#5b5bd6;--primary-solid-background-hover:#5353ce;--primary-text-high-contrast:#272962;--primary-text-low-contrast:#4747c2;--greyscale-app-background:#fcfcfd;--greyscale-app-background-subtle:#f9f9fb;--greyscale-app-border:#dddde3;--greyscale-element-background:#f2f2f5;--greyscale-element-background-hover:#ebebef;--greyscale-element-background-strong:#e4e4e9;--greyscale-element-border-subtle:#d3d4db;--greyscale-element-border-strong:#b9bbc6;--greyscale-solid-background:#8b8d98;--greyscale-solid-background-hover:#7e808a;--greyscale-text-high-contrast:#1c2024;--greyscale-text-low-contrast:#60646c;--error-app-background:#fffcfc;--error-app-background-subtle:#fff7f7;--error-app-border:#f9c6c6;--error-element-background:#ffefef;--error-element-background-hover:#ffe5e5;--error-element-background-strong:#fdd8d8;--error-element-border-subtle:#f3aeaf;--error-element-border-strong:#eb9091;--error-solid-background:#e5484d;--error-solid-background-hover:#d93d42;--error-text-high-contrast:#641723;--error-text-low-contrast:#c62a2f;--success-app-background:#fbfefc;--success-app-background-subtle:#f2fcf5;--success-app-border:#b4dfc4;--success-element-background:#e9f9ee;--success-element-background-hover:#ddf3e4;--success-element-background-strong:#ccebd7;--success-element-border-subtle:#92ceac;--success-element-border-strong:#5bb98c;--success-solid-background:#30a46c;--success-solid-background-hover:#299764;--success-text-high-contrast:#193b2d;--success-text-low-contrast:#18794e;--warning-app-background:#fdfdf9;--warning-app-background-subtle:#fffbe0;--warning-app-border:#ecdd85;--warning-element-background:#fff8c6;--warning-element-background-hover:#fcf3af;--warning-element-background-strong:#f7ea9b;--warning-element-border-subtle:#dac56e;--warning-element-border-strong:#c9aa45;--warning-solid-background:#fbe32d;--warning-solid-background-hover:#f9da10;--warning-text-high-contrast:#473b1f;--warning-text-low-contrast:#775f28;--info-app-background:#fbfdff;--info-app-background-subtle:#f5faff;--info-app-border:#b7d9f8;--info-element-background:#edf6ff;--info-element-background-hover:#e1f0ff;--info-element-background-strong:#cee7fe;--info-element-border-subtle:#96c7f2;--info-element-border-strong:#5eb0ef;--info-solid-background:#0091ff;--info-solid-background-hover:#0880ea;--info-text-high-contrast:#113264;--info-text-low-contrast:#0b68cb;--app-background:var(--primary-app-background);--app-background-subtle:var(--primary-app-background-subtle);--app-border:var(--primary-app-border);--element-background:var(--primary-element-background);--element-background-hover:var(--primary-element-background-hover);--element-background-strong:var(--primary-element-background-strong);--element-border-subtle:var(--primary-element-border-subtle);--element-border-strong:var(--primary-element-border-strong);--solid-background:var(--primary-solid-background);--solid-background-hover:var(--primary-solid-background-hover);--text-high-contrast:var(--primary-text-high-contrast);--text-low-contrast:var(--primary-text-low-contrast);--text-xs:calc(var(--text-sm)/1.25);--text-sm:calc(var(--text-md)/1.25);--text-md:14px;--text-lg:calc(var(--text-md)*1.25);--text-xl:calc(var(--text-lg)*1.25);--text-2xl:calc(var(--text-xl)*1.25);--text-3xl:calc(var(--text-2xl)*1.25);--text-4xl:calc(var(--text-3xl)*1.25);--text-5xl:calc(var(--text-4xl)*1.25);--space-2xs:0.25rem;--space-xs:0.5rem;--space-sm:0.75rem;--space-md:1rem;--space-lg:1.25rem;--space-xl:2rem;--space-2xl:3.25rem;--space-3xl:5.25rem;--space-4xl:8.5rem;--space-5xl:13.75rem;--font-base:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,\"Helvetica Neue\",Arial,\"Noto Sans\",sans-serif,\"Apple Color Emoji\",\"Segoe UI Emoji\",\"Segoe UI Symbol\",\"Noto Color Emoji\";--font-alt:ui-serif,Georgia,Cambria,\"Times New Roman\",Times,serif;--font-mono:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,\"Liberation Mono\",\"Courier New\",monospace;--border-radius:4px;--shadow-sm:0 1px 2px 0 rgba(0,0,0,.05);--shadow-md:0 4px 6px -1px rgba(0,0,0,.1),0 2px 4px -2px rgba(0,0,0,.1);--shadow-lg:0 20px 25px -5px rgba(0,0,0,.1),0 8px 10px -6px rgba(0,0,0,.1)}[data-variant=primary]{--app-background:var(--primary-app-background);--app-background-subtle:var(--primary-app-background-subtle);--app-border:var(--primary-app-border);--element-background:var(--primary-element-background);--element-background-hover:var(--primary-element-background-hover);--element-background-strong:var(--primary-element-background-strong);--element-border-subtle:var(--primary-element-border-subtle);--element-border-strong:var(--primary-element-border-strong);--solid-background:var(--primary-solid-background);--solid-background-hover:var(--primary-solid-background-hover);--text-high-contrast:var(--primary-text-high-contrast);--text-low-contrast:var(--primary-text-low-contrast);color:var(--text-high-contrast)}[data-variant=greyscale]{--app-background:var(--greyscale-app-background);--app-background-subtle:var(--greyscale-app-background-subtle);--app-border:var(--greyscale-app-border);--element-background:var(--greyscale-element-background);--element-background-hover:var(--greyscale-element-background-hover);--element-background-strong:var(--greyscale-element-background-strong);--element-border-subtle:var(--greyscale-element-border-subtle);--element-border-strong:var(--greyscale-element-border-strong);--solid-background:var(--greyscale-solid-background);--solid-background-hover:var(--greyscale-solid-background-hover);--text-high-contrast:var(--greyscale-text-high-contrast);--text-low-contrast:var(--greyscale-text-low-contrast);color:var(--text-high-contrast)}[data-variant=error]{--app-background:var(--error-app-background);--app-background-subtle:var(--error-app-background-subtle);--app-border:var(--error-app-border);--element-background:var(--error-element-background);--element-background-hover:var(--error-element-background-hover);--element-background-strong:var(--error-element-background-strong);--element-border-subtle:var(--error-element-border-subtle);--element-border-strong:var(--error-element-border-strong);--solid-background:var(--error-solid-background);--solid-background-hover:var(--error-solid-background-hover);--text-high-contrast:var(--error-text-high-contrast);--text-low-contrast:var(--error-text-low-contrast);color:var(--text-high-contrast)}[data-variant=success]{--app-background:var(--success-app-background);--app-background-subtle:var(--success-app-background-subtle);--app-border:var(--success-app-border);--element-background:var(--success-element-background);--element-background-hover:var(--success-element-background-hover);--element-background-strong:var(--success-element-background-strong);--element-border-subtle:var(--success-element-border-subtle);--element-border-strong:var(--success-element-border-strong);--solid-background:var(--success-solid-background);--solid-background-hover:var(--success-solid-background-hover);--text-high-contrast:var(--success-text-high-contrast);--text-low-contrast:var(--success-text-low-contrast);color:var(--text-high-contrast)}[data-variant=warning]{--app-background:var(--warning-app-background);--app-background-subtle:var(--warning-app-background-subtle);--app-border:var(--warning-app-border);--element-background:var(--warning-element-background);--element-background-hover:var(--warning-element-background-hover);--element-background-strong:var(--warning-element-background-strong);--element-border-subtle:var(--warning-element-border-subtle);--element-border-strong:var(--warning-element-border-strong);--solid-background:var(--warning-solid-background);--solid-background-hover:var(--warning-solid-background-hover);--text-high-contrast:var(--warning-text-high-contrast);--text-low-contrast:var(--warning-text-low-contrast);color:var(--text-high-contrast)}[data-variant=info]{--app-background:var(--info-app-background);--app-background-subtle:var(--info-app-background-subtle);--app-border:var(--info-app-border);--element-background:var(--info-element-background);--element-background-hover:var(--info-element-background-hover);--element-background-strong:var(--info-element-background-strong);--element-border-subtle:var(--info-element-border-subtle);--element-border-strong:var(--info-element-border-strong);--solid-background:var(--info-solid-background);--solid-background-hover:var(--info-solid-background-hover);--text-high-contrast:var(--info-text-high-contrast);--text-low-contrast:var(--info-text-low-contrast);color:var(--text-high-contrast)}.lustre-ui-alert{--bg:var(--element-background);--border:var(--element-border-subtle);--text:var(--text-high-contrast);background-color:var(--bg);border:1px solid var(--border);border-radius:var(--border-radius);box-shadow:var(--shadow-sm);padding:var(--space-sm)}.lustre-ui-alert.clear{--bg:unsert}.lustre-ui-aside{--align:start;--gap:var(--space-md);--dir:row;--wrap:wrap;--min:60%;align-items:var(--align);display:flex;flex-direction:var(--dir);flex-wrap:var(--wrap);gap:var(--gap)}.lustre-ui-aside.content-first{--dir:row;--wrap:wrap}.lustre-ui-aside.content-last{--dir:row-reverse;--wrap:wrap-reverse}.lustre-ui-aside.align-start{--align:start}.lustre-ui-aside.align-center,.lustre-ui-aside.align-centre{--align:center}.lustre-ui-aside.align-end{--align:end}.lustre-ui-aside.stretch{--align:stretch}.lustre-ui-aside.packed{--gap:0}.lustre-ui-aside.tight{--gap:var(--space-xs)}.lustre-ui-aside.relaxed{--gap:var(--space-md)}.lustre-ui-aside.loose{--gap:var(--space-lg)}.lustre-ui-aside>:first-child{flex-basis:0;flex-grow:999;min-inline-size:var(--min)}.lustre-ui-aside>:last-child{flex-grow:1;max-height:-moz-max-content;max-height:max-content}.lustre-ui-box{--gap:var(--space-sm);padding:var(--gap)}.lustre-ui-box.packed{--gap:0}.lustre-ui-box.tight{--gap:var(--space-xs)}.lustre-ui-box.relaxed{--gap:var(--space-md)}.lustre-ui-box.loose{--gap:var(--space-lg)}.lustre-ui-breadcrumbs{--gap:var(--space-sm);--align:center;align-items:var(--align);display:flex;flex-wrap:nowrap;gap:var(--gap);justify-content:start;overflow-x:auto}.lustre-ui-breadcrumbs.tight{--gap:var(--space-xs)}.lustre-ui-breadcrumbs.relaxed{--gap:var(--space-sm)}.lustre-ui-breadcrumbs.loose{--gap:var(--space-md)}.lustre-ui-breadcrumbs.align-start{--align:start}.lustre-ui-breadcrumbs.align-center,.lustre-ui-breadcrumbs.align-centre{--align:center}.lustre-ui-breadcrumbs.align-end{--align:end}.lustre-ui-breadcrumbs>*{flex:0 0 auto}.lustre-ui-breadcrumbs:not(:has(.active))>:last-child,.lustre-ui-breadcrumbs>.active{color:var(--text-low-contrast)}.lustre-ui-button{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast);--padding-y:var(--space-xs);--padding-x:var(--space-sm);background-color:var(--bg);border:1px solid var(--border,var(--bg),var(--element-border-subtle));border-radius:var(--border-radius);color:var(--text);padding:var(--padding-y) var(--padding-x)}.lustre-ui-button:focus-within,.lustre-ui-button:hover{background-color:var(--bg-hover)}.lustre-ui-button:focus-within:active,.lustre-ui-button:hover:active{background-color:var(--bg-active);border-color:var(--border-active)}.lustre-ui-button.small{--padding-y:var(--space-2xs);--padding-x:var(--space-xs)}.lustre-ui-button.solid{--bg-active:var(--solid-background-hover);--bg-hover:var(--solid-background-hover);--bg:var(--solid-background);--border-active:var(--solid-background-hover);--border:var(--solid-background);--text:#fff}.lustre-ui-button.solid:focus-within:active,.lustre-ui-button.solid:hover:active{--bg-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000);--border-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000)}.lustre-ui-button.soft{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast)}.lustre-ui-button.outline{--bg:unset;--border:var(--element-border-subtle)}.lustre-ui-button.clear{--bg:unset;--border:unset}.lustre-ui-centre{--display:flex;align-items:center;display:var(--display);justify-content:center}.lustre-ui-centre.inline{--display:inline-flex}.lustre-ui-cluster{--gap:var(--space-md);--dir:flex-start;--align:center;align-items:var(--align);display:flex;flex-wrap:wrap;gap:var(--gap);justify-content:var(--dir)}.lustre-ui-cluster.packed{--gap:0}.lustre-ui-cluster.tight{--gap:var(--space-xs)}.lustre-ui-cluster.relaxed{--gap:var(--space-md)}.lustre-ui-cluster.loose{--gap:var(--space-lg)}.lustre-ui-cluster.from-start{--dir:flex-start}.lustre-ui-cluster.from-end{--dir:flex-end}.lustre-ui-cluster.align-start{--align:start}.lustre-ui-cluster.align-center,.lustre-ui-cluster.align-centre{--align:center}.lustre-ui-cluster.align-end{--align:end}.lustre-ui-cluster.stretch{--align:stretch}.lustre-ui-field{--label:var(--text-high-contrast);--label-align:start;--message:var(--text-low-contrast);--message-align:end;--text-size:var(--text-md)}.lustre-ui-field.small{--text-size:var(--text-sm)}.lustre-ui-field.label-start{--label-align:start}.lustre-ui-field.label-center,.lustre-ui-field.label-centre{--label-align:center}.lustre-ui-field.label-end{--label-align:end}.lustre-ui-field.message-start{--message-align:start}.lustre-ui-field.message-center,.lustre-ui-field.message-centre{--message-align:center}.lustre-ui-field.message-end{--message-align:end}.lustre-ui-field:has(input:disabled)>:is(.label,.message){opacity:.5}.lustre-ui-field>:not(input){color:var(--label);font-size:var(--text-size)}.lustre-ui-field>.label{display:inline-flex;justify-content:var(--label-align)}.lustre-ui-field>.message{color:var(--message);display:inline-flex;justify-content:var(--message-align)}.lustre-ui-group{align-items:stretch;display:inline-flex}.lustre-ui-group>:first-child{border-radius:var(--border-radius) 0 0 var(--border-radius)!important}.lustre-ui-group>:not(:first-child):not(:last-child){border-radius:0!important}.lustre-ui-group>:last-child{border-radius:0 var(--border-radius) var(--border-radius) 0!important}.lustre-ui-icon{--size:1em;display:inline;height:var(--size);width:var(--size)}.lustre-ui-icon.xs{--size:var(--text-xs)}.lustre-ui-icon.sm{--size:var(--text-sm)}.lustre-ui-icon.md{--size:var(--text-md)}.lustre-ui-icon.lg{--size:var(--text-lg)}.lustre-ui-icon.xl{--size:var(--text-xl)}.lustre-ui-input{--border-active:var(--element-border-strong);--border:var(--element-border-subtle);--outline:var(--element-border-subtle);--text:var(--text-high-contrast);--text-placeholder:var(--text-low-contrast);--padding-y:var(--space-xs);--padding-x:var(--space-sm);border:1px solid var(--border,var(--bg),var(--element-border-subtle));border-radius:var(--border-radius);color:var(--text);padding:var(--padding-y) var(--padding-x)}.lustre-ui-input:hover{border-color:var(--border-active)}.lustre-ui-input:focus-within{border-color:var(--border-active);outline:1px solid var(--outline);outline-offset:2px}.lustre-ui-input::-moz-placeholder{color:var(--text-placeholder)}.lustre-ui-input::placeholder{color:var(--text-placeholder)}.lustre-ui-input:disabled{opacity:.5}.lustre-ui-input.clear{--border:unset}.lustre-ui-sequence{--gap:var(--space-md);--break:30rem;display:flex;flex-wrap:wrap;gap:var(--gap)}.lustre-ui-sequence.packed{--gap:0}.lustre-ui-sequence.tight{--gap:var(--space-xs)}.lustre-ui-sequence.relaxed{--gap:var(--space-md)}.lustre-ui-sequence.loose{--gap:var(--space-lg)}.lustre-ui-sequence[data-split-at=\"10\"]>:nth-last-child(n+10),.lustre-ui-sequence[data-split-at=\"10\"]>:nth-last-child(n+10)~*,.lustre-ui-sequence[data-split-at=\"3\"]>:nth-last-child(n+3),.lustre-ui-sequence[data-split-at=\"3\"]>:nth-last-child(n+3)~*,.lustre-ui-sequence[data-split-at=\"4\"]>:nth-last-child(n+4),.lustre-ui-sequence[data-split-at=\"4\"]>:nth-last-child(n+4)~*,.lustre-ui-sequence[data-split-at=\"5\"]>:nth-last-child(n+5),.lustre-ui-sequence[data-split-at=\"5\"]>:nth-last-child(n+5)~*,.lustre-ui-sequence[data-split-at=\"6\"]>:nth-last-child(n+6),.lustre-ui-sequence[data-split-at=\"6\"]>:nth-last-child(n+6)~*,.lustre-ui-sequence[data-split-at=\"7\"]>:nth-last-child(n+7),.lustre-ui-sequence[data-split-at=\"7\"]>:nth-last-child(n+7)~*,.lustre-ui-sequence[data-split-at=\"8\"]>:nth-last-child(n+8),.lustre-ui-sequence[data-split-at=\"8\"]>:nth-last-child(n+8)~*,.lustre-ui-sequence[data-split-at=\"9\"]>:nth-last-child(n+9),.lustre-ui-sequence[data-split-at=\"9\"]>:nth-last-child(n+9)~*{flex-basis:100%}.lustre-ui-sequence>*{flex-basis:calc((var(--break) - 100%)*999);flex-grow:1}.lustre-ui-stack{--gap:var(--space-md);display:flex;flex-direction:column;gap:var(--gap);justify-content:flex-start}.lustre-ui-stack.packed{--gap:0}.lustre-ui-stack.tight{--gap:var(--space-xs)}.lustre-ui-stack.relaxed{--gap:var(--space-md)}.lustre-ui-stack.loose{--gap:var(--space-lg)}.lustre-ui-tag{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast);background-color:var(--bg);border:1px solid var(--border,var(--bg),var(--element-border-subtle));border-radius:var(--border-radius);color:var(--text);font-size:var(--text-sm);padding:0 var(--space-xs)}.lustre-ui-tag:is(button,a,[tabindex]){cursor:pointer;-webkit-user-select:none;-moz-user-select:none;user-select:none}.lustre-ui-tag:is(button,a,[tabindex]):focus-within,.lustre-ui-tag:is(button,a,[tabindex]):hover{background-color:var(--bg-hover)}.lustre-ui-tag:is(button,a,[tabindex]):focus-within:active,.lustre-ui-tag:is(button,a,[tabindex]):hover:active{background-color:var(--bg-active);border-color:var(--border-active)}.lustre-ui-tag.solid{--bg-active:var(--solid-background-hover);--bg-hover:var(--solid-background-hover);--bg:var(--solid-background);--border-active:var(--solid-background-hover);--border:var(--solid-background);--text:#fff}.lustre-ui-tag.solid:is(button,a,[tabindex]):focus-within:active,.lustre-ui-tag.solid:is(button,a,[tabindex]):hover:active{--bg-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000);--border-active:color-mix(in srgb,var(--solid-background-hover) 90%,#000)}.lustre-ui-tag.soft{--bg-active:var(--element-background-strong);--bg-hover:var(--element-background-hover);--bg:var(--element-background);--border-active:var(--bg-active);--border:var(--bg);--text:var(--text-high-contrast)}.lustre-ui-tag.outline{--bg:unset;--border:var(--element-border-subtle)}
"
