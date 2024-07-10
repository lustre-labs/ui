const $ = (name) => `var(--lustre-ui-${name})`;

module.exports = {
  optionsHandler(options = {}) {
    return ({ addComponents }) => {
      addComponents(
        SCALES.reduce(
          (obj, scale) => ({
            ...obj,
            [`[data-scale=${scale}]`]: {
              "--lustre-ui-bg": $(`${scale}-bg`),
              "--lustre-ui-bg-subtle": $(`${scale}-bg-subtle`),
              "--lustre-ui-tint": $(`${scale}-tint`),
              "--lustre-ui-tint-subtle": $(`${scale}-tint-subtle`),
              "--lustre-ui-tint-strong": $(`${scale}-tint-strong`),
              "--lustre-ui-accent": $(`--lustre-ui-${scale}-accent`),
              "--lustre-ui-accent-subtle": $(`${scale}-accent-subtle`),
              "--lustre-ui-accent-strong": $(`${scale}-accent-strong`),
              "--lustre-ui-solid": $(`${scale}-solid`),
              "--lustre-ui-solid-subtle": $(`${scale}-solid-subtle`),
              "--lustre-ui-solid-strong": $(`${scale}-solid-strong`),
              "--lustre-ui-solid-text": $(`${scale}-solid-text`),
              "--lustre-ui-text": $(`${scale}-text`),
              "--lustre-ui-text-subtle": $(`${scale}-text-subtle`),
            },
            [`.${scale}`]: {
              "--lustre-ui-bg": $(`${scale}-bg`),
              "--lustre-ui-bg-subtle": $(`${scale}-bg-subtle`),
              "--lustre-ui-tint": $(`${scale}-tint`),
              "--lustre-ui-tint-subtle": $(`${scale}-tint-subtle`),
              "--lustre-ui-tint-strong": $(`${scale}-tint-strong`),
              "--lustre-ui-accent": $(`--lustre-ui-${scale}-accent`),
              "--lustre-ui-accent-subtle": $(`${scale}-accent-subtle`),
              "--lustre-ui-accent-strong": $(`${scale}-accent-strong`),
              "--lustre-ui-solid": $(`${scale}-solid`),
              "--lustre-ui-solid-subtle": $(`${scale}-solid-subtle`),
              "--lustre-ui-solid-strong": $(`${scale}-solid-strong`),
              "--lustre-ui-solid-text": $(`${scale}-solid-text`),
              "--lustre-ui-text": $(`${scale}-text`),
              "--lustre-ui-text-subtle": $(`${scale}-text-subtle`),
            },
          }),
          {},
        ),
      );
    };
  },
  themeHandler(options = {}) {
    return { theme: { extend: {} } };
  },
};

const SCALES = ["base", "primary", "secondary", "success", "warning", "danger"];
