<h1 align="center">Lustre UI</h1>

<div align="center">
  A thoughtfully designed UI library for Lustre.
</div>

<br />

<div align="center">
  <a href="https://hex.pm/packages/lustre_ui">
  <img src="https://img.shields.io/hexpm/v/lustre_ui"
      alt="Available on Hex" />
  </a>
</div>

<div align="center">
  <h3>
    <a href="https://hexdocs.pm/lustre">
      Lustre
    </a>
    <span> | </span>
    <a href="https://discord.gg/Fm8Pwmy">
      Discord
    </a>
  </h3>
</div>

<div align="center">
  <sub>Built with ❤︎ by
  <a href="https://twitter.com/hayleighdotdev">Hayleigh Thompson</a>
</div>

---

## Features

- A set of **thoughtfully designed** and **accessible** components that account
  written with idiomatic Gleam and CSS in mind.

- A collection of **layouting primitives** that make it easy to build complex
  UIs without knowledge of flexbox or grid.

- **Utility classes** that make it easy to style your own components without
  writing CSS.

- A customisable **theme system** to tweak colours, spacing, and typography to
  fit your brand.

## Philosophy

Many of Lustre's users are backend or fullstack developers with less interest or
experience in frontend development. Lustre UI is primarily designed with those
folks in mind, and has two main goals:

- Make it easy to build good-looking, accessible UIs without needing to know
  much about CSS or design.

- Encourage well-structured semantic HTML and avoid div soup.

To achieve this, Lustre UI is _opinionated_ on many aspects of the visual design.
For folks that don't want to worry about design, this is a feature not a bug, but
for users looking for a flexible "headless" UI library you may have to look elsewhere.

## Installation

> **Note**: Lustre UI is currently still an alpha release while we work on the
> core library and experiment with different components. Expect the API to change
> from time to time and documentation to be sparse!

Lustre UI is published on [Hex](https://hex.pm/packages/lustre_ui). To use it in
your project with Gleam:

```sh
gleam add lustre_ui
```

Ensure the required CSS is rendered in your apps by either serving the stylesheet
found in the `priv/static` directory of this package or rendering the styles inline
using the functions found in [`lustre/ui/util/styles`](https://hexdocs.pm/lustre_ui/lustre/ui/util/styles.html).

Lustre UI is configured to work out of the box with no additional themeing or
setup required, so you can just drop the stylesheet in and go!

## Support

Lustre is mostly built by just me, [Hayleigh](https://github.com/hayleigh-dot-dev),
around two jobs. If you'd like to support my work, you can [sponsor me on GitHub](https://github.com/sponsors/hayleigh-dot-dev).

Contributions are also very welcome! If you've spotted a bug, or would like to
suggest a feature, please open an issue or a pull request.
