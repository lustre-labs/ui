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
      tw(),
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
      tw(),
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
      tw(),
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

// UTILITIES -------------------------------------------------------------------

fn tw() {
  attribute.class(
    " flex gap-2
      [&::part(digit)]:w-12 [&::part(digit)]:h-12 [&::part(digit)]:border [&::part(digit)]:border-gray-200 [&::part(digit)]:rounded
      [&::part(digit_active)]:!border-blue-500
      [&::part(separator)]:w-4 [&::part(separator)]:h-px [&::part(separator)]:mx-2 [&::part(separator)]:bg-gray-600
      [&::part(caret)]:w-px [&::part(caret)]:h-3 [&::part(caret)]:bg-blue-500
    ",
  )
}
