// IMPORTS ---------------------------------------------------------------------

import gleam_community/colour as gleam_community_colour
import gleam/map.{Map}
import gleam/string
import gleam/int
import lustre/attribute.{Attribute, attribute}
import lustre/element.{Element}
import lustre/element/html
import lustre/ui/colour.{Scale}

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

pub const text_md: String = "--text-md"

pub const text_lg: String = "--text-lg"

pub const text_xl: String = "--text-xl"

pub const text_2xl: String = "--text-2xl"

pub const text_3xl: String = "--text-3xl"

pub const text_4xl: String = "--text-4xl"

pub const space_xs: String = "--space-xs"

pub const space_sm: String = "--space-sm"

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

/// Lustre_ui's CSS reset is based on Tailwind's "preflight" stylesheet, which
/// in turn is based on the CSS Remedy project.
/// 
pub fn reset() -> Element(a) {
  // 🚨 DO NOT MODIFY THIS COMMENT OR THE FOLLOWING STYLES 🚨
  //
  // The `@embed` comment below is used by the build script in `test/build.gleam`
  // to inject the appropriate CSS into our gleam source. Make sure you run that
  // build script before publishing a new version of this package.
  //
  // @embed reset.css
  "
/*  1. Prevent padding and border from affecting element width. (https://github.com/mozdevs/cssremedy/issues/4) */
*,
::before,
::after {
  /* 1 */
  box-sizing: border-box;
}

/*  1. Use a consistent sensible line-height in all browsers.
    2. Prevent adjustments of font size after orientation changes in iOS.
    3. Use a more readable tab size.
    4. Choose a sensible default font family. */
html {
  /* 1 */
  line-height: 1.5;

  /* 2 */
  -webkit-text-size-adjust: 100%;

  /* 3 */
  -moz-tab-size: 4;
  tab-size: 4;

  /* 4 */
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif,
    'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
}

/*  1. Remove the margin in all browsers.
    2. Inherit line-height from `html` so users can set them as a class directly on the `html` element. */
body {
  /* 1 */
  margin: 0;

  /* 2 */
  line-height: inherit;
}

/*  1. Add the correct height in Firefox.
    2. Correct the inheritance of border color in Firefox. (https://bugzilla.mozilla.org/show_bug.cgi?id=190655)
    3. Ensure horizontal rules are visible by default. */
hr {
  /* 1 */
  height: 0;

  /* 2 */
  color: inherit;

  /* 3 */
  border-top-width: 1px;
}

/*  Add the correct text decoration in Chrome, Edge, and Safari. */
abbr:where([title]) {
  text-decoration: underline dotted;
}

/*  Add the correct font weight in Edge and Safari. */
b,
strong {
  font-weight: bolder;
}

/*  1. Choose a sensible monospaced font family.
    2. Correct the odd `em` font sizing in all browsers. */
code,
kbd,
samp,
pre {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    'Liberation Mono', 'Courier New', monospace; /* 1 */
  font-size: 1em; /* 2 */
}

/*  Add the correct font size in all browsers. */
small {
  font-size: 80%;
}

/*  Prevent `sub` and `sup` elements from affecting the line height in all browsers. */
sub,
sup {
  font-size: 75%;
  line-height: 0;
  position: relative;
  vertical-align: baseline;
}

sub {
  bottom: -0.25em;
}

sup {
  top: -0.5em;
}

/*  1. Remove text indentation from table contents in Chrome and Safari. (https://bugs.chromium.org/p/chromium/issues/detail?id=999088, https://bugs.webkit.org/show_bug.cgi?id=201297)
    2. Correct table border color inheritance in all Chrome and Safari. (https://bugs.chromium.org/p/chromium/issues/detail?id=935729, https://bugs.webkit.org/show_bug.cgi?id=195016)
      .Remove gaps between table borders by default.*/
table {
  text-indent: 0; /* 1 */
  border-color: inherit; /* 2 */
  border-collapse: collapse; /* 3 */
}

/*  1. Change the font styles in all browsers.
    2. Remove the margin in Firefox and Safari.
    3. Remove default padding in all browsers. */
button,
input,
optgroup,
select,
textarea {
  font-family: inherit; /* 1 */
  font-feature-settings: inherit; /* 1 */
  font-variation-settings: inherit; /* 1 */
  font-size: 100%; /* 1 */
  font-weight: inherit; /* 1 */
  line-height: inherit; /* 1 */
  color: inherit; /* 1 */
  margin: 0; /* 2 */
  padding: 0; /* 3 */
  border: none;
}

/*  Remove the inheritance of text transform in Edge and Firefox. */
button,
select {
  text-transform: none;
}

/*  1. Correct the inability to style clickable types in iOS and Safari.
    2. Remove default button styles. */
button,
[type='button'],
[type='reset'],
[type='submit'] {
  -webkit-appearance: button; /* 1 */
  background-color: transparent; /* 2 */
  background-image: none; /* 2 */
}

/*  Use the modern Firefox focus style for all focusable elements. */
:-moz-focusring {
  outline: auto;
}

/*  Remove the additional `:invalid` styles in Firefox. (https://github.com/mozilla/gecko-dev/blob/2f9eacd9d3d995c937b4251a5557d95d494c9be1/layout/style/res/forms.css#L728-L737) */
:-moz-ui-invalid {
  box-shadow: none;
}

/*  Add the correct vertical alignment in Chrome and Firefox. */
progress {
  vertical-align: baseline;
}

/*  Correct the cursor style of increment and decrement buttons in Safari. */
::-webkit-inner-spin-button,
::-webkit-outer-spin-button {
  height: auto;
}

/*  1. Correct the odd appearance in Chrome and Safari.
    2. Correct the outline style in Safari. */
[type='search'] {
  -webkit-appearance: textfield; /* 1 */
  outline-offset: -2px; /* 2 */
}

/*  Remove the inner padding in Chrome and Safari on macOS.
  */
::-webkit-search-decoration {
  -webkit-appearance: none;
}

/*  1. Correct the inability to style clickable types in iOS and Safari.
    2. Change font properties to `inherit` in Safari.
  */
::-webkit-file-upload-button {
  -webkit-appearance: button; /* 1 */
  font: inherit; /* 2 */
}

/*  Add the correct display in Chrome and Safari. */
summary {
  display: list-item;
}

/*  Removes the default spacing and border for appropriate elements. */
blockquote,
dl,
dd,
h1,
h2,
h3,
h4,
h5,
h6,
hr,
figure,
p,
pre {
  margin: 0;
}

fieldset {
  margin: 0;
  padding: 0;
}

legend {
  padding: 0;
}

ol,
ul,
menu {
  list-style: none;
  margin: 0;
  padding: 0;
}

/*  Reset default styling for dialogs. */
dialog {
  padding: 0;
}

/*  Prevent resizing textareas horizontally by default. */
textarea {
  resize: vertical;
}

/*  1. Reset the default placeholder opacity in Firefox. (https://github.com/tailwindlabs/tailwindcss/issues/3300)
    2. Set the default placeholder color to the user's configured gray 400 color. */
input::placeholder,
textarea::placeholder {
  /* 1 */
  opacity: 1;

  /* 2 */
  color: var('colors.gray.400', #9ca3af);
}

/*  Set the default cursor for buttons. */
button,
[role='button'] {
  cursor: pointer;
}

/*  Make sure disabled buttons don't get the pointer cursor. */
:disabled {
  cursor: default;
}

/*  1. Make replaced elements `display: block` by default. (https://github.com/mozdevs/cssremedy/issues/14)
    2. Add `vertical-align: middle` to align replaced elements more sensibly by default. (https://github.com/jensimmons/cssremedy/issues/14#issuecomment-634934210) */
img,
svg,
video,
canvas,
audio,
iframe,
embed,
object {
  /* 1 */
  display: block;

  /* 2 */
  vertical-align: middle;
}

/*  Constrain images and videos to the parent width and preserve their intrinsic aspect ratio. (https://github.com/mozdevs/cssremedy/issues/14) */
img,
video {
  max-width: 100%;
  height: auto;
}

/*  Make elements with the HTML hidden attribute stay hidden by default  */
[hidden] {
  display: none;
}

/*  Create a new stacking context from the Lustre application's root element.
    This means that modal components will always properly float above the page
    content if they're inserted at the end of the document. */
#root,
[data-lustre-app] {
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
    border_radius: 4,
    primary: colour.iris(),
    greyscale: colour.slate(),
    error: colour.red(),
    success: colour.green(),
    warning: colour.yellow(),
    info: colour.blue(),
  ))
}

