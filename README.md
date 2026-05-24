<h1 align="center">lustre/ui</h1>

<div align="center">
  An accessible headless UI library for Lustre.
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
  <a href="https://bsky.app/profile/hayleigh.dev">Hayleigh Thompson</a>
</div>

---

## Features

- A set of **accessible** and **unstyled** components built for design systems
  and rich interfaces.

- Usable in server-rendered applications and Lustre server components, as well as
  client-rendered apps.

## Philosophy

How an interface or component works and how it looks are two challenging but
distinct aspects of a design system that are often conflated in ui libraries. We
think it's better for everyone if these two things are decoupled, so lustre/ui is
a "headless" library focused on _functionality_ that leaves styling up to application
and design system authors.

We've designed lustre/ui with a few goals in mind:

- Make it easy to build accessible interfaces.

- Provide a primitive HTML-like API that more-opinionated abstractions can be
  built on top of.


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

## Usage

In order for lustre/ui to work correctly you need to do two things:

1. Include the lustre/ui stylesheet in your app. This can be found in the
   `priv/static` directory for _this package_ and can either be served by your
   backend (in case of a full stack application) or copied or otherwise included
   from `build/packages/lustre_ui/priv/static` in your frontend application.

2. Construct a theme from the `lustre/ui/theme` module and render the dynamic
   style element by calling `theme.to_style` or wrapping your application's view
   function using `theme.inject`.

**Both** of these steps must be done in order for the components to render
correctly. The base stylesheet includes the necessary CSS rules and classes for
every component, and your theme defines the design tokens and CSS variables used
by those components.

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
