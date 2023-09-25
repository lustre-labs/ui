// IMPORTS ---------------------------------------------------------------------

import gleam_community/colour.{Colour}

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
    app_background: 0xfcfcfc,
    app_background_subtle: 0xf9f9f9,
    app_border: 0xdddddd,
    element_background: 0xf1f1f1,
    element_background_hover: 0xebebeb,
    element_background_strong: 0xe4e4e4,
    element_border_subtle: 0xbbbbbb,
    element_border_strong: 0xd4d4d4,
    solid_background: 0x8d8d8d,
    solid_background_hover: 0x808080,
    text_high_contrast: 0x202020,
    text_low_contrast: 0x646464,
  )
}

pub fn mauve() -> Scale {
  from_radix_scale(
    app_background: 0xfdfcfd,
    app_background_subtle: 0xfaf9fb,
    app_border: 0xdfdce3,
    element_background: 0xf3f1f5,
    element_background_hover: 0xeceaef,
    element_background_strong: 0xe6e3e9,
    element_border_subtle: 0xbcbac7,
    element_border_strong: 0xd5d3db,
    solid_background: 0x8e8c99,
    solid_background_hover: 0x817f8b,
    text_high_contrast: 0x211f26,
    text_low_contrast: 0x65636d,
  )
}

pub fn slate() -> Scale {
  from_radix_scale(
    app_background: 0xfcfcfd,
    app_background_subtle: 0xf9f9fb,
    app_border: 0xdddde3,
    element_background: 0xf2f2f5,
    element_background_hover: 0xebebef,
    element_background_strong: 0xe4e4e9,
    element_border_subtle: 0xb9bbc6,
    element_border_strong: 0xd3d4db,
    solid_background: 0x8b8d98,
    solid_background_hover: 0x7e808a,
    text_high_contrast: 0x1c2024,
    text_low_contrast: 0x60646c,
  )
}

pub fn sage() -> Scale {
  from_radix_scale(
    app_background: 0xfbfdfc,
    app_background_subtle: 0xf7f9f8,
    app_border: 0xdcdfdd,
    element_background: 0xf0f2f1,
    element_background_hover: 0xe9eceb,
    element_background_strong: 0xe3e6e4,
    element_border_subtle: 0xb8bcba,
    element_border_strong: 0xd2d5d3,
    solid_background: 0x868e8b,
    solid_background_hover: 0x7a817f,
    text_high_contrast: 0x1a211e,
    text_low_contrast: 0x5f6563,
  )
}

pub fn olive() -> Scale {
  from_radix_scale(
    app_background: 0xfcfdfc,
    app_background_subtle: 0xf8faf8,
    app_border: 0xdbdedb,
    element_background: 0xf1f3f1,
    element_background_hover: 0xeaecea,
    element_background_strong: 0xe3e5e3,
    element_border_subtle: 0xb9bcb8,
    element_border_strong: 0xd2d4d1,
    solid_background: 0x898e87,
    solid_background_hover: 0x7c817b,
    text_high_contrast: 0x1d211c,
    text_low_contrast: 0x60655f,
  )
}

pub fn sand() -> Scale {
  from_radix_scale(
    app_background: 0xfdfdfc,
    app_background_subtle: 0xf9f9f8,
    app_border: 0xddddda,
    element_background: 0xf2f2f0,
    element_background_hover: 0xebebe9,
    element_background_strong: 0xe4e4e2,
    element_border_subtle: 0xbcbbb5,
    element_border_strong: 0xd3d2ce,
    solid_background: 0x8d8d86,
    solid_background_hover: 0x80807a,
    text_high_contrast: 0x21201c,
    text_low_contrast: 0x63635e,
  )
}

pub fn gold() -> Scale {
  from_radix_scale(
    app_background: 0xfdfdfc,
    app_background_subtle: 0xfbf9f2,
    app_border: 0xdad1bd,
    element_background: 0xf5f2e9,
    element_background_hover: 0xeeeadd,
    element_background_strong: 0xe5dfd0,
    element_border_subtle: 0xb8a383,
    element_border_strong: 0xcbbda4,
    solid_background: 0x978365,
    solid_background_hover: 0x89775c,
    text_high_contrast: 0x3b352b,
    text_low_contrast: 0x71624b,
  )
}

pub fn bronze() -> Scale {
  from_radix_scale(
    app_background: 0xfdfcfc,
    app_background_subtle: 0xfdf8f6,
    app_border: 0xe0cec7,
    element_background: 0xf8f1ee,
    element_background_hover: 0xf2e8e4,
    element_background_strong: 0xeaddd7,
    element_border_subtle: 0xbfa094,
    element_border_strong: 0xd1b9b0,
    solid_background: 0xa18072,
    solid_background_hover: 0x947467,
    text_high_contrast: 0x43302b,
    text_low_contrast: 0x7d5e54,
  )
}