pub fn custom(theme: Theme) -> Element(a) {
  // 🚨 DO NOT MODIFY THIS COMMENT OR THE FOLLOWING STYLES 🚨
  //
  // The `@embed` comment below is used by the build script in `test/build.gleam`
  // to inject the appropriate CSS into our gleam source. Make sure you run that
  // build script before publishing a new version of this package.
  //
  // @embed styles.css
  "
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
  --text-md: $(base_text) px;
  --text-lg: calc(var(--text-md) * 1.25);
  --text-xl: calc(var(--text-lg) * 1.25);
  --text-2xl: calc(var(--text-xl) * 1.25);
  --text-3xl: calc(var(--text-2xl) * 1.25);
  --text-4xl: calc(var(--text-3xl) * 1.25);
  --text-5xl: calc(var(--text-4xl) * 1.25);

  --space-xs: calc(0.5 * 1em);
  --space-sm: calc(0.75 * 1em);
  --space-md: 1em;
  --space-lg: calc(1.25 * 1em);
  --space-xl: calc(2 * 1em);
  --space-2xl: calc(3.25 * 1em);
  --space-3xl: calc(5.25 * 1em);
  --space-4xl: calc(8.5 * 1em);
  --space-5xl: calc(13.75 * 1em);

  --font-base: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif,
    'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  --font-alt: ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
    'Liberation Mono', 'Courier New', monospace;

  --border-radius: $(border_radius) px;

  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 20px 25px -5px rgb(0 0 0 / 0.1),
    0 8px 10px -6px rgb(0 0 0 / 0.1);
}

