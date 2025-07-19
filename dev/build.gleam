import esgleam/mod/install
import simplifile

pub fn main() {
  case simplifile.is_file("build/dev/bin/package/bin/esbuild") {
    Ok(True) -> Nil
    _ -> install.fetch()
  }

  todo
}
