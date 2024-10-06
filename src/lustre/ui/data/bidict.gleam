// IMPORTS ---------------------------------------------------------------------

import gleam/dict.{type Dict}
import gleam/list
import gleam/order.{type Order}
import gleam/pair
import gleam/result

// TYPES -----------------------------------------------------------------------

pub type Bidict(a, b) =
  #(Dict(a, b), Dict(b, a))

// CONSTRUCTORS ----------------------------------------------------------------

pub fn new() -> Bidict(a, b) {
  #(dict.new(), dict.new())
}

pub fn from_list(entries: List(#(a, b))) -> Bidict(a, b) {
  use bidict, entry <- list.fold(entries, new())

  set(bidict, entry.0, entry.1)
}

pub fn indexed(values: List(a)) -> Bidict(a, Int) {
  use bidict, value, index <- list.index_fold(values, new())

  set(bidict, value, index)
}

// QUERIES ---------------------------------------------------------------------

pub fn has(bidict: Bidict(a, b), key: a) -> Bool {
  dict.has_key(bidict.0, key)
}

pub fn has_inverse(bidict: Bidict(a, b), key: b) -> Bool {
  dict.has_key(bidict.1, key)
}

pub fn get(bidict: Bidict(a, b), key: a) -> Result(b, Nil) {
  dict.get(bidict.0, key)
}

pub fn get_inverse(bidict: Bidict(a, b), key: b) -> Result(a, Nil) {
  dict.get(bidict.1, key)
}

pub fn min(bidict: Bidict(a, b), compare: fn(a, a) -> Order) -> Result(b, Nil) {
  dict.to_list(bidict.0)
  |> list.sort(fn(a, b) { compare(a.0, b.0) })
  |> list.first
  |> result.map(pair.second)
}

pub fn min_inverse(
  bidict: Bidict(a, b),
  compare: fn(b, b) -> Order,
) -> Result(a, Nil) {
  dict.to_list(bidict.1)
  |> list.sort(fn(a, b) { compare(a.0, b.0) })
  |> list.first
  |> result.map(pair.second)
}

pub fn max(bidict: Bidict(a, b), compare: fn(a, a) -> Order) -> Result(b, Nil) {
  dict.to_list(bidict.0)
  |> list.sort(fn(a, b) { compare(b.0, a.0) })
  |> list.first
  |> result.map(pair.second)
}

pub fn max_inverse(
  bidict: Bidict(a, b),
  compare: fn(b, b) -> Order,
) -> Result(a, Nil) {
  dict.to_list(bidict.1)
  |> list.sort(fn(a, b) { compare(b.0, a.0) })
  |> list.first
  |> result.map(pair.second)
}

pub fn next(
  bidict: Bidict(a, b),
  key: a,
  increment: fn(b) -> b,
) -> Result(a, Nil) {
  get(bidict, key)
  |> result.map(increment)
  |> result.then(get_inverse(bidict, _))
}

pub fn prev(
  bidict: Bidict(a, b),
  key: a,
  decrement: fn(b) -> b,
) -> Result(a, Nil) {
  get(bidict, key)
  |> result.map(decrement)
  |> result.then(get_inverse(bidict, _))
}

// MANIPULATIONS ---------------------------------------------------------------

pub fn set(bidict: Bidict(a, b), key: a, value: b) -> Bidict(a, b) {
  #(dict.insert(bidict.0, key, value), dict.insert(bidict.1, value, key))
}