[data-variant='primary'] {
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

[data-variant='greyscale'] {
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

[data-variant='error'] {
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

[data-variant='success'] {
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

[data-variant='warning'] {
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

[data-variant='info'] {
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

* {
  max-inline-size: 60ch;
}

html,
body,
div,
header,
nav,
main,
footer {
  max-inline-size: none;
}

body {
  background: var(--app-background);
  color: var(--text-high-contrast);
  font-family: var(--font-base);
  font-size: var(--text-md);
  line-height: 1.4;
}

h1,
h2,
h3,
h4,
h5,
h6 {
  font-family: var(--font-alt);
  line-height: 1.2;
}

h1 {
  font-size: var(--text-5xl);
}

h2 {
  font-size: var(--text-4xl);
}

h3 {
  font-size: var(--text-3xl);
}

h4 {
  font-size: var(--text-2xl);
}

h5 {
  font-size: var(--text-xl);
}

h6 {
  font-size: var(--text-lg);
}

pre,
code,
kbd,
samp {
  font-family: var(--font-mono);
}

input:not([type='checkbox']):not([type='radio']),
textarea {
  border: 1px solid var(--element-border-subtle);
  border-radius: var(--border-radius);
}

input:not([type='checkbox']):not([type='radio']):focus,
textarea:focus {
  border-color: var(--element-border-strong);
}

.lustre-icon {
  width: var(--text-md);
  height: var(--text-md);
}

/* LUSTRE UI LAYOUT: STACK -------------------------------------------------- */

.lustre-ui-stack {
  --gap: var(--space-md);

  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  gap: var(--gap);
}

.lustre-ui-stack.split {
  justify-content: space-between;
}

.lustre-ui-stack.split:only-child {
  block-size: 100%;
}

/* LUSTRE UI LAYOUT: CLUSTER ------------------------------------------------ */

.lustre-ui-cluster {
  --gap: var(--space-md);
  --dir: flex-start;

  align-items: center;
  display: flex;
  flex-wrap: wrap;
  gap: var(--gap);
  justify-content: var(--dir);
}

/* LUSTRE UI LAYOUT: ASIDE -------------------------------------------------- */

.lustre-ui-aside {
  --align: start;
  --gap: var(--space-md);
  --dir: row;
  --wrap: wrap;
  --min: 60%;

  align-items: var(--align);
  display: flex;
  flex-direction: var(--dir);
  flex-wrap: var(--wrap);
  gap: var(--gap);
}

.lustre-ui-aside > :first-child {
  flex-basis: 0;
  flex-grow: 999;
  min-inline-size: var(--min);
}

.lustre-ui-aside > :last-child {
  flex-grow: 1;
  max-height: max-content;
}

/* LUSTRE UI LAYOUT: SEQUENCE ----------------------------------------------- */

.lustre-ui-sequence {
  --gap: var(--space-md);
  --break: 30rem;

  display: flex;
  flex-wrap: wrap;
  gap: var(--gap);
}

.lustre-ui-sequence > * {
  flex-basis: calc((var(--break) - 100%) * 999);
  flex-grow: 1;
}

.lustre-ui-sequence[data-split-at='3'] > :nth-last-child(n + 3),
.lustre-ui-sequence[data-split-at='3'] > :nth-last-child(n + 3) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='4'] > :nth-last-child(n + 4),
.lustre-ui-sequence[data-split-at='4'] > :nth-last-child(n + 4) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='5'] > :nth-last-child(n + 5),
.lustre-ui-sequence[data-split-at='5'] > :nth-last-child(n + 5) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='6'] > :nth-last-child(n + 6),
.lustre-ui-sequence[data-split-at='6'] > :nth-last-child(n + 6) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='7'] > :nth-last-child(n + 7),
.lustre-ui-sequence[data-split-at='7'] > :nth-last-child(n + 7) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='8'] > :nth-last-child(n + 8),
.lustre-ui-sequence[data-split-at='8'] > :nth-last-child(n + 8) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='8'] > :nth-last-child(n + 8),
.lustre-ui-sequence[data-split-at='8'] > :nth-last-child(n + 8) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='9'] > :nth-last-child(n + 9),
.lustre-ui-sequence[data-split-at='9'] > :nth-last-child(n + 9) ~ * {
  flex-basis: 100%;
}

