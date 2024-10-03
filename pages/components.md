# How we use components

Some parts of Lustre UI use Lustre's component system to hide state and logic
from the rest of your application. This can be an effective way to reduce
boilerplate and manage complexity, but it might also challenge how you're used to
thinking about Lustre applications.

The rest of this doc will explain how we use components in Lustre UI and what you
need to do to make sure things are working correctly.

## Knowing when something is a component

Your view function in a Lustre application always has to return `Element(msg)` so
it can be difficult to work out at a glance when something is a component or not.
In Lustre UI we follow a convention where modules that contain components will
*always* have at least two exports:

- a `name` constant that is the name of the component, like
  `pub const name: String = "lustre-ui-collapse"`.

- a `register` function that registers the custom element in the browser. More
  on that in a moment.

If a module does _not_ define these two exports, then it is not defining a
component.

Some modules might _use_ components without defining them directly. In those
cases the module will always return a `register` function to register any of the
components it depends on. This function will behave slightly differently to the
individual register functions, and _will not fail_ if a component has already
been defined.

## Components must be registered

If you are using Lustre UI in a browser-based Lustre application, you must
remember to register any components you use _before_ you try to render them.


Lustre's components are built on top of the Web Component standards and appear as
real HTML elements in the DOM.

## Components are always controlled

Native HTML elements like `<input>` or `<select>` can be ussd in an "uncontrolled"
way. This is where you let the element maintain its own internal state and your
program listens for events when it wants to know what that state is.

Components in Lustre UI are intended to be used as part of a larger Lustre application,
and in Lustre we want our model to be the single source of truth for the DOM.
This means components in Lustre UI do not store internal state in cases where it
is reasonable for a parent application to control it instead.

For example, the `collapse` component will not expand or collapse on its own in
response to user interaction, instead the component will emit events and wait for
the parent to explicitly set the `aria-expanded` attribute before changing.

Taking this approach means important UI state is always stored in your application's
model, but internal details like focus trapping and keyboard interaction can still
be handled by components without leaking into your application.
