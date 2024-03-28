// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/json.{type Json}
import gleam/result
import gleam_community/colour.{type Colour}

// TYPES -----------------------------------------------------------------------

pub type Scale {
  // The 12 steps in a colour scale are taken directly from Radix's excellent
  // design system. See their documentation for a more-thorough break down of
  // what each step in the scale is used for:
  //
  // https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale
  //
  Scale(
    // Radix Scale 1.  App background
    app_background: Colour,
    // Radix Scale 2.  Subtle background
    app_background_subtle: Colour,
    // Radix Scale 6.  Subtle borders and separators
    app_border: Colour,
    // Radix Scale 3.  UI element background
    element_background: Colour,
    // Radix Scale 4.  Hovered UI element background
    element_background_hover: Colour,
    // Radix Scale 5.  Active / Selected UI element background
    element_background_strong: Colour,
    // Radix Scale 7.  UI element border and focus rings
    element_border_subtle: Colour,
    // Radix Scale 8.  Hovered UI element border
    element_border_strong: Colour,
    // Radix Scale 9.  Solid backgrounds
    solid_background: Colour,
    // Radix Scale 10. Hovered solid backgrounds
    solid_background_hover: Colour,
    // Radix Scale 12. High-contrast text
    text_high_contrast: Colour,
    // Radix Scale 11. Low-contrast text
    text_low_contrast: Colour,
  )
}

// JSON ------------------------------------------------------------------------

pub fn encode_scale(scale: Scale) -> Json {
  json.object([
    #("app_background", colour.encode(scale.app_background)),
    #("app_background_subtle", colour.encode(scale.app_background_subtle)),
    #("app_border", colour.encode(scale.app_border)),
    #("element_background", colour.encode(scale.element_background)),
    #("element_background_hover", colour.encode(scale.element_background_hover)),
    #(
      "element_background_strong",
      colour.encode(scale.element_background_strong),
    ),
    #("element_border_subtle", colour.encode(scale.element_border_subtle)),
    #("element_border_strong", colour.encode(scale.element_border_strong)),
    #("solid_background", colour.encode(scale.solid_background)),
    #("solid_background_hover", colour.encode(scale.solid_background_hover)),
    #("text_high_contrast", colour.encode(scale.text_high_contrast)),
    #("text_low_contrast", colour.encode(scale.text_low_contrast)),
  ])
}

pub fn scale_decoder(json: Dynamic) -> Result(Scale, List(DecodeError)) {
  let attempt = fn(field, then) {
    result.try(dynamic.field(field, colour.decoder)(json), then)
  }

  use app_background <- attempt("app_background")
  use app_background_subtle <- attempt("app_background_subtle")
  use app_border <- attempt("app_border")
  use element_background <- attempt("element_background")
  use element_background_hover <- attempt("element_background_hover")
  use element_background_strong <- attempt("element_background_strong")
  use element_border_subtle <- attempt("element_border_subtle")
  use element_border_strong <- attempt("element_border_strong")
  use solid_background <- attempt("solid_background")
  use solid_background_hover <- attempt("solid_background_hover")
  use text_high_contrast <- attempt("text_high_contrast")
  use text_low_contrast <- attempt("text_low_contrast")

  Ok(Scale(
    app_background,
    app_background_subtle,
    app_border,
    element_background,
    element_background_hover,
    element_background_strong,
    element_border_subtle,
    element_border_strong,
    solid_background,
    solid_background_hover,
    text_high_contrast,
    text_low_contrast,
  ))
}

fn from_radix_scale(
  app_background a: Int,
  app_background_subtle b: Int,
  app_border c: Int,
  element_background d: Int,
  element_background_hover e: Int,
  element_background_strong f: Int,
  element_border_subtle g: Int,
  element_border_strong h: Int,
  solid_background i: Int,
  solid_background_hover j: Int,
  text_high_contrast k: Int,
  text_low_contrast l: Int,
) -> Scale {
  let assert Ok(app_background) = colour.from_rgb_hex(a)
  let assert Ok(app_background_subtle) = colour.from_rgb_hex(b)
  let assert Ok(app_border) = colour.from_rgb_hex(c)
  let assert Ok(element_background) = colour.from_rgb_hex(d)
  let assert Ok(element_background_hover) = colour.from_rgb_hex(e)
  let assert Ok(element_background_strong) = colour.from_rgb_hex(f)
  let assert Ok(element_border_strong) = colour.from_rgb_hex(g)
  let assert Ok(element_border_subtle) = colour.from_rgb_hex(h)
  let assert Ok(solid_background) = colour.from_rgb_hex(i)
  let assert Ok(solid_background_hover) = colour.from_rgb_hex(j)
  let assert Ok(text_high_contrast) = colour.from_rgb_hex(k)
  let assert Ok(text_low_contrast) = colour.from_rgb_hex(l)

  Scale(
    app_background,
    app_background_subtle,
    app_border,
    element_background,
    element_background_hover,
    element_background_strong,
    element_border_subtle,
    element_border_strong,
    solid_background,
    solid_background_hover,
    text_high_contrast,
    text_low_contrast,
  )
}

// RADIX COLOUR SCALES ---------------------------------------------------------

