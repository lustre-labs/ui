import gleam/list
import gleam/result
import globlin
import simplifile

pub fn main() {
  let assert Ok(files) = simplifile.get_files("./src")
  let assert Ok(pattern) = globlin.new_pattern("./**/*.css")

  let assert Ok(css) =
    files
    |> list.filter(globlin.match_pattern(pattern:, path: _))
    |> list.try_fold("@layer reset, primitives, components;\n\n", fn(css, path) {
      use src <- result.map(simplifile.read(path))
      let src = case path {
        "./src/lustre/ui/primitives/reset.css" ->
          "@layer reset { " <> src <> " }"
        "./src/lustre/ui/primitives/" <> _ ->
          "@layer primitives { " <> src <> " }"
        _ -> "@layer components { " <> src <> " }"
      }

      css <> src <> "\n\n"
    })

  let assert Ok(_) = simplifile.write("./priv/static/lustre_ui.css", css)
}
