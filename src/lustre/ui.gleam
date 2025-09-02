import gleam/result
import lustre
import lustre/ui/checkbox
import lustre/ui/menu
import lustre/ui/otp

pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(checkbox.register())
  use _ <- result.try(menu.register())
  use _ <- result.try(otp.register())

  Ok(Nil)
}