pub fn grey() -> Scale {
  from_radix_scale(
    app_background: 0xFCFCFC,
    app_background_subtle: 0xF9F9F9,
    app_border: 0xDDDDDD,
    element_background: 0xF1F1F1,
    element_background_hover: 0xEBEBEB,
    element_background_strong: 0xE4E4E4,
    element_border_subtle: 0xBBBBBB,
    element_border_strong: 0xD4D4D4,
    solid_background: 0x8D8D8D,
    solid_background_hover: 0x808080,
    text_high_contrast: 0x202020,
    text_low_contrast: 0x646464,
  )
}

pub fn grey_dark() -> Scale {
  from_radix_scale(
    app_background: 0x111111,
    app_background_subtle: 0x191919,
    app_border: 0x3A3A3A,
    element_background: 0x222222,
    element_background_hover: 0x2A2A2A,
    element_background_strong: 0x313131,
    element_border_subtle: 0x484848,
    element_border_strong: 0x606060,
    solid_background: 0x6E6E6E,
    solid_background_hover: 0x7B7B7B,
    text_high_contrast: 0xEEEEEE,
    text_low_contrast: 0xB4B4B4,
  )
}

pub fn mauve() -> Scale {
  from_radix_scale(
    app_background: 0xFDFCFD,
    app_background_subtle: 0xFAF9FB,
    app_border: 0xDFDCE3,
    element_background: 0xF3F1F5,
    element_background_hover: 0xECEAEF,
    element_background_strong: 0xE6E3E9,
    element_border_subtle: 0xBCBAC7,
    element_border_strong: 0xD5D3DB,
    solid_background: 0x8E8C99,
    solid_background_hover: 0x817F8B,
    text_high_contrast: 0x211F26,
    text_low_contrast: 0x65636D,
  )
}

pub fn mauve_dark() -> Scale {
  from_radix_scale(
    app_background: 0x121113,
    app_background_subtle: 0x1A191B,
    app_border: 0x3C393F,
    element_background: 0x232225,
    element_background_hover: 0x2B292D,
    element_background_strong: 0x323035,
    element_border_subtle: 0x49474E,
    element_border_strong: 0x625F69,
    solid_background: 0x6F6D78,
    solid_background_hover: 0x7C7A85,
    text_high_contrast: 0xEEEEF0,
    text_low_contrast: 0xB5B2BC,
  )
}

pub fn slate() -> Scale {
  from_radix_scale(
    app_background: 0xFCFCFD,
    app_background_subtle: 0xF9F9FB,
    app_border: 0xDDDDE3,
    element_background: 0xF2F2F5,
    element_background_hover: 0xEBEBEF,
    element_background_strong: 0xE4E4E9,
    element_border_subtle: 0xB9BBC6,
    element_border_strong: 0xD3D4DB,
    solid_background: 0x8B8D98,
    solid_background_hover: 0x7E808A,
    text_high_contrast: 0x1C2024,
    text_low_contrast: 0x60646C,
  )
}

pub fn slate_dark() -> Scale {
  from_radix_scale(
    app_background: 0x111113,
    app_background_subtle: 0x18191B,
    app_border: 0x363A3F,
    element_background: 0x212225,
    element_background_hover: 0x272A2D,
    element_background_strong: 0x2E3135,
    element_border_subtle: 0x43484E,
    element_border_strong: 0x5A6169,
    solid_background: 0x696E77,
    solid_background_hover: 0x777B84,
    text_high_contrast: 0xEDEEF0,
    text_low_contrast: 0xB0B4BA,
  )
}

pub fn sage() -> Scale {
  from_radix_scale(
    app_background: 0xFBFDFC,
    app_background_subtle: 0xF7F9F8,
    app_border: 0xDCDFDD,
    element_background: 0xF0F2F1,
    element_background_hover: 0xE9ECEB,
    element_background_strong: 0xE3E6E4,
    element_border_subtle: 0xB8BCBA,
    element_border_strong: 0xD2D5D3,
    solid_background: 0x868E8B,
    solid_background_hover: 0x7A817F,
    text_high_contrast: 0x1A211E,
    text_low_contrast: 0x5F6563,
  )
}

pub fn sage_dark() -> Scale {
  from_radix_scale(
    app_background: 0x101211,
    app_background_subtle: 0x171918,
    app_border: 0x373B39,
    element_background: 0x202221,
    element_background_hover: 0x272A29,
    element_background_strong: 0x2E3130,
    element_border_subtle: 0x444947,
    element_border_strong: 0x5B625F,
    solid_background: 0x63706B,
    solid_background_hover: 0x717D79,
    text_high_contrast: 0xECEEED,
    text_low_contrast: 0xADB5B2,
  )
}

pub fn olive() -> Scale {
  from_radix_scale(
    app_background: 0xFCFDFC,
    app_background_subtle: 0xF8FAF8,
    app_border: 0xDBDEDB,
    element_background: 0xF1F3F1,
    element_background_hover: 0xEAECEA,
    element_background_strong: 0xE3E5E3,
    element_border_subtle: 0xB9BCB8,
    element_border_strong: 0xD2D4D1,
    solid_background: 0x898E87,
    solid_background_hover: 0x7C817B,
    text_high_contrast: 0x1D211C,
    text_low_contrast: 0x60655F,
  )
}

