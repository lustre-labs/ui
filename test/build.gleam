// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{Some}
import gleam/regex.{Match, Options}
import gleam/result
import gleam/string
import simplifile

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let options = Options(case_insensitive: False, multi_line: True)

  let assert Ok(src) = simplifile.read("./src/lustre/ui.gleam")
  let assert Ok(regex) = regex.compile("// @embed (.+)", options)

  let matches = regex.scan(regex, src)
  let out = {
    use src, Match(submatches: [Some(path)], ..) <- list.fold(matches, src)
    let assert Ok(css) = simplifile.read("./priv/" <> path)
    let assert Ok([Match(content: chunk, ..)]) =
      { "// @embed " <> path <> "\n  \"(.|\n)+?  \"" }
      |> regex.compile(options)
      |> result.map(regex.scan(_, src))

    string.replace(
      src,
      chunk,
      ["// @embed " <> path, "  \"", string.replace(css, "\"", "'"), "  \""]
      |> string.join("\n"),
    )
  }

  let assert Ok(_) = simplifile.write(out, "./src/lustre/ui.gleam")
}
