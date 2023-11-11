// IMPORTS ---------------------------------------------------------------------

import gleam/string
import lustre/attribute.{type Attribute, attribute}
import lustre/ui/colour.{type Scale}

// TYPES -----------------------------------------------------------------------

///
/// 
pub type Theme {
  Theme(
    primary: Scale,
    greyscale: Scale,
    error: Scale,
    warning: Scale,
    success: Scale,
    info: Scale,
  )
}

///
/// 
pub type Variant {
  Primary
  Greyscale
  Error
  Warning
  Success
  Info
}

// ELEMENTS --------------------------------------------------------------------

/// Lustre_ui's base theme.
/// 
pub fn base() -> Theme {
  Theme(
    primary: colour.iris(),
    greyscale: colour.slate(),
    error: colour.red(),
    success: colour.green(),
    warning: colour.yellow(),
    info: colour.blue(),
  )
}

// ATTRIBUTES ------------------------------------------------------------------

pub fn variant(variant: Variant) -> Attribute(a) {
  attribute(
    "data-variant",
    case variant {
      Primary -> "primary"
      Greyscale -> "greyscale"
      Error -> "error"
      Warning -> "warning"
      Success -> "success"
      Info -> "info"
    },
  )
}

// UTILS -----------------------------------------------------------------------

pub fn var(name: String) -> String {
  case string.starts_with(name, "--") {
    True -> "var(" <> name <> ")"
    False -> "var(--" <> name <> ")"
  }
}
