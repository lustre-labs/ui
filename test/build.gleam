// IMPORTS ---------------------------------------------------------------------

import gleam/bool
import gleam/list
import gleam/regex.{Match, Options}
import gleam/string
import simplifile

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let options = Options(case_insensitive: False, multi_line: True)
  let assert Ok(src) = simplifile.read("./src/lustre/ui/styles.gleam")
  let assert Ok(entries) = simplifile.get_files("./src/lustre/ui")
  let css = {
    use css, path <- list.fold(entries, "")
    use <- bool.guard(!string.ends_with(path, ".css"), css)
    let assert Ok(styles) = simplifile.read("./src/lustre/ui/" <> path)

    css <> styles <> "\n"
  }
  let assert Ok(regex) =
    regex.compile("const element_css: String = \"(.|\n)+\"", options)
  let assert [Match(content, ..)] = regex.scan(regex, src)
  use css <- compile_css(css)
  let css = string.replace(css, "\"", "\\\"")
  let out =
    string.replace(
      src,
      content,
      "const element_css: String = \"\n"
      <> css
      <> "\n\"",
    )
  let assert Ok(_) = simplifile.write(out, "./src/lustre/ui/styles.gleam")
}

// EXTERNALS -------------------------------------------------------------------

@external(javascript, "./build.ffi.mjs", "compile_css")
fn compile_css(_: String, _: fn(String) -> a) -> a {
  panic as "This build script should be run using the JavaScript target as it depends on PostCSS."
}
