// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/int
import gleam/string

// CONSTANTS -------------------------------------------------------------------

const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

const letters_size = 52

const digits = "0123456789"

const alphabet = letters <> digits

const alphabet_size = 62

// CONSTRUCTORS ----------------------------------------------------------------

pub fn new(length: Int) -> String {
  use <- bool.guard(length <= 0, "")
  let index = int.random(letters_size - 1)
  let character = string.slice(letters, index, 1)

  do_new("lustre-ui-" <> character, length - 1)
}

fn do_new(id: String, length: Int) -> String {
  use <- bool.guard(length <= 0, id)
  let index = int.random(alphabet_size - 1)
  let character = string.slice(alphabet, index, 1)

  do_new(id <> character, length - 1)
}