pub fn olive_dark() -> Scale {
  from_radix_scale(
    app_background: 0x111210,
    app_background_subtle: 0x181917,
    app_border: 0x383A36,
    element_background: 0x212220,
    element_background_hover: 0x282A27,
    element_background_strong: 0x2F312E,
    element_border_subtle: 0x454843,
    element_border_strong: 0x5C625B,
    solid_background: 0x687066,
    solid_background_hover: 0x767D74,
    text_high_contrast: 0xECEEEC,
    text_low_contrast: 0xAFB5AD,
  )
}

pub fn sand() -> Scale {
  from_radix_scale(
    app_background: 0xFDFDFC,
    app_background_subtle: 0xF9F9F8,
    app_border: 0xDDDDDA,
    element_background: 0xF2F2F0,
    element_background_hover: 0xEBEBE9,
    element_background_strong: 0xE4E4E2,
    element_border_subtle: 0xBCBBB5,
    element_border_strong: 0xD3D2CE,
    solid_background: 0x8D8D86,
    solid_background_hover: 0x80807A,
    text_high_contrast: 0x21201C,
    text_low_contrast: 0x63635E,
  )
}

pub fn sand_dark() -> Scale {
  from_radix_scale(
    app_background: 0x111110,
    app_background_subtle: 0x191918,
    app_border: 0x3B3A37,
    element_background: 0x222221,
    element_background_hover: 0x2A2A28,
    element_background_strong: 0x31312E,
    element_border_subtle: 0x494844,
    element_border_strong: 0x62605B,
    solid_background: 0x6F6D66,
    solid_background_hover: 0x7C7B74,
    text_high_contrast: 0xEEEEEC,
    text_low_contrast: 0xB5B3AD,
  )
}

pub fn gold() -> Scale {
  from_radix_scale(
    app_background: 0xFDFDFC,
    app_background_subtle: 0xFBF9F2,
    app_border: 0xDAD1BD,
    element_background: 0xF5F2E9,
    element_background_hover: 0xEEEADD,
    element_background_strong: 0xE5DFD0,
    element_border_subtle: 0xB8A383,
    element_border_strong: 0xCBBDA4,
    solid_background: 0x978365,
    solid_background_hover: 0x89775C,
    text_high_contrast: 0x3B352B,
    text_low_contrast: 0x71624B,
  )
}

pub fn gold_dark() -> Scale {
  from_radix_scale(
    app_background: 0x121211,
    app_background_subtle: 0x1B1A17,
    app_border: 0x444039,
    element_background: 0x24231F,
    element_background_hover: 0x2D2B26,
    element_background_strong: 0x38352E,
    element_border_subtle: 0x544F46,
    element_border_strong: 0x696256,
    solid_background: 0x978365,
    solid_background_hover: 0xA39073,
    text_high_contrast: 0xE8E2D9,
    text_low_contrast: 0xCBB99F,
  )
}

pub fn bronze() -> Scale {
  from_radix_scale(
    app_background: 0xFDFCFC,
    app_background_subtle: 0xFDF8F6,
    app_border: 0xE0CEC7,
    element_background: 0xF8F1EE,
    element_background_hover: 0xF2E8E4,
    element_background_strong: 0xEADDD7,
    element_border_subtle: 0xBFA094,
    element_border_strong: 0xD1B9B0,
    solid_background: 0xA18072,
    solid_background_hover: 0x947467,
    text_high_contrast: 0x43302B,
    text_low_contrast: 0x7D5E54,
  )
}

pub fn bronze_dark() -> Scale {
  from_radix_scale(
    app_background: 0x141110,
    app_background_subtle: 0x1C1917,
    app_border: 0x493E3A,
    element_background: 0x262220,
    element_background_hover: 0x302A27,
    element_background_strong: 0x3B3330,
    element_border_subtle: 0x5A4C47,
    element_border_strong: 0x6F5F58,
    solid_background: 0xA18072,
    solid_background_hover: 0xAE8C7E,
    text_high_contrast: 0xEDE0D9,
    text_low_contrast: 0xD4B3A5,
  )
}

pub fn brown() -> Scale {
  from_radix_scale(
    app_background: 0xFEFDFC,
    app_background_subtle: 0xFCF9F6,
    app_border: 0xE8CDB5,
    element_background: 0xF8F1EA,
    element_background_hover: 0xF4E9DD,
    element_background_strong: 0xEFDDCC,
    element_border_subtle: 0xD09E72,
    element_border_strong: 0xDDB896,
    solid_background: 0xAD7F58,
    solid_background_hover: 0x9E7352,
    text_high_contrast: 0x3E332E,
    text_low_contrast: 0x815E46,
  )
}

pub fn brown_dark() -> Scale {
  from_radix_scale(
    app_background: 0x12110F,
    app_background_subtle: 0x1C1816,
    app_border: 0x4D3C2F,
    element_background: 0x28211D,
    element_background_hover: 0x322922,
    element_background_strong: 0x3E3128,
    element_border_subtle: 0x614A39,
    element_border_strong: 0x7C5F46,
    solid_background: 0xAD7F58,
    solid_background_hover: 0xB88C67,
    text_high_contrast: 0xF2E1CA,
    text_low_contrast: 0xDBB594,
  )
}

