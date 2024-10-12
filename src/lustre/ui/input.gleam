// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html

// ELEMENTS --------------------------------------------------------------------

pub fn input(attributes: List(Attribute(msg))) -> Element(msg) {
  html.input([
    attribute.class("p-w-sm rounded-sm"),
    attribute.class(
      "focus:outline outline-1 outline-w-primary-solid outline-offset-0
       invalid:outline-w-danger-solid
      ",
    ),
    ..attributes
  ])
}

pub fn container(
  attributes: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  html.div(
    [
      attribute.class("relative flex items-center"),
      attribute.class("[&:has(*+:is(input,select))>*:not(input,select)]:left-2"),
      attribute.class("[&:has(*+:is(input,select))>:is(input,select)]:pl-8"),
      attribute.class("[&:has(:is(input,select)+*)>:is(input,select)]:pr-8"),
      attribute.class(
        "[&>:is(input,select)+*]:!left-[unset] [&>:is(input,select)+*]:right-2",
      ),
      ..attributes
    ],
    children,
  )
}

pub fn icon(child: Element(msg)) -> Element(msg) {
  html.span([attribute.class("absolute pointer-events-none size-4")], [child])
}