.lustre-ui-sequence[data-split-at='10'] > :nth-last-child(n + 10),
.lustre-ui-sequence[data-split-at='10'] > :nth-last-child(n + 10) ~ * {
  flex-basis: 100%;
}

/* LUSTRE UI LAYOUT: BOX ---------------------------------------------------- */

.lustre-ui-box {
  --gap: var(--space-sm);

  padding: var(--gap);
}

/* LUSTRE UI ELEMENTS: BUTTON ----------------------------------------------- */

.lustre-ui-button {
  --bg-active: var(--element-background-strong);
  --bg-hover: var(--element-background-hover);
  --bg: var(--element-background);
  --border-active: var(--bg-active);
  --border: var(--bg);
  --text: var(--text-high-contrast);

  background-color: var(--bg);
  border: 1px solid var(--border, var(--bg), var(--element-border-subtle));
  border-radius: var(--border-radius);
  color: var(--text);
  padding: var(--space-xs) var(--space-sm);
}

.lustre-ui-button:hover,
.lustre-ui-button:focus-within {
  background-color: var(--bg-hover);
}

.lustre-ui-button:hover:active,
.lustre-ui-button:focus-within:active {
  background-color: var(--bg-active);
  border-color: var(--border-active);
}

.lustre-ui-button.solid {
  --bg-active: var(--solid-background-hover);
  --bg-hover: var(--solid-background-hover);
  --bg: var(--solid-background);
  --border-active: var(--solid-background-hover);
  --border: var(--solid-background);
  --text: white;
}