pub fn yellow() -> Scale {
  from_radix_scale(
    app_background: 0xFDFDF9,
    app_background_subtle: 0xFFFBE0,
    app_border: 0xECDD85,
    element_background: 0xFFF8C6,
    element_background_hover: 0xFCF3AF,
    element_background_strong: 0xF7EA9B,
    element_border_subtle: 0xC9AA45,
    element_border_strong: 0xDAC56E,
    solid_background: 0xFBE32D,
    solid_background_hover: 0xF9DA10,
    text_high_contrast: 0x473B1F,
    text_low_contrast: 0x775F28,
  )
}

pub fn yellow_dark() -> Scale {
  from_radix_scale(
    app_background: 0x14120B,
    app_background_subtle: 0x1B180F,
    app_border: 0x524202,
    element_background: 0x2D2305,
    element_background_hover: 0x362B00,
    element_background_strong: 0x433500,
    element_border_subtle: 0x665417,
    element_border_strong: 0x836A21,
    solid_background: 0xFFE629,
    solid_background_hover: 0xFFFF57,
    text_high_contrast: 0xF6EEB4,
    text_low_contrast: 0xF5E147,
  )
}

pub fn amber() -> Scale {
  from_radix_scale(
    app_background: 0xFEFDFB,
    app_background_subtle: 0xFFF9ED,
    app_border: 0xF5D08C,
    element_background: 0xFFF3D0,
    element_background_hover: 0xFFECB7,
    element_background_strong: 0xFFE0A1,
    element_border_subtle: 0xD6A35C,
    element_border_strong: 0xE4BB78,
    solid_background: 0xFFC53D,
    solid_background_hover: 0xFFBA1A,
    text_high_contrast: 0x4F3422,
    text_low_contrast: 0x915930,
  )
}

pub fn amber_dark() -> Scale {
  from_radix_scale(
    app_background: 0x16120C,
    app_background_subtle: 0x1D180F,
    app_border: 0x5C3D05,
    element_background: 0x302008,
    element_background_hover: 0x3F2700,
    element_background_strong: 0x4D3000,
    element_border_subtle: 0x714F19,
    element_border_strong: 0x8F6424,
    solid_background: 0xFFC53D,
    solid_background_hover: 0xFFD60A,
    text_high_contrast: 0xFFE7B3,
    text_low_contrast: 0xFFCA16,
  )
}

pub fn orange() -> Scale {
  from_radix_scale(
    app_background: 0xFEFCFB,
    app_background_subtle: 0xFFF8F4,
    app_border: 0xFFC291,
    element_background: 0xFFEDD5,
    element_background_hover: 0xFFE0BB,
    element_background_strong: 0xFFD3A4,
    element_border_subtle: 0xED8A5C,
    element_border_strong: 0xFFAA7D,
    solid_background: 0xF76808,
    solid_background_hover: 0xED5F00,
    text_high_contrast: 0x582D1D,
    text_low_contrast: 0x99543A,
  )
}

pub fn orange_dark() -> Scale {
  from_radix_scale(
    app_background: 0x17120E,
    app_background_subtle: 0x1E160F,
    app_border: 0x66350C,
    element_background: 0x331E0B,
    element_background_hover: 0x462100,
    element_background_strong: 0x562800,
    element_border_subtle: 0x7E451D,
    element_border_strong: 0xA35829,
    solid_background: 0xF76B15,
    solid_background_hover: 0xFF801F,
    text_high_contrast: 0xFFE0C2,
    text_low_contrast: 0xFFA057,
  )
}

pub fn tomato() -> Scale {
  from_radix_scale(
    app_background: 0xFFFCFC,
    app_background_subtle: 0xFFF8F7,
    app_border: 0xFAC7BE,
    element_background: 0xFFF0EE,
    element_background_hover: 0xFFE6E2,
    element_background_strong: 0xFDD8D3,
    element_border_subtle: 0xEA9280,
    element_border_strong: 0xF3B0A2,
    solid_background: 0xE54D2E,
    solid_background_hover: 0xD84224,
    text_high_contrast: 0x5C271F,
    text_low_contrast: 0xC33113,
  )
}

pub fn tomato_dark() -> Scale {
  from_radix_scale(
    app_background: 0x181111,
    app_background_subtle: 0x1F1513,
    app_border: 0x6E2920,
    element_background: 0x391714,
    element_background_hover: 0x4E1511,
    element_background_strong: 0x5E1C16,
    element_border_subtle: 0x853A2D,
    element_border_strong: 0xAC4D39,
    solid_background: 0xE54D2E,
    solid_background_hover: 0xEC6142,
    text_high_contrast: 0xFBD3CB,
    text_low_contrast: 0xFF977D,
  )
}

