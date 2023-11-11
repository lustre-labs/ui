// IMPORTS ---------------------------------------------------------------------

import lustre/attribute.{type Attribute, attribute}
import lustre/ui/colour.{type Scale}

// TYPES -----------------------------------------------------------------------

/// A theme is a collection of colour scales that define the look and feel of
/// your application. You can consider the "primary" scale as your brand or 
/// accent colour. The "greyscale" scale can be used when you want suitable
/// shading without any particular colour or meaning. The "error", "warning",
/// "success", and "info" scales are semantic colours that can be used to communicate
/// meaning to the user.
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

/// This type enumerates the different colour scales that are available in a 
/// theme. It is mostly used to set the variant of an element using the
/// `variant` attribute, but you could also use it in your own custom elements.
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

/// Lustre_ui's base theme. If you just need something that looks good and don't
/// have any strict requirements, you can use this theme to get going quickly.
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

/// Use this attribute to set the colour scale of an element. Unless a child
/// element sets its own variant, it will inherit the variant of its parent. You
/// could, for example, set the variant on some custom alert element to be 
/// `Warning`. Then, any buttons or icons inside the alert will inherit the
/// warning palette and be coloured accordingly.
/// 
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
