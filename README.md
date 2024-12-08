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

- A set of **thoughtfully designed** and **accessible** components that have been
  written with idiomatic Gleam and CSS in mind.

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
for users looking for a flexible "headless" UI library you will find that many
aspects of each component's styles are customisable through CSS variables.

## Installation

> **Note**: Lustre UI is currently in pre-release and under active development.
> If you have any feedback or suggestions, please open an issue or reach out on
> the [Gleam discord](https://discord.gg/Fm8Pwmy).

Lustre UI is published on [Hex](https://hex.pm/packages/lustre_ui). To use it in
your project with Gleam:

```sh
gleam add lustre_ui@1.0.0-rc.1
```

Ensure the required CSS is rendered in your apps by serving the stylesheet found
in the `priv/static` directory of this package!

## Support

Lustre is mostly built by just me, [Hayleigh](https://github.com/hayleigh-dot-dev),
around two jobs. If you'd like to support my work, you can [sponsor me on GitHub](https://github.com/sponsors/hayleigh-dot-dev).

Contributions are also very welcome! If you've spotted a bug, or would like to
suggest a feature, please open an issue or a pull request.

## Reads

- https://www.aha.io/engineering/articles/web-components-and-implicit-slot-names
- https://www.abeautifulsite.net/posts/dynamic-slots/
- https://thomaswilburn.github.io/wc-book/sd-slots.html
- https://nolanlawson.com/2022/11/28/shadow-dom-and-accessibility-the-trouble-with-aria/
