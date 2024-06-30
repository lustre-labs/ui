//// All `lustre_ui` components are configured through attributes.
//// This module provides helpers to handle common scenarios across all of our components.
////
//// Oh! Btw, this module is name `attr` so it won't conflict with `lustre/attribute` 💡
////

// IMPORTS ---------------------------------------------------------------------

import gleam/function
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/ui/internals/attr

// HELPERS ---------------------------------------------------------------------

/// Apply an attribute based on an `Result`'s `Ok(a)` value.
/// If the result is `Error`, no attribute is passed.
///
/// ```
/// button.view(
///   [attr.from_result(model.save_response, fn(_) { button.success() })],
///   ..
/// )
/// ```
///
pub fn from_result(
  result: Result(a, b),
  attribute: fn(a) -> attr.Attribute(options, msg),
) {
  case result {
    Ok(a) -> attribute(a)
    Error(_) -> none()
  }
}

/// Apply an attribute based on an `Option`'s `Some(a)` value.
/// If the option is `None`, no attribute is passed.
///
/// ```
/// button.view(
///   [attr.from_maybe(model.last_name, fn(_) { button.secondary() })],
///   ..
/// )
/// ```
///
pub fn from_option(
  result: Option(a),
  attribute: fn(a) -> attr.Attribute(options, msg),
) {
  case result {
    Some(a) -> attribute(a)
    None -> none()
  }
}

/// Apply an attribute based on a `Bool` value.
/// If the value is `False`, no attribute is passed.
///
/// ```
/// button.view(
///   [attr.from_bool(model.is_loading, button.disabled())],
///   ..
/// )
/// ```
///
pub fn from_bool(
  result: Option(a),
  attribute: fn(a) -> attr.Attribute(options, msg),
) {
  case result {
    Some(a) -> attribute(a)
    None -> none()
  }
}

/// Apply a list of attributes as a single attribute.
///
/// ```
/// button.view([
///     attr.from_bool(
///       model.is_exploding,
///       attr.batch([button.disabled(), button.danger()]),
///     ),
///   ],
///   ..
/// )
/// ```
///
pub fn batch(attributes: List(attr.Attribute(option, msg))) {
  attr.AttrBatch(attributes)
}

/// Apply a list of attributes as a single attribute while filtering them by related predicates.
/// ```
/// button.view([
///     attr.filter(
///       #(button.danger(), model.is_exploding),
///       #(button.disabled(), model.is_loading)
///     ),
///   ],
///   ..
/// )
/// ```
///
pub fn filter(attributes: List(#(attr.Attribute(option, msg), Bool))) {
  attributes
  |> list.filter_map(fn(tuple) {
    case tuple.1 {
      True -> Ok(tuple.0)
      False -> Error(Nil)
    }
  })
  |> attr.AttrBatch
}

///
///
pub fn none() {
  attr.Attr(function.identity)
}