pub fn brown() -> Scale {
  from_radix_scale(
    app_background: 0xfefdfc,
    app_background_subtle: 0xfcf9f6,
    app_border: 0xe8cdb5,
    element_background: 0xf8f1ea,
    element_background_hover: 0xf4e9dd,
    element_background_strong: 0xefddcc,
    element_border_subtle: 0xd09e72,
    element_border_strong: 0xddb896,
    solid_background: 0xad7f58,
    solid_background_hover: 0x9e7352,
    text_high_contrast: 0x3e332e,
    text_low_contrast: 0x815e46,
  )
}

pub fn yellow() -> Scale {
  from_radix_scale(
    app_background: 0xfdfdf9,
    app_background_subtle: 0xfffbe0,
    app_border: 0xecdd85,
    element_background: 0xfff8c6,
    element_background_hover: 0xfcf3af,
    element_background_strong: 0xf7ea9b,
    element_border_subtle: 0xc9aa45,
    element_border_strong: 0xdac56e,
    solid_background: 0xfbe32d,
    solid_background_hover: 0xf9da10,
    text_high_contrast: 0x473b1f,
    text_low_contrast: 0x775f28,
  )
}

pub fn amber() -> Scale {
  from_radix_scale(
    app_background: 0xfefdfb,
    app_background_subtle: 0xfff9ed,
    app_border: 0xf5d08c,
    element_background: 0xfff3d0,
    element_background_hover: 0xffecb7,
    element_background_strong: 0xffe0a1,
    element_border_subtle: 0xd6a35c,
    element_border_strong: 0xe4bb78,
    solid_background: 0xffc53d,
    solid_background_hover: 0xffba1a,
    text_high_contrast: 0x4f3422,
    text_low_contrast: 0x915930,
  )
}

pub fn orange() -> Scale {
  from_radix_scale(
    app_background: 0xfefcfb,
    app_background_subtle: 0xfff8f4,
    app_border: 0xffc291,
    element_background: 0xffedd5,
    element_background_hover: 0xffe0bb,
    element_background_strong: 0xffd3a4,
    element_border_subtle: 0xed8a5c,
    element_border_strong: 0xffaa7d,
    solid_background: 0xf76808,
    solid_background_hover: 0xed5f00,
    text_high_contrast: 0x582d1d,
    text_low_contrast: 0x99543a,
  )
}

pub fn tomato() -> Scale {
  from_radix_scale(
    app_background: 0xfffcfc,
    app_background_subtle: 0xfff8f7,
    app_border: 0xfac7be,
    element_background: 0xfff0ee,
    element_background_hover: 0xffe6e2,
    element_background_strong: 0xfdd8d3,
    element_border_subtle: 0xea9280,
    element_border_strong: 0xf3b0a2,
    solid_background: 0xe54d2e,
    solid_background_hover: 0xd84224,
    text_high_contrast: 0x5c271f,
    text_low_contrast: 0xc33113,
  )
}

pub fn red() -> Scale {
  from_radix_scale(
    app_background: 0xfffcfc,
    app_background_subtle: 0xfff7f7,
    app_border: 0xf9c6c6,
    element_background: 0xffefef,
    element_background_hover: 0xffe5e5,
    element_background_strong: 0xfdd8d8,
    element_border_subtle: 0xeb9091,
    element_border_strong: 0xf3aeaf,
    solid_background: 0xe5484d,
    solid_background_hover: 0xd93d42,
    text_high_contrast: 0x641723,
    text_low_contrast: 0xc62a2f,
  )
}

pub fn ruby() -> Scale {
  from_radix_scale(
    app_background: 0xfffcfd,
    app_background_subtle: 0xfff7f9,
    app_border: 0xf5c7d1,
    element_background: 0xfeeff3,
    element_background_hover: 0xfde5ea,
    element_background_strong: 0xfad8e0,
    element_border_subtle: 0xe592a2,
    element_border_strong: 0xeeafbc,
    solid_background: 0xe54666,
    solid_background_hover: 0xda3a5c,
    text_high_contrast: 0x64172b,
    text_low_contrast: 0xca244d,
  )
}

