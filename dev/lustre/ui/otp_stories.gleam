import lustre/attribute
import lustre/dev/fable
import lustre/ui/otp

pub fn default_story() {
  use <- fable.story("Default")
  use value <- fable.input(label: "OTP", default: "")
  use controls <- fable.scene()

  otp.root(
    [
      otp.value(fable.get(controls, value)),
      otp.on_change(fable.set(value, _)),
      attribute.class("otp-root"),
    ],
    [],
  )
}

pub fn six_digits_story() {
  use <- fable.story("Six digits")
  use value <- fable.input(label: "OTP", default: "")
  use controls <- fable.scene()

  otp.root(
    [
      otp.value(fable.get(controls, value)),
      otp.on_change(fable.set(value, _)),
      attribute.class("otp-root"),
    ],
    [
      otp.digit(),
      otp.digit(),
      otp.digit(),
      otp.digit(),
      otp.digit(),
      otp.digit(),
    ],
  )
}

pub fn with_separator_story() {
  use <- fable.story("With separator")
  use value <- fable.input(label: "OTP", default: "")
  use controls <- fable.scene()

  otp.root(
    [
      otp.value(fable.get(controls, value)),
      otp.on_change(fable.set(value, _)),
      attribute.class("otp-root"),
    ],
    [
      otp.digit(),
      otp.digit(),
      otp.digit(),
      otp.separator(),
      otp.digit(),
      otp.digit(),
      otp.digit(),
    ],
  )
}

pub fn letters_story() {
  use <- fable.story("Letters")
  use value <- fable.input(label: "OTP", default: "")
  use controls <- fable.scene()

  otp.root(
    [
      otp.value(fable.get(controls, value)),
      otp.on_change(fable.set(value, _)),
      otp.allow(otp.Letters),
      attribute.class("otp-root"),
    ],
    [],
  )
}

pub fn letters_and_digits_story() {
  use <- fable.story("Letters and digits")
  use value <- fable.input(label: "OTP", default: "")
  use controls <- fable.scene()

  otp.root(
    [
      otp.value(fable.get(controls, value)),
      otp.on_change(fable.set(value, _)),
      otp.allow(otp.Both),
      attribute.class("otp-root"),
    ],
    [],
  )
}
// UTILITIES -------------------------------------------------------------------
