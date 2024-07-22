import gleam/io
import tailwind

pub fn main() {
  tailwind.install_and_run([
    "--config=./tailwind.config.js", "--input=./src/lustre_ui.css",
    "--output=./priv/static/lustre_ui.css",
  ])
  |> io.debug
}