pub fn crimson() -> Scale {
  from_radix_scale(
    app_background: 0xfffcfd,
    app_background_subtle: 0xfff7fb,
    app_border: 0xf4c6db,
    element_background: 0xfeeff6,
    element_background_hover: 0xfce5f0,
    element_background_strong: 0xf9d8e7,
    element_border_subtle: 0xe58fb1,
    element_border_strong: 0xedadc8,
    solid_background: 0xe93d82,
    solid_background_hover: 0xdc3175,
    text_high_contrast: 0x621639,
    text_low_contrast: 0xcb1d63,
  )
}

pub fn pink() -> Scale {
  from_radix_scale(
    app_background: 0xfffcfe,
    app_background_subtle: 0xfff7fc,
    app_border: 0xf3c6e2,
    element_background: 0xfeeef8,
    element_background_hover: 0xfce5f3,
    element_background_strong: 0xf9d8ec,
    element_border_subtle: 0xe38ec3,
    element_border_strong: 0xecadd4,
    solid_background: 0xd6409f,
    solid_background_hover: 0xcd3093,
    text_high_contrast: 0x651249,
    text_low_contrast: 0xc41c87,
  )
}

pub fn plum() -> Scale {
  from_radix_scale(
    app_background: 0xfefcff,
    app_background_subtle: 0xfff8ff,
    app_border: 0xebc8ed,
    element_background: 0xfceffc,
    element_background_hover: 0xf9e5f9,
    element_background_strong: 0xf3d9f4,
    element_border_subtle: 0xcf91d8,
    element_border_strong: 0xdfafe3,
    solid_background: 0xab4aba,
    solid_background_hover: 0xa43cb4,
    text_high_contrast: 0x53195d,
    text_low_contrast: 0x9c2bad,
  )
}

pub fn purple() -> Scale {
  from_radix_scale(
    app_background: 0xfefcfe,
    app_background_subtle: 0xfdfaff,
    app_border: 0xe3ccf4,
    element_background: 0xf9f1fe,
    element_background_hover: 0xf3e7fc,
    element_background_strong: 0xeddbf9,
    element_border_subtle: 0xbe93e4,
    element_border_strong: 0xd3b4ed,
    solid_background: 0x8e4ec6,
    solid_background_hover: 0x8445bc,
    text_high_contrast: 0x402060,
    text_low_contrast: 0x793aaf,
  )
}

pub fn violet() -> Scale {
  from_radix_scale(
    app_background: 0xfdfcfe,
    app_background_subtle: 0xfbfaff,
    app_border: 0xd7cff9,
    element_background: 0xf5f2ff,
    element_background_hover: 0xede9fe,
    element_background_strong: 0xe4defc,
    element_border_subtle: 0xaa99ec,
    element_border_strong: 0xc4b8f3,
    solid_background: 0x6e56cf,
    solid_background_hover: 0x644fc1,
    text_high_contrast: 0x2f265f,
    text_low_contrast: 0x5746af,
  )
}

pub fn iris() -> Scale {
  from_radix_scale(
    app_background: 0xfdfdff,
    app_background_subtle: 0xfafaff,
    app_border: 0xd0d0fa,
    element_background: 0xf3f3ff,
    element_background_hover: 0xebebfe,
    element_background_strong: 0xe0e0fd,
    element_border_subtle: 0x9b9ef0,
    element_border_strong: 0xbabbf5,
    solid_background: 0x5b5bd6,
    solid_background_hover: 0x5353ce,
    text_high_contrast: 0x272962,
    text_low_contrast: 0x4747c2,
  )
}

pub fn indigo() -> Scale {
  from_radix_scale(
    app_background: 0xfdfdfe,
    app_background_subtle: 0xf8faff,
    app_border: 0xc6d4f9,
    element_background: 0xf0f4ff,
    element_background_hover: 0xe6edfe,
    element_background_strong: 0xd9e2fc,
    element_border_subtle: 0x8da4ef,
    element_border_strong: 0xaec0f5,
    solid_background: 0x3e63dd,
    solid_background_hover: 0x3a5ccc,
    text_high_contrast: 0x1f2d5c,
    text_low_contrast: 0x3451b2,
  )
}

pub fn blue() -> Scale {
  from_radix_scale(
    app_background: 0xfbfdff,
    app_background_subtle: 0xf5faff,
    app_border: 0xb7d9f8,
    element_background: 0xedf6ff,
    element_background_hover: 0xe1f0ff,
    element_background_strong: 0xcee7fe,
    element_border_subtle: 0x5eb0ef,
    element_border_strong: 0x96c7f2,
    solid_background: 0x0091ff,
    solid_background_hover: 0x0880ea,
    text_high_contrast: 0x113264,
    text_low_contrast: 0x0b68cb,
  )
}