pub fn red() -> Scale {
  from_radix_scale(
    app_background: 0xFFFCFC,
    app_background_subtle: 0xFFF7F7,
    app_border: 0xF9C6C6,
    element_background: 0xFFEFEF,
    element_background_hover: 0xFFE5E5,
    element_background_strong: 0xFDD8D8,
    element_border_subtle: 0xEB9091,
    element_border_strong: 0xF3AEAF,
    solid_background: 0xE5484D,
    solid_background_hover: 0xD93D42,
    text_high_contrast: 0x641723,
    text_low_contrast: 0xC62A2F,
  )
}

pub fn red_dark() -> Scale {
  from_radix_scale(
    app_background: 0x191111,
    app_background_subtle: 0x201314,
    app_border: 0x72232D,
    element_background: 0x3B1219,
    element_background_hover: 0x500F1C,
    element_background_strong: 0x611623,
    element_border_subtle: 0x8C333A,
    element_border_strong: 0xB54548,
    solid_background: 0xE5484D,
    solid_background_hover: 0xEC5D5E,
    text_high_contrast: 0xFFD1D9,
    text_low_contrast: 0xFF9592,
  )
}

pub fn ruby() -> Scale {
  from_radix_scale(
    app_background: 0xFFFCFD,
    app_background_subtle: 0xFFF7F9,
    app_border: 0xF5C7D1,
    element_background: 0xFEEFF3,
    element_background_hover: 0xFDE5EA,
    element_background_strong: 0xFAD8E0,
    element_border_subtle: 0xE592A2,
    element_border_strong: 0xEEAFBC,
    solid_background: 0xE54666,
    solid_background_hover: 0xDA3A5C,
    text_high_contrast: 0x64172B,
    text_low_contrast: 0xCA244D,
  )
}

pub fn ruby_dark() -> Scale {
  from_radix_scale(
    app_background: 0x191113,
    app_background_subtle: 0x1E1517,
    app_border: 0x6F2539,
    element_background: 0x3A141E,
    element_background_hover: 0x4E1325,
    element_background_strong: 0x5E1A2E,
    element_border_subtle: 0x883447,
    element_border_strong: 0xB3445A,
    solid_background: 0xE54666,
    solid_background_hover: 0xEC5A72,
    text_high_contrast: 0xFED2E1,
    text_low_contrast: 0xFF949D,
  )
}

pub fn crimson() -> Scale {
  from_radix_scale(
    app_background: 0xFFFCFD,
    app_background_subtle: 0xFFF7FB,
    app_border: 0xF4C6DB,
    element_background: 0xFEEFF6,
    element_background_hover: 0xFCE5F0,
    element_background_strong: 0xF9D8E7,
    element_border_subtle: 0xE58FB1,
    element_border_strong: 0xEDADC8,
    solid_background: 0xE93D82,
    solid_background_hover: 0xDC3175,
    text_high_contrast: 0x621639,
    text_low_contrast: 0xCB1D63,
  )
}

pub fn crimson_dark() -> Scale {
  from_radix_scale(
    app_background: 0x191114,
    app_background_subtle: 0x201318,
    app_border: 0x6D2545,
    element_background: 0x381525,
    element_background_hover: 0x4D122F,
    element_background_strong: 0x5C1839,
    element_border_subtle: 0x873356,
    element_border_strong: 0xB0436E,
    solid_background: 0xE93D82,
    solid_background_hover: 0xEE518A,
    text_high_contrast: 0xFDD3E8,
    text_low_contrast: 0xFF92AD,
  )
}

pub fn pink() -> Scale {
  from_radix_scale(
    app_background: 0xFFFCFE,
    app_background_subtle: 0xFFF7FC,
    app_border: 0xF3C6E2,
    element_background: 0xFEEEF8,
    element_background_hover: 0xFCE5F3,
    element_background_strong: 0xF9D8EC,
    element_border_subtle: 0xE38EC3,
    element_border_strong: 0xECADD4,
    solid_background: 0xD6409F,
    solid_background_hover: 0xCD3093,
    text_high_contrast: 0x651249,
    text_low_contrast: 0xC41C87,
  )
}

pub fn pink_dark() -> Scale {
  from_radix_scale(
    app_background: 0x191117,
    app_background_subtle: 0x21121D,
    app_border: 0x692955,
    element_background: 0x37172F,
    element_background_hover: 0x4B143D,
    element_background_strong: 0x591C47,
    element_border_subtle: 0x833869,
    element_border_strong: 0xA84885,
    solid_background: 0xD6409F,
    solid_background_hover: 0xDE51A8,
    text_high_contrast: 0xFDD1EA,
    text_low_contrast: 0xFF8DCC,
  )
}

pub fn plum() -> Scale {
  from_radix_scale(
    app_background: 0xFEFCFF,
    app_background_subtle: 0xFFF8FF,
    app_border: 0xEBC8ED,
    element_background: 0xFCEFFC,
    element_background_hover: 0xF9E5F9,
    element_background_strong: 0xF3D9F4,
    element_border_subtle: 0xCF91D8,
    element_border_strong: 0xDFAFE3,
    solid_background: 0xAB4ABA,
    solid_background_hover: 0xA43CB4,
    text_high_contrast: 0x53195D,
    text_low_contrast: 0x9C2BAD,
  )
}