.lustre-ui-button.solid:hover:active,
.lustre-ui-button.solid:focus-within:active {
  --bg-active: color-mix(in srgb, var(--solid-background-hover) 90%, black);
  --border-active: color-mix(in srgb, var(--solid-background-hover) 90%, black);
}

.lustre-ui-button.soft {
  --bg-active: var(--element-background-strong);
  --bg-hover: var(--element-background-hover);
  --bg: var(--element-background);
  --border-active: var(--bg-active);
  --border: var(--bg);
  --text: var(--text-high-contrast);
}

.lustre-ui-button.outline {
  --bg: unset;
  --border: var(--element-border-subtle);
}

/* LUSTRE UI ELEMENTS: INPUT ------------------------------------------------ */

/*  When a .lustre-ui-input has at least two children, the first child is used as
    the label for the input. We want labels to always be greyscale unless the user
    explicitly sets it to something else.

    This selector matches the first child but only when it is not the only one!
 */
.lustre-ui-input *:first-child:not(:only-child) {
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

  color: var(--text-low-contrast);
  font-size: var(--text-sm);
}

/*  When a .lustre-ui-input has more than two children it means additional info
    was provided to display under the input tag. This can an arbitrary number of
    children and the selectors below style all of them.
*/
.lustre-ui-input :nth-child(2) ~ :nth-child(n + 2) {
  color: var(--solid-background);
  font-size: var(--text-sm);
}

