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
    let assert Ok(styles) = simplifile.read(path)

    css <> styles <> "\n"
  }
  let _ = {
    let assert Ok(regex) =
      regex.compile("const element_css: String = \"(.|\n)+\"", options)
    let assert [Match(content, ..)] = regex.scan(regex, src)
    use css <- compile_css(css, "styles")
    let css =
      css
      |> string.replace("\\", "\\\\")
      |> string.replace("\"", "\\\"")
    let out =
      string.replace(
        src,
        content,
        "const element_css: String = \"\n" <> css <> "\n\"",
      )
    let assert Ok(_) = simplifile.write("./src/lustre/ui/styles.gleam", out)
  }

  let css = {
    use css, path <- list.fold(entries, "")
    use <- bool.guard(
      !string.ends_with(path, ".css") || string.ends_with(path, "_reset.css"),
      css,
    )
    let assert Ok(styles) = simplifile.read(path)

    css <> styles <> "\n"
  }
  let _ = {
    let assert Ok(regex) =
      regex.compile("const element_css_no_reset: String = \"(.|\n)+\"", options)
    let assert [Match(content, ..)] = regex.scan(regex, src)
    use css <- compile_css(css, "styles-no-reset")
    let css =
      css
      |> string.replace("\\", "\\\\")
      |> string.replace("\"", "\\\"")
    let out =
      string.replace(
        src,
        content,
        "const element_css_no_reset: String = \"\n" <> css <> "\n\"",
      )
    let assert Ok(_) = simplifile.write("./src/lustre/ui/styles.gleam", out)
  }
}

// EXTERNALS -------------------------------------------------------------------

@external(javascript, "./build.ffi.mjs", "compile_css")
fn compile_css(_css: String, _name: String, _next: fn(String) -> a) -> a {
  panic as "This build script should be run using the JavaScript target as it depends on PostCSS."
}
