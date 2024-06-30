// IMPORTS ---------------------------------------------------------------------

import gleam/list

// BUILDERS --------------------------------------------------------------------

pub type Attribute(options, msg) {
  Attr(fn(options) -> options)
  AttrBatch(List(Attribute(options, msg)))
}

pub fn attr(update: fn(options) -> options) -> Attribute(options, msg) {
  Attr(update)
}

pub fn to_options(
  attributes: List(Attribute(options, msg)),
  default: options,
) -> options {
  list.fold(attributes, default, fn(acc, attribute) {
    case attribute {
      Attr(update) -> update(acc)
      AttrBatch(attrs) -> to_options(attrs, acc)
    }
  })
}