pub fn plum_dark() -> Scale {
  from_radix_scale(
    app_background: 0x181118,
    app_background_subtle: 0x201320,
    app_border: 0x5E3061,
    element_background: 0x351A35,
    element_background_hover: 0x451D47,
    element_background_strong: 0x512454,
    element_border_subtle: 0x734079,
    element_border_strong: 0x92549C,
    solid_background: 0xAB4ABA,
    solid_background_hover: 0xB658C4,
    text_high_contrast: 0xF4D4F4,
    text_low_contrast: 0xE796F3,
  )
}

pub fn purple() -> Scale {
  from_radix_scale(
    app_background: 0xFEFCFE,
    app_background_subtle: 0xFDFAFF,
    app_border: 0xE3CCF4,
    element_background: 0xF9F1FE,
    element_background_hover: 0xF3E7FC,
    element_background_strong: 0xEDDBF9,
    element_border_subtle: 0xBE93E4,
    element_border_strong: 0xD3B4ED,
    solid_background: 0x8E4EC6,
    solid_background_hover: 0x8445BC,
    text_high_contrast: 0x402060,
    text_low_contrast: 0x793AAF,
  )
}

pub fn purple_dark() -> Scale {
  from_radix_scale(
    app_background: 0x18111B,
    app_background_subtle: 0x1E1523,
    app_border: 0x54346B,
    element_background: 0x301C3B,
    element_background_hover: 0x3D224E,
    element_background_strong: 0x48295C,
    element_border_subtle: 0x664282,
    element_border_strong: 0x8457AA,
    solid_background: 0x8E4EC6,
    solid_background_hover: 0x9A5CD0,
    text_high_contrast: 0xECD9FA,
    text_low_contrast: 0xD19DFF,
  )
}

pub fn violet() -> Scale {
  from_radix_scale(
    app_background: 0xFDFCFE,
    app_background_subtle: 0xFBFAFF,
    app_border: 0xD7CFF9,
    element_background: 0xF5F2FF,
    element_background_hover: 0xEDE9FE,
    element_background_strong: 0xE4DEFC,
    element_border_subtle: 0xAA99EC,
    element_border_strong: 0xC4B8F3,
    solid_background: 0x6E56CF,
    solid_background_hover: 0x644FC1,
    text_high_contrast: 0x2F265F,
    text_low_contrast: 0x5746AF,
  )
}

pub fn violet_dark() -> Scale {
  from_radix_scale(
    app_background: 0x14121F,
    app_background_subtle: 0x1B1525,
    app_border: 0x473876,
    element_background: 0x291F43,
    element_background_hover: 0x33255B,
    element_background_strong: 0x3C2E69,
    element_border_subtle: 0x56468B,
    element_border_strong: 0x6958AD,
    solid_background: 0x6E56CF,
    solid_background_hover: 0x7D66D9,
    text_high_contrast: 0xE2DDFE,
    text_low_contrast: 0xBAA7FF,
  )
}

pub fn iris() -> Scale {
  from_radix_scale(
    app_background: 0xFDFDFF,
    app_background_subtle: 0xFAFAFF,
    app_border: 0xD0D0FA,
    element_background: 0xF3F3FF,
    element_background_hover: 0xEBEBFE,
    element_background_strong: 0xE0E0FD,
    element_border_subtle: 0x9B9EF0,
    element_border_strong: 0xBABBF5,
    solid_background: 0x5B5BD6,
    solid_background_hover: 0x5353CE,
    text_high_contrast: 0x272962,
    text_low_contrast: 0x4747C2,
  )
}

pub fn iris_dark() -> Scale {
  from_radix_scale(
    app_background: 0x13131E,
    app_background_subtle: 0x171625,
    app_border: 0x3D3E82,
    element_background: 0x202248,
    element_background_hover: 0x262A65,
    element_background_strong: 0x303374,
    element_border_subtle: 0x4A4A95,
    element_border_strong: 0x5958B1,
    solid_background: 0x5B5BD6,
    solid_background_hover: 0x6E6ADE,
    text_high_contrast: 0xE0DFFE,
    text_low_contrast: 0xB1A9FF,
  )
}

pub fn indigo() -> Scale {
  from_radix_scale(
    app_background: 0xFDFDFE,
    app_background_subtle: 0xF8FAFF,
    app_border: 0xC6D4F9,
    element_background: 0xF0F4FF,
    element_background_hover: 0xE6EDFE,
    element_background_strong: 0xD9E2FC,
    element_border_subtle: 0x8DA4EF,
    element_border_strong: 0xAEC0F5,
    solid_background: 0x3E63DD,
    solid_background_hover: 0x3A5CCC,
    text_high_contrast: 0x1F2D5C,
    text_low_contrast: 0x3451B2,
  )
}

pub fn indigo_dark() -> Scale {
  from_radix_scale(
    app_background: 0x11131F,
    app_background_subtle: 0x141726,
    app_border: 0x304384,
    element_background: 0x182449,
    element_background_hover: 0x1D2E62,
    element_background_strong: 0x253974,
    element_border_subtle: 0x3A4F97,
    element_border_strong: 0x435DB1,
    solid_background: 0x3E63DD,
    solid_background_hover: 0x5472E4,
    text_high_contrast: 0xD6E1FF,
    text_low_contrast: 0x9EB1FF,
  )
}

