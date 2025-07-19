import esgleam
import esgleam/mod/install
import gleam/list
import gleam/result
import globlin
import simplifile

pub fn main() {
  case simplifile.is_file("build/dev/bin/package/bin/esbuild") {
    Ok(True) -> Nil
    _ -> install.fetch()
  }

  // Process CSS files
  let assert Ok(_) = process_css(True)
  let assert Ok(_) = process_css(False)

  // Process JS files
  let assert Ok(_) = bundle_js(False)
  let assert Ok(_) = bundle_js(True)
}

fn process_css(include_reset: Bool) {
  let assert Ok(files) = simplifile.get_files("./src")
  let assert Ok(pattern) = globlin.new_pattern("./**/*.css")
  let initial_layers = case include_reset {
    True -> "@layer reset, primitives, components;\n\n"
    False -> "@layer primitives, components;\n\n"
  }

  let assert Ok(css) =
    files
    |> list.filter(globlin.match_pattern(pattern:, path: _))
    |> list.try_fold(initial_layers, fn(css, path) {
      use src <- result.map(simplifile.read(path))
      let src = case path {
        "./src/lustre/ui/primitives/reset.css" if include_reset ->
          case include_reset {
            True -> "@layer reset {\n" <> src <> "\n}"
            False -> ""
          }

        "./src/lustre/ui/primitives/" <> _ ->
          "@layer primitives {\n" <> src <> "\n}"

        _ -> "@layer components {\n" <> src <> "\n}"
      }

      css <> src <> "\n\n"
    })

  let filename = case include_reset {
    True -> "lustre_ui"
    False -> "lustre_ui_no_reset"
  }

  let assert Ok(_) =
    simplifile.write("./priv/static/" <> filename <> ".css", css)

  let assert Ok(_) =
    esgleam.new("")
    |> esgleam.entry("../../../../priv/static/" <> filename <> ".css")
    |> esgleam.minify(True)
    |> esgleam.raw("--outfile=./priv/static/" <> filename <> ".min.css")
    |> esgleam.bundle
}

fn bundle_js(minify: Bool) {
  let filename = case minify {
    True -> ".min.mjs"
    False -> ".mjs"
  }

  let assert Ok(_) =
    esgleam.new("")
    |> esgleam.entry("../../../../src/lustre_ui_components.mjs")
    |> esgleam.minify(minify)
    |> esgleam.raw("--outfile=./priv/static/lustre_ui_components" <> filename)
    |> esgleam.bundle
}