pub fn cyan() -> Scale {
  from_radix_scale(
    app_background: 0xfafdfe,
    app_background_subtle: 0xf2fcfd,
    app_border: 0xaadee6,
    element_background: 0xe7f9fb,
    element_background_hover: 0xd8f3f6,
    element_background_strong: 0xc4eaef,
    element_border_subtle: 0x3db9cf,
    element_border_strong: 0x84cdda,
    solid_background: 0x05a2c2,
    solid_background_hover: 0x0894b3,
    text_high_contrast: 0x0d3c48,
    text_low_contrast: 0x0c7792,
  )
}

pub fn teal() -> Scale {
  from_radix_scale(
    app_background: 0xfafefd,
    app_background_subtle: 0xf1fcfa,
    app_border: 0xafdfd7,
    element_background: 0xe7f9f5,
    element_background_hover: 0xd9f3ee,
    element_background_strong: 0xc7ebe5,
    element_border_subtle: 0x53b9ab,
    element_border_strong: 0x8dcec3,
    solid_background: 0x12a594,
    solid_background_hover: 0x0e9888,
    text_high_contrast: 0x0d3d38,
    text_low_contrast: 0x067a6f,
  )
}

pub fn jade() -> Scale {
  from_radix_scale(
    app_background: 0xfbfefd,
    app_background_subtle: 0xeffdf6,
    app_border: 0xb0e0cc,
    element_background: 0xe4faef,
    element_background_hover: 0xd7f4e6,
    element_background_strong: 0xc6ecdb,
    element_border_subtle: 0x56ba9f,
    element_border_strong: 0x8fcfb9,
    solid_background: 0x29a383,
    solid_background_hover: 0x259678,
    text_high_contrast: 0x1d3b31,
    text_low_contrast: 0x1a7a5e,
  )
}

pub fn green() -> Scale {
  from_radix_scale(
    app_background: 0xfbfefc,
    app_background_subtle: 0xf2fcf5,
    app_border: 0xb4dfc4,
    element_background: 0xe9f9ee,
    element_background_hover: 0xddf3e4,
    element_background_strong: 0xccebd7,
    element_border_subtle: 0x5bb98c,
    element_border_strong: 0x92ceac,
    solid_background: 0x30a46c,
    solid_background_hover: 0x299764,
    text_high_contrast: 0x193b2d,
    text_low_contrast: 0x18794e,
  )
}

pub fn grass() -> Scale {
  from_radix_scale(
    app_background: 0xfbfefb,
    app_background_subtle: 0xf3fcf3,
    app_border: 0xb7dfba,
    element_background: 0xebf9eb,
    element_background_hover: 0xdff3df,
    element_background_strong: 0xceebcf,
    element_border_subtle: 0x65ba75,
    element_border_strong: 0x97cf9c,
    solid_background: 0x46a758,
    solid_background_hover: 0x3d9a50,
    text_high_contrast: 0x203c25,
    text_low_contrast: 0x297c3b,
  )
}

pub fn lime() -> Scale {
  from_radix_scale(
    app_background: 0xfcfdfa,
    app_background_subtle: 0xf7fcf0,
    app_border: 0xc6de99,
    element_background: 0xedfada,
    element_background_hover: 0xe2f5c4,
    element_background_strong: 0xd5edaf,
    element_border_subtle: 0x9ab654,
    element_border_strong: 0xb2ca7f,
    solid_background: 0xbdee63,
    solid_background_hover: 0xb0e64c,
    text_high_contrast: 0x37401c,
    text_low_contrast: 0x59682c,
  )
}

pub fn mint() -> Scale {
  from_radix_scale(
    app_background: 0xf9fefd,
    app_background_subtle: 0xeffefa,
    app_border: 0xa6e1d3,
    element_background: 0xddfbf3,
    element_background_hover: 0xccf7ec,
    element_background_strong: 0xbbeee2,
    element_border_subtle: 0x51bda7,
    element_border_strong: 0x87d0bf,
    solid_background: 0x86ead4,
    solid_background_hover: 0x7fe1cc,
    text_high_contrast: 0x16433c,
    text_low_contrast: 0x27756a,
  )
}

pub fn sky() -> Scale {
  from_radix_scale(
    app_background: 0xf9feff,
    app_background_subtle: 0xf1fcff,
    app_border: 0xa5dced,
    element_background: 0xe2f9ff,
    element_background_hover: 0xd2f4fd,
    element_background_strong: 0xbfebf8,
    element_border_subtle: 0x46b8d8,
    element_border_strong: 0x82cae0,
    solid_background: 0x7ce2fe,
    solid_background_hover: 0x72dbf8,
    text_high_contrast: 0x19404d,
    text_low_contrast: 0x256e93,
  )
}
