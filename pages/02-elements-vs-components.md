# 02 Components vs elements

In many frontend frameworks, the word "component" is a general term used to
describe any construct in the framework that can render something. There's often
an implicit but _optional_ ability for components to encapsulate state too. As an
example, the following two snippets are both considered React **components**:

```jsx
export function ButtonComponent({ onClick, children }) {
  return (
    <button className="my-button" onClick={onClick}>
      {children}
    </button>
  )
}
```

```jsx
import { useState } from 'react'

export function CounterComponent() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <ButtonComponent onClick={() => setCount(count - 1)}>Decr</ButtonComponent>
      <p>{count}</p>
      <ButtonComponent onClick={() => setCount(count + 1)}>Incr</ButtonComponent>
    </div>
  )
}
```

State locality and encapsulation is a positive feature for these frameworks, and
to work out if a component does contain its own state you have to peak at the
implementation.

In Lustre we do things a bit differently, and centralising state in your application's
`Model` is a key part of what makes the framework feel robust and approachable.
Lustre _does_ have an abstraction for stateful components though, and so for
clarity we make an explicit difference between stateless _elements_ (also known
as "view functions") and stateful _components_.

If we take the React components from above and translate them to Lustre, we get
something like:

```gleam
import lustre/attribute
import lustre/element/html
import lustre/event

pub fn button_element(on_click, children) {
  html.button([attribute.class("my-button"), event.on_click(on_click)], children)
}
```

```gleam
import lustre
import lustre/element
import lustre/element/html

pub fn register() {
  lustre.register("counter-component", lustre.simple(init, update, view))
}

pub fn counter_component() {
  element.element("counter-component", [], [])
}

fn init(_) {
  0
}

type Msg {
  Incr
  Decr
}

fn update(model, msg) {
  case msg {
    Incr -> model + 1
    Decr -> model - 1
  }
}

fn view(model) {
  let count = int.to_string(model)

  html.div([], [
    button_element(Decr, [html.text("Decr")]),
    html.p([], [html.text(count)]),
    button_element(Incr, [html.text("Incr")]),
  ])
}
```

Woah, that's quite a bit more! Components in Lustre are complete applications
registered as custom elements, and then rendered like all other HTML elements.
Because of the set up, the number of components a typical application have will
be far fewer than other frontend frameworks and the decision to encapsulate state
in a component tends to be given more weight even as the project grows.

Throughout Lustre's documentation - both in the core library and other packages
such as this one - the word **component** will always refer to stateful components,
and everything else will always be referred to as an "element" or "view function".
We encourage you to adopt this naming when writing your own applications or
content about Lustre, so everyone stays on the same page!

## Why does lustre/ui need components?

Elm - one of the frameworks Lustre is heavily inspired by - has this to say about
components:

> Folks coming from React expect everything to be components. Actively trying to
> make components is a recipe for disaster in Elm. The root issue is that components
> are objects. It would be odd to start using Elm and wonder "how do I structure
> my application with objects?" There are no objects in Elm!

Given that both Elm and Gleam are immutable functional programming languages, you
might question why Lustre (and lustre/ui) need components at all. In our experience
with a number of large production Elm codebases, a number of problems tend to
arise when components are not available:

- Developers tend to naturally gravitate to quasi-components over time with modules
  that contain their own `Model`, `update` and `view` to make related functionality
  more manageable.

- When more than one of the same "component" is on the page, the application model
  must come up with an ad-hoc system to distinguish messages and state for each
  component such as `Dict String ComponentModel`.

- Storing component state far away from where it's (exclusively) used leads to
  problems. It becomes difficult to understand the responsibilities of different
  view functions when unrelated state needs to be passed down through these elements.

There's also a reason unique to Lustre that makes components an interesting
option:

- Components create a hard boundary between the component and its parent which
  is particularly useful when taking advantage of _server components_. That boundary
  makes it possible to blend server and client components in a render tree without
  sending unnecessary data over the wire.

## How to use components in lustre/ui

You can always register a component in lustre/ui because the module will expose
a `register` function. Some examples of components available in lustre/ui include:

- [`accordion`](https://hexdocs.pm/lustre_ui/lustre/ui/accordion.html)
- [`combobox`](https://hexdocs.pm/lustre_ui/lustre/ui/combobox.html)

If you are using Lustre and lustre/ui to build a Single Page Application (SPA) on
the **client**, it's important to call the `register` function of any component
you intend to use.

Typically this is done before you start your application:

```gleam
import lustre
import lustre/ui/combobox

pub fn main() {
  let app = lustre.simple(init, update, view)

  let assert Ok(_) = combobox.register()
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
```

Lustre components are built on top of the [Web Components](https://developer.mozilla.org/en-US/docs/Web/API/Web_components)
standard, which means the browser needs to know about the components you want to
use before they can be rendered properly.

If you are rendering components on the **server** either with server-side rendering
or static site generation, you should include a supplementary bundle as a `<script>`
tag in your HTML alongside the package's CSS. Here's how you might modify the
[wisp "serving static assets" example](https://github.com/gleam-wisp/wisp/tree/main/examples/06-serving-static-assets)
to serve lustre/ui's styles and component bundle:

```diff
  // app/web.gleam
+ import gleam/erlang/application
  import wisp

  pub type Context {
    Context(static_directory: String)
  }

  pub fn middleware(
    req: wisp.Request,
    ctx: Context,
    handle_request: fn(wisp.Request) -> wisp.Response,
  ) -> wisp.Response {
    let req = wisp.method_override(req)
    use <- wisp.log_request(req)
    use <- wisp.rescue_crashes
    use req <- wisp.handle_head(req)
    use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

+   let assert Ok(lustre_ui_static) = application.priv_directory("lustre_ui")
+   use <- wisp.serve_static(req, under: "/static", from: lustre_ui_static)

    handle_request(req)
  }
```

```diff
  // app/router.gleam
  import app/web.{type Context}
  import gleam/string_tree
  import wisp.{type Request, type Response}

  const html = "<!DOCTYPE html>
  <html lang=\"en\">
    <head>
      <meta charset=\"utf-8\">
      <title>Wisp Example</title>
      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
      <link rel=\"stylesheet\" href=\"/static/styles.css\">
+     <link rel=\"stylesheet\" href=\"/static/lustre_ui.css\">

    </head>
    <body>
+     <script src=\"/static/lustre_ui_components.mjs\" type=\"module\"></script>
      <script src=\"/static/main.js\"></script>
    </body>
  </html>
  "

  pub fn handle_request(req: Request, ctx: Context) -> Response {
    use _req <- web.middleware(req, ctx)
    wisp.html_response(string_tree.from_string(html), 200)
  }
```
