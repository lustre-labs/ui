import gleam/result
import lustre
import lustre/ui/otp

pub fn register() -> Result(Nil, lustre.Error) {
  use _ <- result.try(otp.register())

  Ok(Nil)
}