/*  Attributes passed to the input element over on the gleam side of things pass
    through to the input HTML element but won't affect any of the sibligns (eg
    the label or any info elements).
    
    When a user passes in a variant to colour the input we also want that colour
    to be applied to any info elements because the most common case is displaying
    an error or warning under an input after validation fails.
*/
.lustre-ui-input :nth-child(2)[data-variant='primary'] ~ :nth-child(n + 2) {
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

.lustre-ui-input :nth-child(2)[data-variant='greyscale'] ~ :nth-child(n + 2) {
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

.lustre-ui-input :nth-child(2)[data-variant='greyscale'] ~ :nth-child(n + 2) {
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

.lustre-ui-input :nth-child(2)[data-variant='error'] ~ :nth-child(n + 2) {
  --app-background: $(error.app_background);
  --app-background-subtle: $(success.app_background_subtle);
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

.lustre-ui-input :nth-child(2)[data-variant='warning'] ~ :nth-child(n + 2) {
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

.lustre-ui-input :nth-child(2)[data-variant='success'] ~ :nth-child(n + 2) {
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

.lustre-ui-input :nth-child(2)[data-variant='info'] ~ :nth-child(n + 2) {
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

/* LUSTRE UI STATEFUL COMPONENTS: LISTBOX ----------------------------------- */

lustre-ui-listbox .label {
  font-size: var(--text-sm);
}

lustre-ui-listbox .options {
  border-radius: var(--border-radius);
  border: 1px solid var(--element-border-subtle);
  padding-bottom: var(--space-xs);
  padding-top: var(--space-xs);
}

lustre-ui-listbox:focus-within .options {
  border-color: var(--element-border-strong);
}

lustre-ui-listbox .option {
  cursor: pointer;
}

lustre-ui-listbox .option:hover,
lustre-ui-listbox .option:focus-within {
  background-color: var(--element-background-hover);
}

lustre-ui-listbox .option:hover:active,
lustre-ui-listbox .option:focus-within:active,
lustre-ui-listbox .option[aria-selected='true'] {
  background-color: var(--element-background-strong);
}

lustre-ui-listbox .option .marker > svg {
  width: var(--text-lg);
  height: var(--text-lg);
}

/* LUSTRE UI STATEFUL COMPONENTS: COMBOBOX ---------------------------------- */

lustre-ui-combobox .label {
  font-size: var(--text-sm);
}

lustre-ui-combobox .input {
  border-radius: var(--border-radius);
  border: 1px solid var(--element-border-subtle);
  box-sizing: content-box;
  height: calc(1em * 1.4);
  padding: var(--space-xs) var(--space-sm);
}

lustre-ui-combobox:focus-within .input {
  border-color: var(--element-border-strong);
}

lustre-ui-combobox .toggle {
  padding: var(--space-xs) var(--space-sm);
}

lustre-ui-combobox .toggle > svg {
  width: var(--text-lg);
  height: var(--text-lg);
}

lustre-ui-combobox .options-container {
  position: relative;
}

lustre-ui-combobox .options {
  background-color: var(--app-background);
  border-radius: var(--border-radius);
  border: 1px solid var(--element-border-subtle);
  box-shadow: var(--shadow-md);
  padding-bottom: var(--space-xs);
  padding-top: var(--space-xs);
  position: absolute;
  visibility: hidden;
  width: 100%;
}

lustre-ui-combobox:has([aria-expanded='true']) .options {
  visibility: visible;
}

lustre-ui-combobox:focus-within .options {
  border-color: var(--element-border-strong);
}

lustre-ui-combobox .option {
  cursor: pointer;
}

lustre-ui-combobox .option:hover,
lustre-ui-combobox .option:focus-within {
  background-color: var(--element-background-hover);
}

lustre-ui-combobox .option:hover:active,
lustre-ui-combobox .option:focus-within:active,
lustre-ui-combobox .option[aria-selected='true'] {
  background-color: var(--element-background-strong);
}

lustre-ui-combobox .option .marker > svg {
  width: var(--text-lg);
  height: var(--text-lg);
}

  "
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
    // Note the extra space here. Because we're writing the stylesheet externally
    // but leaving in these hooks for string replacement, it can confuse the code
    // formatter. 
    //
    // Specific to thes two is that a formatter will insert a space between $(base_text)
    // and px, which will break the stylesheet if we don't remove it.
    #("$(base_text) ", int.to_string(theme.base_text)),
    #("$(border_radius) ", int.to_string(theme.border_radius)),
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
      gleam_community_colour.to_css_rgba_string(scale.app_background),
    ),
    #(
      "$(" <> prefix <> ".app_background_subtle)",
      gleam_community_colour.to_css_rgba_string(scale.app_background_subtle),
    ),
    #(
      "$(" <> prefix <> ".app_border)",
      gleam_community_colour.to_css_rgba_string(scale.app_border),
    ),
    #(
      "$(" <> prefix <> ".element_background)",
      gleam_community_colour.to_css_rgba_string(scale.element_background),
    ),
    #(
      "$(" <> prefix <> ".element_background_hover)",
      gleam_community_colour.to_css_rgba_string(scale.element_background_hover),
    ),
    #(
      "$(" <> prefix <> ".element_background_strong)",
      gleam_community_colour.to_css_rgba_string(scale.element_background_strong),
    ),
    #(
      "$(" <> prefix <> ".element_border_subtle)",
      gleam_community_colour.to_css_rgba_string(scale.element_border_subtle),
    ),
    #(
      "$(" <> prefix <> ".element_border_strong)",
      gleam_community_colour.to_css_rgba_string(scale.element_border_strong),
    ),
    #(
      "$(" <> prefix <> ".solid_background)",
      gleam_community_colour.to_css_rgba_string(scale.solid_background),
    ),
    #(
      "$(" <> prefix <> ".solid_background_hover)",
      gleam_community_colour.to_css_rgba_string(scale.solid_background_hover),
    ),
    #(
      "$(" <> prefix <> ".text_high_contrast)",
      gleam_community_colour.to_css_rgba_string(scale.text_high_contrast),
    ),
    #(
      "$(" <> prefix <> ".text_low_contrast)",
      gleam_community_colour.to_css_rgba_string(scale.text_low_contrast),
    ),
  ])
}
