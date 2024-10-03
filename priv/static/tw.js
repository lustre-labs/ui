const plugin = require("tailwindcss/plugin");
const SCALES = ["base", "primary", "secondary", "success", "warning", "danger"];

const $ = (name) => `var(--lustre-ui-${name})`;
const colour = (name) => `rgb(${$(name)} / <alpha-value>)`;

module.exports = plugin(
  ({ addComponents }) => {
    addComponents({
      [`.bg-lui`]: {
        backgroundColor: colour(`bg`),
      },
      [`.bg-w-subtle`]: {
        backgroundColor: colour(`bg-subtle`),
      },
      [`.text-lui`]: {
        color: colour(`text`),
      },
      [`.text-w-subtle`]: {
        color: colour(`text-subtle`),
      },

      ...SCALES.reduce(
        (obj, scale) => ({
          ...obj,
          // Create a utility that sets the lustre/ui colour variables for the
          // scale given in the data-scale attribute.
          [`[data-scale=${scale}]`]: {
            "--lustre-ui-bg": $(`${scale}-bg`),
            "--lustre-ui-bg-subtle": $(`${scale}-bg-subtle`),
            "--lustre-ui-tint": $(`${scale}-tint`),
            "--lustre-ui-tint-subtle": $(`${scale}-tint-subtle`),
            "--lustre-ui-tint-strong": $(`${scale}-tint-strong`),
            "--lustre-ui-accent": $(`${scale}-accent`),
            "--lustre-ui-accent-subtle": $(`${scale}-accent-subtle`),
            "--lustre-ui-accent-strong": $(`${scale}-accent-strong`),
            "--lustre-ui-solid": $(`${scale}-solid`),
            "--lustre-ui-solid-subtle": $(`${scale}-solid-subtle`),
            "--lustre-ui-solid-strong": $(`${scale}-solid-strong`),
            "--lustre-ui-solid-text": $(`${scale}-solid-text`),
            "--lustre-ui-text": $(`${scale}-text`),
            "--lustre-ui-text-subtle": $(`${scale}-text-subtle`),
          },

          // Create a utility class that sets the lustre/ui colour variables
          // for the given scale.
          [`.${scale}`]: {
            "--lustre-ui-bg": $(`${scale}-bg`),
            "--lustre-ui-bg-subtle": $(`${scale}-bg-subtle`),
            "--lustre-ui-tint": $(`${scale}-tint`),
            "--lustre-ui-tint-subtle": $(`${scale}-tint-subtle`),
            "--lustre-ui-tint-strong": $(`${scale}-tint-strong`),
            "--lustre-ui-accent": $(`${scale}-accent`),
            "--lustre-ui-accent-subtle": $(`${scale}-accent-subtle`),
            "--lustre-ui-accent-strong": $(`${scale}-accent-strong`),
            "--lustre-ui-solid": $(`${scale}-solid`),
            "--lustre-ui-solid-subtle": $(`${scale}-solid-subtle`),
            "--lustre-ui-solid-strong": $(`${scale}-solid-strong`),
            "--lustre-ui-solid-text": $(`${scale}-solid-text`),
            "--lustre-ui-text": $(`${scale}-text`),
            "--lustre-ui-text-subtle": $(`${scale}-text-subtle`),
          },

          // Create some utility classes that read more naturally than the
          // generated tailwind ones. For example, by default to set the background
          // colour to the primary background colour indicated in the theme,
          // you would have to write `bg-primary-bg`. These utility classes
          // make it so you can instead write `bg-primary`.
          [`.bg-w-${scale}`]: {
            backgroundColor: colour(`${scale}-bg`),
          },
          [`.bg-w-${scale}-subtle`]: {
            backgroundColor: colour(`${scale}-bg-subtle`),
          },
          [`.text-w-${scale}`]: {
            color: colour(`${scale}-text`),
          },
          [`.text-w-${scale}-subtle`]: {
            color: colour(`${scale}-text-subtle`),
          },
        }),
        {},
      ),
    });
  },
  {
    theme: {
      extend: {
        borderRadius: {
          "w-xs": $("radius-xs"),
          "w-sm": $("radius-sm"),
          "w-md": $("radius-md"),
          "w-lg": $("radius-lg"),
          "w-xl": $("radius-xl"),
          "w-xl2": $("radius-xl-2"),
          "w-xl3": $("radius-xl-3"),
        },

        colors: {
          // Register a 'lustre-ui' colour palette in the user's tailwind theme
          // that can be used to access the currently-inherited colour palette.
          ["w"]: {
            bg: colour("bg"),
            "bg-subtle": colour("bg-subtle"),
            tint: colour("tint"),
            "tint-subtle": colour("tint-subtle"),
            "tint-strong": colour("tint-strong"),
            accent: colour("accent"),
            "accent-subtle": colour("accent-subtle"),
            "accent-strong": colour("accent-strong"),
            solid: colour("solid"),
            "solid-subtle": colour("solid-subtle"),
            "solid-strong": colour("solid-strong"),
            "solid-text": colour("solid-text"),
            text: colour("text"),
            "text-subtle": colour("text-subtle"),
          },

          // Register each colour scale in the theme as a separate palette in
          // the user's tailwind theme.
          ...SCALES.reduce(
            (obj, scale) => ({
              ...obj,
              [`w-${scale}`]: {
                bg: colour(`${scale}-bg`),
                "bg-subtle": colour(`${scale}-bg-subtle`),
                tint: colour(`${scale}-tint`),
                "tint-subtle": colour(`${scale}-tint-subtle`),
                "tint-strong": colour(`${scale}-tint-strong`),
                accent: colour(`${scale}-accent`),
                "accent-subtle": colour(`${scale}-accent-subtle`),
                "accent-strong": colour(`${scale}-accent-strong`),
                solid: colour(`${scale}-solid`),
                "solid-subtle": colour(`${scale}-solid-subtle`),
                "solid-strong": colour(`${scale}-solid-strong`),
                "solid-text": colour(`${scale}-solid-text`),
                text: colour(`${scale}-text`),
                "text-subtle": colour(`${scale}-text-subtle`),
              },
            }),
            {},
          ),
        },

        fontFamily: {
          "w-heading": $("font-heading"),
          "w-body": $("font-body"),
          "w-code": $("font-code"),
        },

        spacing: {
          "w-xs": $("spacing-xs"),
          "w-sm": $("spacing-sm"),
          "w-md": $("spacing-md"),
          "w-lg": $("spacing-lg"),
          "w-xl": $("spacing-xl"),
          "w-xl2": $("spacing-xl-2"),
          "w-xl3": $("spacing-xl-3"),
        },
      },
    },
  },
);