pub fn blue() -> Scale {
  from_radix_scale(
    app_background: 0xFBFDFF,
    app_background_subtle: 0xF5FAFF,
    app_border: 0xB7D9F8,
    element_background: 0xEDF6FF,
    element_background_hover: 0xE1F0FF,
    element_background_strong: 0xCEE7FE,
    element_border_subtle: 0x5EB0EF,
    element_border_strong: 0x96C7F2,
    solid_background: 0x0091FF,
    solid_background_hover: 0x0880EA,
    text_high_contrast: 0x113264,
    text_low_contrast: 0x0B68CB,
  )
}

pub fn blue_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0D1520,
    app_background_subtle: 0x111927,
    app_border: 0x104D87,
    element_background: 0x0D2847,
    element_background_hover: 0x003362,
    element_background_strong: 0x004074,
    element_border_subtle: 0x205D9E,
    element_border_strong: 0x2870BD,
    solid_background: 0x0090FF,
    solid_background_hover: 0x3B9EFF,
    text_high_contrast: 0xC2E6FF,
    text_low_contrast: 0x70B8FF,
  )
}

pub fn cyan() -> Scale {
  from_radix_scale(
    app_background: 0xFAFDFE,
    app_background_subtle: 0xF2FCFD,
    app_border: 0xAADEE6,
    element_background: 0xE7F9FB,
    element_background_hover: 0xD8F3F6,
    element_background_strong: 0xC4EAEF,
    element_border_subtle: 0x3DB9CF,
    element_border_strong: 0x84CDDA,
    solid_background: 0x05A2C2,
    solid_background_hover: 0x0894B3,
    text_high_contrast: 0x0D3C48,
    text_low_contrast: 0x0C7792,
  )
}

pub fn cyan_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0B161A,
    app_background_subtle: 0x101B20,
    app_border: 0x045468,
    element_background: 0x082C36,
    element_background_hover: 0x003848,
    element_background_strong: 0x004558,
    element_border_subtle: 0x12677E,
    element_border_strong: 0x11809C,
    solid_background: 0x00A2C7,
    solid_background_hover: 0x23AFD0,
    text_high_contrast: 0xB6ECF7,
    text_low_contrast: 0x4CCCE6,
  )
}

pub fn teal() -> Scale {
  from_radix_scale(
    app_background: 0xFAFEFD,
    app_background_subtle: 0xF1FCFA,
    app_border: 0xAFDFD7,
    element_background: 0xE7F9F5,
    element_background_hover: 0xD9F3EE,
    element_background_strong: 0xC7EBE5,
    element_border_subtle: 0x53B9AB,
    element_border_strong: 0x8DCEC3,
    solid_background: 0x12A594,
    solid_background_hover: 0x0E9888,
    text_high_contrast: 0x0D3D38,
    text_low_contrast: 0x067A6F,
  )
}

pub fn teal_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0D1514,
    app_background_subtle: 0x111C1B,
    app_border: 0x145750,
    element_background: 0x0D2D2A,
    element_background_hover: 0x023B37,
    element_background_strong: 0x084843,
    element_border_subtle: 0x1C6961,
    element_border_strong: 0x207E73,
    solid_background: 0x12A594,
    solid_background_hover: 0x0EB39E,
    text_high_contrast: 0xADF0DD,
    text_low_contrast: 0x0BD8B6,
  )
}

pub fn jade() -> Scale {
  from_radix_scale(
    app_background: 0xFBFEFD,
    app_background_subtle: 0xEFFDF6,
    app_border: 0xB0E0CC,
    element_background: 0xE4FAEF,
    element_background_hover: 0xD7F4E6,
    element_background_strong: 0xC6ECDB,
    element_border_subtle: 0x56BA9F,
    element_border_strong: 0x8FCFB9,
    solid_background: 0x29A383,
    solid_background_hover: 0x259678,
    text_high_contrast: 0x1D3B31,
    text_low_contrast: 0x1A7A5E,
  )
}

pub fn jade_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0D1512,
    app_background_subtle: 0x121C18,
    app_border: 0x1B5745,
    element_background: 0x0F2E22,
    element_background_hover: 0x0B3B2C,
    element_background_strong: 0x114837,
    element_border_subtle: 0x246854,
    element_border_strong: 0x2A7E68,
    solid_background: 0x29A383,
    solid_background_hover: 0x27B08B,
    text_high_contrast: 0xADF0D4,
    text_low_contrast: 0x1FD8A4,
  )
}

pub fn green() -> Scale {
  from_radix_scale(
    app_background: 0xFBFEFC,
    app_background_subtle: 0xF2FCF5,
    app_border: 0xB4DFC4,
    element_background: 0xE9F9EE,
    element_background_hover: 0xDDF3E4,
    element_background_strong: 0xCCEBD7,
    element_border_subtle: 0x5BB98C,
    element_border_strong: 0x92CEAC,
    solid_background: 0x30A46C,
    solid_background_hover: 0x299764,
    text_high_contrast: 0x193B2D,
    text_low_contrast: 0x18794E,
  )
}

