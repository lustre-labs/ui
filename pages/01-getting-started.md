# 01 Getting started

Lustre/ui is a component library for building interactive user interfaces built
around the central idea of a _theme_. The library provides a set of styled
components that draw from a common pool of design tokens and then gives you a
way to customise those tokens to fit your own style or brand.

To see how it all comes together, let's build a simple one-button counter. This
isn't a _lustre_ tutorial, so if you're brand new to lustre you might want to
head over to the main [quickstart guide](https://hexdocs.pm/lustre/guide/01-quickstart.html)
first.

## Setup

Let's start by creating a new Gleam project, and adding the dependencies we'll
need.

```sh
# Create a new gleam project and enter it
gleam new lustre_ui_quickstart && cd lustre_ui_quickstart

# Add dependencies
gleam add lustre lustre_ui

# Add lustre_dev_tools to access the development server
gleam add lustre_dev_tools --dev
```

Before we look at lustre/ui, we'll put together the application logic so we can
focus on styling for the rest of the guide.

```gleam
import lustre
import lustre/element/html
import lustre/event

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Model {
  Model(count: Int)
}

fn init(_) {
  Model(0)
}

type Msg {
  Increment
}

fn update(model, msg) {
  case msg {
    Increment -> Model(..model, count: model.count + 1
  }
}

fn view(model) {
  let count = int.to_string(model.count)

  html.button([event.on_click(Increment)], [html.text(count)])
}
```

To confirm everything is working, run `gleam run -m lustre/dev start` to start
the development server and open `localhost:1234` in your browser. Clicking the
button should update the count.

## Adding lustre/ui styles

In order for lustre/ui to work correctly we need to do two things:

1. Include the lustre/ui stylesheet in your app. This stylesheet contains all
   the necessary CSS to style each component and can be found in your project's
   build directory at `build/packages/lustre_ui/priv/static/lustre_ui.css`.

2. Construct a new theme and dynamically inject its styles into your application.

Let's start with the base static stylesheet. How you serve lustre/ui's stylesheet
will depend on your application and how you deploy it: common approaches include
copying the CSS file from the package into your own application's `priv/static`
directory, or serving it from a server using something like wisp's
[`serve_static`](https://hexdocs.pm/wisp/wisp.html#serve_static) function.

For simplicity during development, we can add a `<link>` tag to the generated
HTML document and point it directly to the stylesheet:

```diff
  <!doctype html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />

      <title>🚧 lustre_ui_quickstart</title>

-     <!-- Uncomment this if you add the TailwindCSS integration -->
-     <!-- <link rel="stylesheet" href="/priv/static/lustre_ui_quickstart.css"> -->
+     <link rel="stylesheet" href="/build/packages/lustre_ui/priv/static/lustre_ui.css">
      <script type="module" src="/priv/static/lustre_ui_quickstart.mjs"></script>
    </head>
    <body>
      <div id="app"></div>
    </body>
  </html>
```

If you refresh the page (or restart the development server if you stopped it) you
might already notice some changes. Lustre/ui includes a **CSS reset** which is
a common way for styling frameworks to ensure consistent base styles across
browsers.

This isn't quite enough to get going yet, though. Lustre/ui's stylesheet contains
all the styles for each component, but the look and feel of your application is
dictated by your _theme_.

## Configuring your theme

A theme is the collection of design tokens lustre/ui uses to style each component:
it configures things like padding, colours, and border radius. By making the theme
flexible, lustre/ui can author many components without dictating a strict visual
style!

The library ships with a default theme, which we'll use for now by storing it in
our model.

```diff
+ import lustre/ui/theme.{type Theme}

  type Model {
+   Model(count: Int, theme: Theme)
  }

  fn init(_) {
    Model(0, theme.default())
  }
```

Lustre/ui gives us two ways to render a theme into a stylesheet that defines all
your design tokens as CSS variables. For more control over where you insert the
stylehseet, you can use `theme.to_style`: this function is useful to injecting
the tokens into the `<head>` of a server-rendered document.

For SPAs and client applications, `theme.inject` can be used to wrap your `view`
function and automatically insert the stylesheet:


```diff
  fn view(model) {
+   use <- theme.inject(model.theme)
    let count = int.to_string(model.count)

    html.button([event.on_click(Increment)], [html.text(count)])
  }
```

## Rendering lustre/ui elements!

We've set up everything we need to start using lustre/ui in our pages and elements.
Among other things, lustre/ui includes a [button element](https://hexdocs.pm/lustre_ui/lustre/ui/button.html)
we can use instead of the unstyled HTML button:

```diff
+ import lustre/ui/button

  fn view(model) {
    use <- theme.inject(model.theme)
    let count = int.to_string(model.count)

+   button.element([event.on_click(Increment)], [html.text(count)])
  }
```

All modules in lustre/ui follow the same pattern: the main element or container
in the module is always called "element" to encourage qualified usage. That means
we have `button.element`, or `checkbox.element`, or `combobox.element`.

A module may also contain other elements intended to be used as children. In the
button's case we can add a number badge to show the count:

```diff
+ import lustre/ui/button

  fn view(model) {
    use <- theme.inject(model.theme)
-   let count = int.to_string(model.count)

+   button.element([event.on_click(Increment)], [
      html.text("Increment"),
      button.count_badge([], model.count)
    ])
  }
```

Elements in lustre/ui are designed to be flexible rather than prescriptive so
often children can be supplied in any order or combination and the element will
adapt accordingly.

## Customising your theme

The default theme is a great to drop in when you're just starting out, but once
your application has grown a bit you might want to start customising it to better
suit your own design.

It's possible to construct a theme from scratch, but the `lustre/ui/theme` module
also exposes a number of builders to modify an existing theme. Let's tweak the
default theme by changing the primary colour and removing the rounded borders of
all elements:

```diff
+ import lustre/ui/colour

  fn init(_) {
+   let theme =
+     theme.default()
+     |> theme.with_primary_scale(colour.sage())
+     |> theme.with_radius(theme.constant_size(0.0))

+   Model(0, theme)
  }
```