pub fn green_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0E1512,
    app_background_subtle: 0x121B17,
    app_border: 0x20573E,
    element_background: 0x132D21,
    element_background_hover: 0x113B29,
    element_background_strong: 0x174933,
    element_border_subtle: 0x28684A,
    element_border_strong: 0x2F7C57,
    solid_background: 0x30A46C,
    solid_background_hover: 0x33B074,
    text_high_contrast: 0xB1F1CB,
    text_low_contrast: 0x3DD68C,
  )
}

pub fn grass() -> Scale {
  from_radix_scale(
    app_background: 0xFBFEFB,
    app_background_subtle: 0xF3FCF3,
    app_border: 0xB7DFBA,
    element_background: 0xEBF9EB,
    element_background_hover: 0xDFF3DF,
    element_background_strong: 0xCEEBCF,
    element_border_subtle: 0x65BA75,
    element_border_strong: 0x97CF9C,
    solid_background: 0x46A758,
    solid_background_hover: 0x3D9A50,
    text_high_contrast: 0x203C25,
    text_low_contrast: 0x297C3B,
  )
}

pub fn grass_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0E1511,
    app_background_subtle: 0x141A15,
    app_border: 0x2D5736,
    element_background: 0x1B2A1E,
    element_background_hover: 0x1D3A24,
    element_background_strong: 0x25482D,
    element_border_subtle: 0x366740,
    element_border_strong: 0x3E7949,
    solid_background: 0x46A758,
    solid_background_hover: 0x53B365,
    text_high_contrast: 0xC2F0C2,
    text_low_contrast: 0x71D083,
  )
}

pub fn lime() -> Scale {
  from_radix_scale(
    app_background: 0xFCFDFA,
    app_background_subtle: 0xF7FCF0,
    app_border: 0xC6DE99,
    element_background: 0xEDFADA,
    element_background_hover: 0xE2F5C4,
    element_background_strong: 0xD5EDAF,
    element_border_subtle: 0x9AB654,
    element_border_strong: 0xB2CA7F,
    solid_background: 0xBDEE63,
    solid_background_hover: 0xB0E64C,
    text_high_contrast: 0x37401C,
    text_low_contrast: 0x59682C,
  )
}

pub fn lime_dark() -> Scale {
  from_radix_scale(
    app_background: 0x11130C,
    app_background_subtle: 0x151A10,
    app_border: 0x3D522A,
    element_background: 0x1F2917,
    element_background_hover: 0x29371D,
    element_background_strong: 0x334423,
    element_border_subtle: 0x496231,
    element_border_strong: 0x577538,
    solid_background: 0xBDEE63,
    solid_background_hover: 0xD4FF70,
    text_high_contrast: 0xE3F7BA,
    text_low_contrast: 0xBDE56C,
  )
}

pub fn mint() -> Scale {
  from_radix_scale(
    app_background: 0xF9FEFD,
    app_background_subtle: 0xEFFEFA,
    app_border: 0xA6E1D3,
    element_background: 0xDDFBF3,
    element_background_hover: 0xCCF7EC,
    element_background_strong: 0xBBEEE2,
    element_border_subtle: 0x51BDA7,
    element_border_strong: 0x87D0BF,
    solid_background: 0x86EAD4,
    solid_background_hover: 0x7FE1CC,
    text_high_contrast: 0x16433C,
    text_low_contrast: 0x27756A,
  )
}

pub fn mint_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0E1515,
    app_background_subtle: 0x0F1B1B,
    app_border: 0x105650,
    element_background: 0x092C2B,
    element_background_hover: 0x003A38,
    element_background_strong: 0x004744,
    element_border_subtle: 0x1E685F,
    element_border_strong: 0x277F70,
    solid_background: 0x86EAD4,
    solid_background_hover: 0xA8F5E5,
    text_high_contrast: 0xC4F5E1,
    text_low_contrast: 0x58D5BA,
  )
}

pub fn sky() -> Scale {
  from_radix_scale(
    app_background: 0xF9FEFF,
    app_background_subtle: 0xF1FCFF,
    app_border: 0xA5DCED,
    element_background: 0xE2F9FF,
    element_background_hover: 0xD2F4FD,
    element_background_strong: 0xBFEBF8,
    element_border_subtle: 0x46B8D8,
    element_border_strong: 0x82CAE0,
    solid_background: 0x7CE2FE,
    solid_background_hover: 0x72DBF8,
    text_high_contrast: 0x19404D,
    text_low_contrast: 0x256E93,
  )
}

pub fn sky_dark() -> Scale {
  from_radix_scale(
    app_background: 0x0D141F,
    app_background_subtle: 0x111A27,
    app_border: 0x1B537B,
    element_background: 0x112840,
    element_background_hover: 0x113555,
    element_background_strong: 0x154467,
    element_border_subtle: 0x1F6692,
    element_border_strong: 0x197CAE,
    solid_background: 0x7CE2FE,
    solid_background_hover: 0xA8EEFF,
    text_high_contrast: 0xC2F3FF,
    text_low_contrast: 0x75C7F0,
  )
}
