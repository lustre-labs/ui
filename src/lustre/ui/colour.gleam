// IMPORTS ---------------------------------------------------------------------
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/result.{try}
import gleam_community/colour
import gleam_community/colour/accessibility

// TYPES -----------------------------------------------------------------------

///
///
pub type Colour =
  colour.Colour

///
///
pub type ColourPalette {
  ColourPalette(
    base: ColourScale,
    primary: ColourScale,
    secondary: ColourScale,
    success: ColourScale,
    warning: ColourScale,
    danger: ColourScale,
  )
}

///
///
pub type ColourScale {
  ColourScale(
    bg: Colour,
    bg_subtle: Colour,
    //
    tint: Colour,
    tint_subtle: Colour,
    tint_strong: Colour,
    //
    accent: Colour,
    accent_subtle: Colour,
    accent_strong: Colour,
    //
    solid: Colour,
    solid_subtle: Colour,
    solid_strong: Colour,
    solid_text: Colour,
    //
    text: Colour,
    text_subtle: Colour,
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

///
///
pub fn rgb(r: Int, g: Int, b: Int) -> Colour {
  let r = int.min(255, int.max(0, r))
  let g = int.min(255, int.max(0, g))
  let b = int.min(255, int.max(0, b))
  let assert Ok(colour) = colour.from_rgb255(r, g, b)

  colour
}

///
///
pub fn rgba(r: Int, g: Int, b: Int, a: Float) -> Colour {
  let r = int.to_float(int.min(255, int.max(0, r))) /. 255.0
  let b = int.to_float(int.min(255, int.max(0, b))) /. 255.0
  let g = int.to_float(int.min(255, int.max(0, g))) /. 255.0
  let a = float.min(1.0, float.max(0.0, a))
  let assert Ok(colour) = colour.from_rgba(r, g, b, a)

  colour
}

///
///
pub fn hsl(h: Float, s: Float, l: Float) -> Colour {
  let assert Ok(h) = float.modulo(h, by: 360.0)
  let s = float.min(1.0, float.max(0.0, s))
  let l = float.min(1.0, float.max(0.0, l))
  let assert Ok(colour) = colour.from_hsl(h, s, l)

  colour
}

// QUERIES ---------------------------------------------------------------------

///
///
pub fn luminance(colour: Colour) -> Float {
  accessibility.luminance(colour)
}

///
///
pub fn contrast_ratio(a: Colour, b: Colour) -> Float {
  accessibility.contrast_ratio(a, b)
}

///
///
pub fn maximum_contrast(base: Colour, options: List(Colour)) -> Colour {
  let assert Ok(colour) =
    accessibility.maximum_contrast(base, case options {
      [] -> [colour.white, colour.black]
      _ -> options
    })

  colour
}

// COLOUR PALETTES -------------------------------------------------------------

/// Lustre UI's default light colour palette. You can use this if you don't have
/// any strict requirements around colours and you want to start building your
/// app straight away.
///
/// This is the light mode palette used by the [default theme](./theme.html#default).
///
pub fn default_light_palette() -> ColourPalette {
  ColourPalette(
    base: slate(),
    primary: pink(),
    secondary: cyan(),
    success: green(),
    warning: yellow(),
    danger: red(),
  )
}

/// Lustre UI's default dark colour palette. You can use this if you don't have
/// any strict requirements around colours and you want to start building your
/// app straight away.
///
/// This is the dark mode palette used by the [default theme](./theme.html#default),
/// but it is not required to _only_ use this palette for dark mode!
///
pub fn default_dark_palette() -> ColourPalette {
  ColourPalette(
    base: slate_dark(),
    primary: pink_dark(),
    secondary: cyan_dark(),
    success: green_dark(),
    warning: yellow_dark(),
    danger: red_dark(),
  )
}

// JSON ------------------------------------------------------------------------

pub fn encode(scale: ColourScale) -> Json {
  json.object([
    #("bg", colour.encode(scale.bg)),
    #("bg_subtle", colour.encode(scale.bg_subtle)),
    #("tint", colour.encode(scale.tint)),
    #("tint_subtle", colour.encode(scale.tint_subtle)),
    #("tint_strong", colour.encode(scale.tint_strong)),
    #("accent", colour.encode(scale.accent)),
    #("accent_subtle", colour.encode(scale.accent_subtle)),
    #("accent_strong", colour.encode(scale.accent_strong)),
    #("solid", colour.encode(scale.solid)),
    #("solid_subtle", colour.encode(scale.solid_subtle)),
    #("solid_strong", colour.encode(scale.solid_strong)),
    #("solid_text", colour.encode(scale.solid_text)),
    #("text", colour.encode(scale.text)),
    #("text_subtle", colour.encode(scale.text_subtle)),
  ])
}

pub fn encode_palette(palette: ColourPalette) -> Json {
  json.object([
    #("base", encode(palette.base)),
    #("primary", encode(palette.primary)),
    #("secondary", encode(palette.secondary)),
    #("success", encode(palette.success)),
    #("warning", encode(palette.warning)),
    #("danger", encode(palette.danger)),
  ])
}

pub fn decoder(json: Dynamic) -> Result(ColourScale, List(DecodeError)) {
  use bg <- try(dynamic.field("bg", colour.decoder)(json))
  use bg_subtle <- try(dynamic.field("bg_subtle", colour.decoder)(json))
  use tint <- try(dynamic.field("tint", colour.decoder)(json))
  use tint_subtle <- try(dynamic.field("tint_subtle", colour.decoder)(json))
  use tint_strong <- try(dynamic.field("tint_strong", colour.decoder)(json))
  use accent <- try(dynamic.field("accent", colour.decoder)(json))
  use accent_subtle <- try(dynamic.field("accent_subtle", colour.decoder)(json))
  use accent_strong <- try(dynamic.field("accent_strong", colour.decoder)(json))
  use solid <- try(dynamic.field("solid", colour.decoder)(json))
  use solid_subtle <- try(dynamic.field("solid_subtle", colour.decoder)(json))
  use solid_strong <- try(dynamic.field("solid_strong", colour.decoder)(json))
  use solid_text <- try(dynamic.field("solid_text", colour.decoder)(json))
  use text <- try(dynamic.field("text", colour.decoder)(json))
  use text_subtle <- try(dynamic.field("text_subtle", colour.decoder)(json))

  Ok(ColourScale(
    bg:,
    bg_subtle:,
    tint:,
    tint_subtle:,
    tint_strong:,
    accent:,
    accent_subtle:,
    accent_strong:,
    solid:,
    solid_subtle:,
    solid_strong:,
    solid_text:,
    text:,
    text_subtle:,
  ))
}

pub fn palette_decoder(
  json: Dynamic,
) -> Result(ColourPalette, List(DecodeError)) {
  dynamic.decode6(
    ColourPalette,
    dynamic.field("base", decoder),
    dynamic.field("primary", decoder),
    dynamic.field("secondary", decoder),
    dynamic.field("success", decoder),
    dynamic.field("warning", decoder),
    dynamic.field("danger", decoder),
  )(json)
}

// RADIX UI --------------------------------------------------------------------

pub fn gray() -> ColourScale {
  ColourScale(
    bg: rgb(252, 252, 252),
    bg_subtle: rgb(249, 249, 249),
    tint: rgb(232, 232, 232),
    tint_subtle: rgb(240, 240, 240),
    tint_strong: rgb(224, 224, 224),
    accent: rgb(206, 206, 206),
    accent_subtle: rgb(217, 217, 217),
    accent_strong: rgb(187, 187, 187),
    solid: rgb(141, 141, 141),
    solid_subtle: rgb(151, 151, 151),
    solid_strong: rgb(131, 131, 131),
    solid_text: rgb(255, 255, 255),
    text: rgb(32, 32, 32),
    text_subtle: rgb(100, 100, 100),
  )
}

pub fn mauve() -> ColourScale {
  ColourScale(
    bg: rgb(253, 252, 253),
    bg_subtle: rgb(250, 249, 251),
    tint: rgb(234, 231, 236),
    tint_subtle: rgb(242, 239, 243),
    tint_strong: rgb(227, 223, 230),
    accent: rgb(208, 205, 215),
    accent_subtle: rgb(219, 216, 224),
    accent_strong: rgb(188, 186, 199),
    solid: rgb(142, 140, 153),
    solid_subtle: rgb(152, 150, 163),
    solid_strong: rgb(132, 130, 142),
    solid_text: rgb(255, 255, 255),
    text: rgb(33, 31, 38),
    text_subtle: rgb(101, 99, 109),
  )
}

pub fn slate() -> ColourScale {
  ColourScale(
    bg: rgb(252, 252, 253),
    bg_subtle: rgb(249, 249, 251),
    tint: rgb(232, 232, 236),
    tint_subtle: rgb(240, 240, 243),
    tint_strong: rgb(224, 225, 230),
    accent: rgb(205, 206, 214),
    accent_subtle: rgb(217, 217, 224),
    accent_strong: rgb(185, 187, 198),
    solid: rgb(139, 141, 152),
    solid_subtle: rgb(150, 152, 162),
    solid_strong: rgb(128, 131, 141),
    solid_text: rgb(255, 255, 255),
    text: rgb(28, 32, 36),
    text_subtle: rgb(96, 100, 108),
  )
}

pub fn sage() -> ColourScale {
  ColourScale(
    bg: rgb(251, 253, 252),
    bg_subtle: rgb(247, 249, 248),
    tint: rgb(230, 233, 232),
    tint_subtle: rgb(238, 241, 240),
    tint_strong: rgb(223, 226, 224),
    accent: rgb(203, 207, 205),
    accent_subtle: rgb(215, 218, 217),
    accent_strong: rgb(184, 188, 186),
    solid: rgb(134, 142, 139),
    solid_subtle: rgb(144, 151, 148),
    solid_strong: rgb(124, 132, 129),
    solid_text: rgb(255, 255, 255),
    text: rgb(26, 33, 30),
    text_subtle: rgb(95, 101, 99),
  )
}

pub fn olive() -> ColourScale {
  ColourScale(
    bg: rgb(252, 253, 252),
    bg_subtle: rgb(248, 250, 248),
    tint: rgb(231, 233, 231),
    tint_subtle: rgb(239, 241, 239),
    tint_strong: rgb(223, 226, 223),
    accent: rgb(204, 207, 204),
    accent_subtle: rgb(215, 218, 215),
    accent_strong: rgb(185, 188, 184),
    solid: rgb(137, 142, 135),
    solid_subtle: rgb(147, 151, 145),
    solid_strong: rgb(127, 132, 125),
    solid_text: rgb(255, 255, 255),
    text: rgb(29, 33, 28),
    text_subtle: rgb(96, 101, 95),
  )
}

pub fn sand() -> ColourScale {
  ColourScale(
    bg: rgb(253, 253, 252),
    bg_subtle: rgb(249, 249, 248),
    tint: rgb(233, 232, 230),
    tint_subtle: rgb(241, 240, 239),
    tint_strong: rgb(226, 225, 222),
    accent: rgb(207, 206, 202),
    accent_subtle: rgb(218, 217, 214),
    accent_strong: rgb(188, 187, 181),
    solid: rgb(141, 141, 134),
    solid_subtle: rgb(151, 151, 144),
    solid_strong: rgb(130, 130, 124),
    solid_text: rgb(255, 255, 255),
    text: rgb(33, 32, 28),
    text_subtle: rgb(99, 99, 94),
  )
}

pub fn tomato() -> ColourScale {
  ColourScale(
    bg: rgb(255, 252, 252),
    bg_subtle: rgb(255, 248, 247),
    tint: rgb(255, 220, 211),
    tint_subtle: rgb(254, 235, 231),
    tint_strong: rgb(255, 205, 194),
    accent: rgb(245, 168, 152),
    accent_subtle: rgb(253, 189, 175),
    accent_strong: rgb(236, 142, 123),
    solid: rgb(229, 77, 46),
    solid_subtle: rgb(236, 86, 55),
    solid_strong: rgb(221, 68, 37),
    solid_text: rgb(255, 255, 255),
    text: rgb(92, 39, 31),
    text_subtle: rgb(209, 52, 21),
  )
}

pub fn red() -> ColourScale {
  ColourScale(
    bg: rgb(255, 252, 252),
    bg_subtle: rgb(255, 247, 247),
    tint: rgb(255, 219, 220),
    tint_subtle: rgb(254, 235, 236),
    tint_strong: rgb(255, 205, 206),
    accent: rgb(244, 169, 170),
    accent_subtle: rgb(253, 189, 190),
    accent_strong: rgb(235, 142, 144),
    solid: rgb(229, 72, 77),
    solid_subtle: rgb(236, 83, 88),
    solid_strong: rgb(220, 62, 66),
    solid_text: rgb(255, 255, 255),
    text: rgb(100, 23, 35),
    text_subtle: rgb(206, 44, 49),
  )
}

pub fn ruby() -> ColourScale {
  ColourScale(
    bg: rgb(255, 252, 253),
    bg_subtle: rgb(255, 247, 248),
    tint: rgb(255, 220, 225),
    tint_subtle: rgb(254, 234, 237),
    tint_strong: rgb(255, 206, 214),
    accent: rgb(239, 172, 184),
    accent_subtle: rgb(248, 191, 200),
    accent_strong: rgb(229, 146, 163),
    solid: rgb(229, 70, 102),
    solid_subtle: rgb(236, 82, 113),
    solid_strong: rgb(220, 59, 93),
    solid_text: rgb(255, 255, 255),
    text: rgb(100, 23, 43),
    text_subtle: rgb(202, 36, 77),
  )
}

pub fn crimson() -> ColourScale {
  ColourScale(
    bg: rgb(255, 252, 253),
    bg_subtle: rgb(254, 247, 249),
    tint: rgb(254, 220, 231),
    tint_subtle: rgb(255, 233, 240),
    tint_strong: rgb(250, 206, 221),
    accent: rgb(234, 172, 195),
    accent_subtle: rgb(243, 190, 209),
    accent_strong: rgb(224, 147, 178),
    solid: rgb(233, 61, 130),
    solid_subtle: rgb(241, 71, 139),
    solid_strong: rgb(223, 52, 120),
    solid_text: rgb(255, 255, 255),
    text: rgb(98, 22, 57),
    text_subtle: rgb(203, 29, 99),
  )
}

pub fn pink() -> ColourScale {
  ColourScale(
    bg: rgb(255, 252, 254),
    bg_subtle: rgb(254, 247, 251),
    tint: rgb(251, 220, 239),
    tint_subtle: rgb(254, 233, 245),
    tint_strong: rgb(246, 206, 231),
    accent: rgb(231, 172, 208),
    accent_subtle: rgb(239, 191, 221),
    accent_strong: rgb(221, 147, 194),
    solid: rgb(214, 64, 159),
    solid_subtle: rgb(220, 72, 166),
    solid_strong: rgb(207, 56, 151),
    solid_text: rgb(255, 255, 255),
    text: rgb(101, 18, 73),
    text_subtle: rgb(194, 41, 138),
  )
}

pub fn plum() -> ColourScale {
  ColourScale(
    bg: rgb(254, 252, 255),
    bg_subtle: rgb(253, 247, 253),
    tint: rgb(247, 222, 248),
    tint_subtle: rgb(251, 235, 251),
    tint_strong: rgb(242, 209, 243),
    accent: rgb(222, 173, 227),
    accent_subtle: rgb(233, 194, 236),
    accent_strong: rgb(207, 145, 216),
    solid: rgb(171, 74, 186),
    solid_subtle: rgb(177, 85, 191),
    solid_strong: rgb(161, 68, 175),
    solid_text: rgb(255, 255, 255),
    text: rgb(83, 25, 93),
    text_subtle: rgb(149, 62, 163),
  )
}

pub fn purple() -> ColourScale {
  ColourScale(
    bg: rgb(254, 252, 254),
    bg_subtle: rgb(251, 247, 254),
    tint: rgb(242, 226, 252),
    tint_subtle: rgb(247, 237, 254),
    tint_strong: rgb(234, 213, 249),
    accent: rgb(209, 175, 236),
    accent_subtle: rgb(224, 196, 244),
    accent_strong: rgb(190, 147, 228),
    solid: rgb(142, 78, 198),
    solid_subtle: rgb(152, 86, 209),
    solid_strong: rgb(131, 71, 185),
    solid_text: rgb(255, 255, 255),
    text: rgb(64, 32, 96),
    text_subtle: rgb(129, 69, 181),
  )
}

pub fn violet() -> ColourScale {
  ColourScale(
    bg: rgb(253, 252, 254),
    bg_subtle: rgb(250, 248, 255),
    tint: rgb(235, 228, 255),
    tint_subtle: rgb(244, 240, 254),
    tint_strong: rgb(225, 217, 255),
    accent: rgb(194, 181, 245),
    accent_subtle: rgb(212, 202, 254),
    accent_strong: rgb(170, 153, 236),
    solid: rgb(110, 86, 207),
    solid_subtle: rgb(120, 96, 216),
    solid_strong: rgb(101, 77, 196),
    solid_text: rgb(255, 255, 255),
    text: rgb(47, 38, 95),
    text_subtle: rgb(101, 80, 185),
  )
}

pub fn iris() -> ColourScale {
  ColourScale(
    bg: rgb(253, 253, 255),
    bg_subtle: rgb(248, 248, 255),
    tint: rgb(230, 231, 255),
    tint_subtle: rgb(240, 241, 254),
    tint_strong: rgb(218, 220, 255),
    accent: rgb(184, 186, 248),
    accent_subtle: rgb(203, 205, 255),
    accent_strong: rgb(155, 158, 240),
    solid: rgb(91, 91, 214),
    solid_subtle: rgb(101, 101, 222),
    solid_strong: rgb(81, 81, 205),
    solid_text: rgb(255, 255, 255),
    text: rgb(39, 41, 98),
    text_subtle: rgb(87, 83, 198),
  )
}

pub fn indigo() -> ColourScale {
  ColourScale(
    bg: rgb(253, 253, 254),
    bg_subtle: rgb(247, 249, 255),
    tint: rgb(225, 233, 255),
    tint_subtle: rgb(237, 242, 254),
    tint_strong: rgb(210, 222, 255),
    accent: rgb(171, 189, 249),
    accent_subtle: rgb(193, 208, 255),
    accent_strong: rgb(141, 164, 239),
    solid: rgb(62, 99, 221),
    solid_subtle: rgb(73, 110, 229),
    solid_strong: rgb(51, 88, 212),
    solid_text: rgb(255, 255, 255),
    text: rgb(31, 45, 92),
    text_subtle: rgb(58, 91, 199),
  )
}

pub fn blue() -> ColourScale {
  ColourScale(
    bg: rgb(251, 253, 255),
    bg_subtle: rgb(244, 250, 255),
    tint: rgb(213, 239, 255),
    tint_subtle: rgb(230, 244, 254),
    tint_strong: rgb(194, 229, 255),
    accent: rgb(142, 200, 246),
    accent_subtle: rgb(172, 216, 252),
    accent_strong: rgb(94, 177, 239),
    solid: rgb(0, 144, 255),
    solid_subtle: rgb(5, 148, 260),
    solid_strong: rgb(5, 136, 240),
    solid_text: rgb(255, 255, 255),
    text: rgb(17, 50, 100),
    text_subtle: rgb(13, 116, 206),
  )
}

pub fn cyan() -> ColourScale {
  ColourScale(
    bg: rgb(250, 253, 254),
    bg_subtle: rgb(242, 250, 251),
    tint: rgb(202, 241, 246),
    tint_subtle: rgb(222, 247, 249),
    tint_strong: rgb(181, 233, 240),
    accent: rgb(125, 206, 220),
    accent_subtle: rgb(157, 221, 231),
    accent_strong: rgb(61, 185, 207),
    solid: rgb(0, 162, 199),
    solid_subtle: rgb(247, 172, 213),
    solid_strong: rgb(7, 151, 185),
    solid_text: rgb(255, 255, 255),
    text: rgb(13, 60, 72),
    text_subtle: rgb(16, 125, 152),
  )
}

pub fn teal() -> ColourScale {
  ColourScale(
    bg: rgb(250, 254, 253),
    bg_subtle: rgb(243, 251, 249),
    tint: rgb(204, 243, 234),
    tint_subtle: rgb(224, 248, 243),
    tint_strong: rgb(184, 234, 224),
    accent: rgb(131, 205, 193),
    accent_subtle: rgb(161, 222, 210),
    accent_strong: rgb(83, 185, 171),
    solid: rgb(18, 165, 148),
    solid_subtle: rgb(23, 174, 156),
    solid_strong: rgb(13, 155, 138),
    solid_text: rgb(255, 255, 255),
    text: rgb(13, 61, 56),
    text_subtle: rgb(0, 133, 115),
  )
}

pub fn jade() -> ColourScale {
  ColourScale(
    bg: rgb(251, 254, 253),
    bg_subtle: rgb(244, 251, 247),
    tint: rgb(214, 241, 227),
    tint_subtle: rgb(230, 247, 237),
    tint_strong: rgb(195, 233, 215),
    accent: rgb(139, 206, 182),
    accent_subtle: rgb(172, 222, 200),
    accent_strong: rgb(86, 186, 159),
    solid: rgb(41, 163, 131),
    solid_subtle: rgb(44, 172, 139),
    solid_strong: rgb(38, 153, 123),
    solid_text: rgb(255, 255, 255),
    text: rgb(29, 59, 49),
    text_subtle: rgb(32, 131, 104),
  )
}

pub fn green() -> ColourScale {
  ColourScale(
    bg: rgb(251, 254, 252),
    bg_subtle: rgb(244, 251, 246),
    tint: rgb(214, 241, 223),
    tint_subtle: rgb(230, 246, 235),
    tint_strong: rgb(196, 232, 209),
    accent: rgb(142, 206, 170),
    accent_subtle: rgb(173, 221, 192),
    accent_strong: rgb(91, 185, 139),
    solid: rgb(48, 164, 108),
    solid_subtle: rgb(53, 173, 115),
    solid_strong: rgb(43, 154, 102),
    solid_text: rgb(255, 255, 255),
    text: rgb(25, 59, 45),
    text_subtle: rgb(33, 131, 88),
  )
}

pub fn grass() -> ColourScale {
  ColourScale(
    bg: rgb(251, 254, 251),
    bg_subtle: rgb(245, 251, 245),
    tint: rgb(218, 241, 219),
    tint_subtle: rgb(233, 246, 233),
    tint_strong: rgb(201, 232, 202),
    accent: rgb(148, 206, 154),
    accent_subtle: rgb(178, 221, 181),
    accent_strong: rgb(101, 186, 116),
    solid: rgb(70, 167, 88),
    solid_subtle: rgb(79, 177, 97),
    solid_strong: rgb(62, 155, 79),
    solid_text: rgb(255, 255, 255),
    text: rgb(32, 60, 37),
    text_subtle: rgb(42, 126, 59),
  )
}

pub fn brown() -> ColourScale {
  ColourScale(
    bg: rgb(254, 253, 252),
    bg_subtle: rgb(252, 249, 246),
    tint: rgb(240, 228, 217),
    tint_subtle: rgb(246, 238, 231),
    tint_strong: rgb(235, 218, 202),
    accent: rgb(220, 188, 159),
    accent_subtle: rgb(228, 205, 183),
    accent_strong: rgb(206, 163, 126),
    solid: rgb(173, 127, 88),
    solid_subtle: rgb(181, 136, 97),
    solid_strong: rgb(160, 117, 83),
    solid_text: rgb(255, 255, 255),
    text: rgb(62, 51, 46),
    text_subtle: rgb(129, 94, 70),
  )
}

pub fn bronze() -> ColourScale {
  ColourScale(
    bg: rgb(253, 252, 252),
    bg_subtle: rgb(253, 247, 245),
    tint: rgb(239, 228, 223),
    tint_subtle: rgb(246, 237, 234),
    tint_strong: rgb(231, 217, 211),
    accent: rgb(211, 188, 179),
    accent_subtle: rgb(223, 205, 197),
    accent_strong: rgb(194, 164, 153),
    solid: rgb(161, 128, 114),
    solid_subtle: rgb(172, 138, 124),
    solid_strong: rgb(149, 116, 104),
    solid_text: rgb(255, 255, 255),
    text: rgb(67, 48, 43),
    text_subtle: rgb(125, 94, 84),
  )
}

pub fn gold() -> ColourScale {
  ColourScale(
    bg: rgb(253, 253, 252),
    bg_subtle: rgb(250, 249, 242),
    tint: rgb(234, 230, 219),
    tint_subtle: rgb(242, 240, 231),
    tint_strong: rgb(225, 220, 207),
    accent: rgb(203, 192, 170),
    accent_subtle: rgb(216, 208, 191),
    accent_strong: rgb(185, 168, 141),
    solid: rgb(151, 131, 101),
    solid_subtle: rgb(159, 139, 110),
    solid_strong: rgb(140, 122, 94),
    solid_text: rgb(255, 255, 255),
    text: rgb(59, 53, 43),
    text_subtle: rgb(113, 98, 75),
  )
}

pub fn sky() -> ColourScale {
  ColourScale(
    bg: rgb(249, 254, 255),
    bg_subtle: rgb(241, 250, 253),
    tint: rgb(209, 240, 250),
    tint_subtle: rgb(225, 246, 253),
    tint_strong: rgb(190, 231, 245),
    accent: rgb(141, 202, 227),
    accent_subtle: rgb(169, 218, 237),
    accent_strong: rgb(96, 179, 215),
    solid: rgb(124, 226, 254),
    solid_subtle: rgb(133, 231, 258),
    solid_strong: rgb(116, 218, 248),
    solid_text: rgb(29, 62, 86),
    text: rgb(29, 62, 86),
    text_subtle: rgb(0, 116, 158),
  )
}

pub fn mint() -> ColourScale {
  ColourScale(
    bg: rgb(249, 254, 253),
    bg_subtle: rgb(242, 251, 249),
    tint: rgb(200, 244, 233),
    tint_subtle: rgb(221, 249, 242),
    tint_strong: rgb(179, 236, 222),
    accent: rgb(126, 207, 189),
    accent_subtle: rgb(156, 224, 208),
    accent_strong: rgb(76, 187, 165),
    solid: rgb(134, 234, 212),
    solid_subtle: rgb(144, 242, 220),
    solid_strong: rgb(125, 224, 203),
    solid_text: rgb(22, 67, 60),
    text: rgb(22, 67, 60),
    text_subtle: rgb(2, 120, 100),
  )
}

pub fn lime() -> ColourScale {
  ColourScale(
    bg: rgb(252, 253, 250),
    bg_subtle: rgb(248, 250, 243),
    tint: rgb(226, 240, 189),
    tint_subtle: rgb(238, 246, 214),
    tint_strong: rgb(211, 231, 166),
    accent: rgb(171, 201, 120),
    accent_subtle: rgb(194, 218, 145),
    accent_strong: rgb(141, 182, 84),
    solid: rgb(189, 238, 99),
    solid_subtle: rgb(201, 244, 123),
    solid_strong: rgb(176, 230, 76),
    solid_text: rgb(55, 64, 28),
    text: rgb(55, 64, 28),
    text_subtle: rgb(92, 124, 47),
  )
}

pub fn yellow() -> ColourScale {
  ColourScale(
    bg: rgb(253, 253, 249),
    bg_subtle: rgb(254, 252, 233),
    tint: rgb(255, 243, 148),
    tint_subtle: rgb(255, 250, 184),
    tint_strong: rgb(255, 231, 112),
    accent: rgb(228, 199, 103),
    accent_subtle: rgb(243, 215, 104),
    accent_strong: rgb(213, 174, 57),
    solid: rgb(255, 230, 41),
    solid_subtle: rgb(255, 234, 82),
    solid_strong: rgb(255, 220, 0),
    solid_text: rgb(71, 59, 31),
    text: rgb(71, 59, 31),
    text_subtle: rgb(158, 108, 0),
  )
}

pub fn amber() -> ColourScale {
  ColourScale(
    bg: rgb(254, 253, 251),
    bg_subtle: rgb(254, 251, 233),
    tint: rgb(255, 238, 156),
    tint_subtle: rgb(255, 247, 194),
    tint_strong: rgb(251, 229, 119),
    accent: rgb(233, 193, 98),
    accent_subtle: rgb(243, 214, 115),
    accent_strong: rgb(226, 163, 54),
    solid: rgb(255, 197, 61),
    solid_subtle: rgb(255, 208, 97),
    solid_strong: rgb(255, 186, 24),
    solid_text: rgb(79, 52, 34),
    text: rgb(79, 52, 34),
    text_subtle: rgb(171, 100, 0),
  )
}

pub fn orange() -> ColourScale {
  ColourScale(
    bg: rgb(254, 252, 251),
    bg_subtle: rgb(255, 247, 237),
    tint: rgb(255, 223, 181),
    tint_subtle: rgb(255, 239, 214),
    tint_strong: rgb(255, 209, 154),
    accent: rgb(245, 174, 115),
    accent_subtle: rgb(255, 193, 130),
    accent_strong: rgb(236, 148, 85),
    solid: rgb(247, 107, 21),
    solid_subtle: rgb(240, 126, 56),
    solid_strong: rgb(239, 95, 0),
    solid_text: rgb(255, 255, 255),
    text: rgb(88, 45, 29),
    text_subtle: rgb(204, 78, 0),
  )
}

pub fn gray_dark() -> ColourScale {
  ColourScale(
    bg: rgb(25, 25, 25),
    bg_subtle: rgb(17, 17, 17),
    tint: rgb(42, 42, 42),
    tint_subtle: rgb(34, 34, 34),
    tint_strong: rgb(49, 49, 49),
    accent: rgb(72, 72, 72),
    accent_subtle: rgb(58, 58, 58),
    accent_strong: rgb(96, 96, 96),
    solid: rgb(110, 110, 110),
    solid_subtle: rgb(97, 97, 97),
    solid_strong: rgb(123, 123, 123),
    solid_text: rgb(255, 255, 255),
    text: rgb(238, 238, 238),
    text_subtle: rgb(180, 180, 180),
  )
}

pub fn mauve_dark() -> ColourScale {
  ColourScale(
    bg: rgb(26, 25, 27),
    bg_subtle: rgb(18, 17, 19),
    tint: rgb(43, 41, 45),
    tint_subtle: rgb(35, 34, 37),
    tint_strong: rgb(50, 48, 53),
    accent: rgb(73, 71, 78),
    accent_subtle: rgb(60, 57, 63),
    accent_strong: rgb(98, 95, 105),
    solid: rgb(111, 109, 120),
    solid_subtle: rgb(98, 96, 106),
    solid_strong: rgb(124, 122, 133),
    solid_text: rgb(255, 255, 255),
    text: rgb(238, 238, 240),
    text_subtle: rgb(181, 178, 188),
  )
}

pub fn slate_dark() -> ColourScale {
  ColourScale(
    bg: rgb(24, 25, 27),
    bg_subtle: rgb(17, 17, 19),
    tint: rgb(39, 42, 45),
    tint_subtle: rgb(33, 34, 37),
    tint_strong: rgb(46, 49, 53),
    accent: rgb(67, 72, 78),
    accent_subtle: rgb(54, 58, 63),
    accent_strong: rgb(90, 97, 105),
    solid: rgb(105, 110, 119),
    solid_subtle: rgb(91, 96, 105),
    solid_strong: rgb(119, 123, 132),
    solid_text: rgb(255, 255, 255),
    text: rgb(237, 238, 240),
    text_subtle: rgb(176, 180, 186),
  )
}

pub fn sage_dark() -> ColourScale {
  ColourScale(
    bg: rgb(23, 25, 24),
    bg_subtle: rgb(16, 18, 17),
    tint: rgb(39, 42, 41),
    tint_subtle: rgb(32, 34, 33),
    tint_strong: rgb(46, 49, 48),
    accent: rgb(68, 73, 71),
    accent_subtle: rgb(55, 59, 57),
    accent_strong: rgb(91, 98, 95),
    solid: rgb(99, 112, 107),
    solid_subtle: rgb(85, 98, 93),
    solid_strong: rgb(113, 125, 121),
    solid_text: rgb(255, 255, 255),
    text: rgb(236, 238, 237),
    text_subtle: rgb(173, 181, 178),
  )
}

pub fn olive_dark() -> ColourScale {
  ColourScale(
    bg: rgb(24, 25, 23),
    bg_subtle: rgb(17, 18, 16),
    tint: rgb(40, 42, 39),
    tint_subtle: rgb(33, 34, 32),
    tint_strong: rgb(47, 49, 46),
    accent: rgb(69, 72, 67),
    accent_subtle: rgb(56, 58, 54),
    accent_strong: rgb(92, 98, 91),
    solid: rgb(104, 112, 102),
    solid_subtle: rgb(90, 98, 88),
    solid_strong: rgb(118, 125, 116),
    solid_text: rgb(255, 255, 255),
    text: rgb(236, 238, 236),
    text_subtle: rgb(175, 181, 173),
  )
}

pub fn sand_dark() -> ColourScale {
  ColourScale(
    bg: rgb(25, 25, 24),
    bg_subtle: rgb(17, 17, 16),
    tint: rgb(42, 42, 40),
    tint_subtle: rgb(34, 34, 33),
    tint_strong: rgb(49, 49, 46),
    accent: rgb(73, 72, 68),
    accent_subtle: rgb(59, 58, 55),
    accent_strong: rgb(98, 96, 91),
    solid: rgb(111, 109, 102),
    solid_subtle: rgb(97, 95, 88),
    solid_strong: rgb(124, 123, 116),
    solid_text: rgb(255, 255, 255),
    text: rgb(238, 238, 236),
    text_subtle: rgb(181, 179, 173),
  )
}

pub fn tomato_dark() -> ColourScale {
  ColourScale(
    bg: rgb(31, 21, 19),
    bg_subtle: rgb(24, 17, 17),
    tint: rgb(78, 21, 17),
    tint_subtle: rgb(57, 23, 20),
    tint_strong: rgb(94, 28, 22),
    accent: rgb(133, 58, 45),
    accent_subtle: rgb(110, 41, 32),
    accent_strong: rgb(172, 77, 57),
    solid: rgb(229, 77, 46),
    solid_subtle: rgb(215, 63, 32),
    solid_strong: rgb(236, 97, 66),
    solid_text: rgb(255, 255, 255),
    text: rgb(251, 211, 203),
    text_subtle: rgb(255, 151, 125),
  )
}

pub fn red_dark() -> ColourScale {
  ColourScale(
    bg: rgb(32, 19, 20),
    bg_subtle: rgb(25, 17, 17),
    tint: rgb(80, 15, 28),
    tint_subtle: rgb(59, 18, 25),
    tint_strong: rgb(97, 22, 35),
    accent: rgb(140, 51, 58),
    accent_subtle: rgb(114, 35, 45),
    accent_strong: rgb(181, 69, 72),
    solid: rgb(229, 72, 77),
    solid_subtle: rgb(220, 52, 57),
    solid_strong: rgb(236, 93, 94),
    solid_text: rgb(255, 255, 255),
    text: rgb(255, 209, 217),
    text_subtle: rgb(255, 149, 146),
  )
}

pub fn ruby_dark() -> ColourScale {
  ColourScale(
    bg: rgb(30, 21, 23),
    bg_subtle: rgb(25, 17, 19),
    tint: rgb(78, 19, 37),
    tint_subtle: rgb(58, 20, 30),
    tint_strong: rgb(94, 26, 46),
    accent: rgb(136, 52, 71),
    accent_subtle: rgb(111, 37, 57),
    accent_strong: rgb(179, 68, 90),
    solid: rgb(229, 70, 102),
    solid_subtle: rgb(220, 51, 85),
    solid_strong: rgb(236, 90, 114),
    solid_text: rgb(255, 255, 255),
    text: rgb(254, 210, 225),
    text_subtle: rgb(255, 148, 157),
  )
}

pub fn crimson_dark() -> ColourScale {
  ColourScale(
    bg: rgb(32, 19, 24),
    bg_subtle: rgb(25, 17, 20),
    tint: rgb(77, 18, 47),
    tint_subtle: rgb(56, 21, 37),
    tint_strong: rgb(92, 24, 57),
    accent: rgb(135, 51, 86),
    accent_subtle: rgb(109, 37, 69),
    accent_strong: rgb(176, 67, 110),
    solid: rgb(233, 61, 130),
    solid_subtle: rgb(227, 41, 116),
    solid_strong: rgb(238, 81, 138),
    solid_text: rgb(255, 255, 255),
    text: rgb(253, 211, 232),
    text_subtle: rgb(255, 146, 173),
  )
}

pub fn pink_dark() -> ColourScale {
  ColourScale(
    bg: rgb(33, 18, 29),
    bg_subtle: rgb(25, 17, 23),
    tint: rgb(75, 20, 61),
    tint_subtle: rgb(55, 23, 47),
    tint_strong: rgb(89, 28, 71),
    accent: rgb(131, 56, 105),
    accent_subtle: rgb(105, 41, 85),
    accent_strong: rgb(168, 72, 133),
    solid: rgb(214, 64, 159),
    solid_subtle: rgb(203, 49, 147),
    solid_strong: rgb(222, 81, 168),
    solid_text: rgb(255, 255, 255),
    text: rgb(253, 209, 234),
    text_subtle: rgb(255, 141, 204),
  )
}

pub fn plum_dark() -> ColourScale {
  ColourScale(
    bg: rgb(32, 19, 32),
    bg_subtle: rgb(24, 17, 24),
    tint: rgb(69, 29, 71),
    tint_subtle: rgb(53, 26, 53),
    tint_strong: rgb(81, 36, 84),
    accent: rgb(115, 64, 121),
    accent_subtle: rgb(94, 48, 97),
    accent_strong: rgb(146, 84, 156),
    solid: rgb(171, 74, 186),
    solid_subtle: rgb(154, 68, 167),
    solid_strong: rgb(182, 88, 196),
    solid_text: rgb(255, 255, 255),
    text: rgb(244, 212, 244),
    text_subtle: rgb(231, 150, 243),
  )
}

pub fn purple_dark() -> ColourScale {
  ColourScale(
    bg: rgb(30, 21, 35),
    bg_subtle: rgb(24, 17, 27),
    tint: rgb(61, 34, 78),
    tint_subtle: rgb(48, 28, 59),
    tint_strong: rgb(72, 41, 92),
    accent: rgb(102, 66, 130),
    accent_subtle: rgb(84, 52, 107),
    accent_strong: rgb(132, 87, 170),
    solid: rgb(142, 78, 198),
    solid_subtle: rgb(129, 66, 185),
    solid_strong: rgb(154, 92, 208),
    solid_text: rgb(255, 255, 255),
    text: rgb(236, 217, 250),
    text_subtle: rgb(209, 157, 255),
  )
}

pub fn violet_dark() -> ColourScale {
  ColourScale(
    bg: rgb(27, 21, 37),
    bg_subtle: rgb(20, 18, 31),
    tint: rgb(51, 37, 91),
    tint_subtle: rgb(41, 31, 67),
    tint_strong: rgb(60, 46, 105),
    accent: rgb(86, 70, 139),
    accent_subtle: rgb(71, 56, 118),
    accent_strong: rgb(105, 88, 173),
    solid: rgb(110, 86, 207),
    solid_subtle: rgb(95, 71, 195),
    solid_strong: rgb(125, 102, 217),
    solid_text: rgb(255, 255, 255),
    text: rgb(226, 221, 254),
    text_subtle: rgb(186, 167, 255),
  )
}

pub fn iris_dark() -> ColourScale {
  ColourScale(
    bg: rgb(23, 22, 37),
    bg_subtle: rgb(19, 19, 30),
    tint: rgb(38, 42, 101),
    tint_subtle: rgb(32, 34, 72),
    tint_strong: rgb(48, 51, 116),
    accent: rgb(74, 74, 149),
    accent_subtle: rgb(61, 62, 130),
    accent_strong: rgb(89, 88, 177),
    solid: rgb(91, 91, 214),
    solid_subtle: rgb(76, 76, 205),
    solid_strong: rgb(110, 106, 222),
    solid_text: rgb(255, 255, 255),
    text: rgb(224, 223, 254),
    text_subtle: rgb(177, 169, 255),
  )
}

pub fn indigo_dark() -> ColourScale {
  ColourScale(
    bg: rgb(20, 23, 38),
    bg_subtle: rgb(17, 19, 31),
    tint: rgb(29, 46, 98),
    tint_subtle: rgb(24, 36, 73),
    tint_strong: rgb(37, 57, 116),
    accent: rgb(58, 79, 151),
    accent_subtle: rgb(48, 67, 132),
    accent_strong: rgb(67, 93, 177),
    solid: rgb(62, 99, 221),
    solid_subtle: rgb(41, 81, 212),
    solid_strong: rgb(84, 114, 228),
    solid_text: rgb(255, 255, 255),
    text: rgb(214, 225, 255),
    text_subtle: rgb(158, 177, 255),
  )
}

pub fn blue_dark() -> ColourScale {
  ColourScale(
    bg: rgb(17, 25, 39),
    bg_subtle: rgb(13, 21, 32),
    tint: rgb(0, 51, 98),
    tint_subtle: rgb(13, 40, 71),
    tint_strong: rgb(0, 64, 116),
    accent: rgb(32, 93, 158),
    accent_subtle: rgb(16, 77, 135),
    accent_strong: rgb(40, 112, 189),
    solid: rgb(0, 144, 255),
    solid_subtle: rgb(0, 110, 195),
    solid_strong: rgb(59, 158, 255),
    solid_text: rgb(255, 255, 255),
    text: rgb(194, 230, 255),
    text_subtle: rgb(112, 184, 255),
  )
}

pub fn cyan_dark() -> ColourScale {
  ColourScale(
    bg: rgb(16, 27, 32),
    bg_subtle: rgb(11, 22, 26),
    tint: rgb(0, 56, 72),
    tint_subtle: rgb(8, 44, 54),
    tint_strong: rgb(0, 69, 88),
    accent: rgb(18, 103, 126),
    accent_subtle: rgb(4, 84, 104),
    accent_strong: rgb(17, 128, 156),
    solid: rgb(0, 162, 199),
    solid_subtle: rgb(232, 140, 177),
    solid_strong: rgb(35, 175, 208),
    solid_text: rgb(255, 255, 255),
    text: rgb(182, 236, 247),
    text_subtle: rgb(76, 204, 230),
  )
}

pub fn teal_dark() -> ColourScale {
  ColourScale(
    bg: rgb(17, 28, 27),
    bg_subtle: rgb(13, 21, 20),
    tint: rgb(2, 59, 55),
    tint_subtle: rgb(13, 45, 42),
    tint_strong: rgb(8, 72, 67),
    accent: rgb(28, 105, 97),
    accent_subtle: rgb(20, 87, 80),
    accent_strong: rgb(32, 126, 115),
    solid: rgb(18, 165, 148),
    solid_subtle: rgb(21, 151, 136),
    solid_strong: rgb(14, 179, 158),
    solid_text: rgb(255, 255, 255),
    text: rgb(173, 240, 221),
    text_subtle: rgb(11, 216, 182),
  )
}

pub fn jade_dark() -> ColourScale {
  ColourScale(
    bg: rgb(18, 28, 24),
    bg_subtle: rgb(13, 21, 18),
    tint: rgb(11, 59, 44),
    tint_subtle: rgb(15, 46, 34),
    tint_strong: rgb(17, 72, 55),
    accent: rgb(36, 104, 84),
    accent_subtle: rgb(27, 87, 69),
    accent_strong: rgb(42, 126, 104),
    solid: rgb(41, 163, 131),
    solid_subtle: rgb(42, 150, 122),
    solid_strong: rgb(39, 176, 139),
    solid_text: rgb(255, 255, 255),
    text: rgb(173, 240, 212),
    text_subtle: rgb(31, 216, 164),
  )
}

pub fn green_dark() -> ColourScale {
  ColourScale(
    bg: rgb(18, 27, 23),
    bg_subtle: rgb(14, 21, 18),
    tint: rgb(17, 59, 41),
    tint_subtle: rgb(19, 45, 33),
    tint_strong: rgb(23, 73, 51),
    accent: rgb(40, 104, 74),
    accent_subtle: rgb(32, 87, 62),
    accent_strong: rgb(47, 124, 87),
    solid: rgb(48, 164, 108),
    solid_subtle: rgb(44, 152, 100),
    solid_strong: rgb(51, 176, 116),
    solid_text: rgb(255, 255, 255),
    text: rgb(177, 241, 203),
    text_subtle: rgb(61, 214, 140),
  )
}

pub fn grass_dark() -> ColourScale {
  ColourScale(
    bg: rgb(20, 26, 21),
    bg_subtle: rgb(14, 21, 17),
    tint: rgb(29, 58, 36),
    tint_subtle: rgb(27, 42, 30),
    tint_strong: rgb(37, 72, 45),
    accent: rgb(54, 103, 64),
    accent_subtle: rgb(45, 87, 54),
    accent_strong: rgb(62, 121, 73),
    solid: rgb(70, 167, 88),
    solid_subtle: rgb(60, 151, 77),
    solid_strong: rgb(83, 179, 101),
    solid_text: rgb(255, 255, 255),
    text: rgb(194, 240, 194),
    text_subtle: rgb(113, 208, 131),
  )
}

pub fn brown_dark() -> ColourScale {
  ColourScale(
    bg: rgb(28, 24, 22),
    bg_subtle: rgb(18, 17, 15),
    tint: rgb(50, 41, 34),
    tint_subtle: rgb(40, 33, 29),
    tint_strong: rgb(62, 49, 40),
    accent: rgb(97, 74, 57),
    accent_subtle: rgb(77, 60, 47),
    accent_strong: rgb(124, 95, 70),
    solid: rgb(173, 127, 88),
    solid_subtle: rgb(155, 114, 79),
    solid_strong: rgb(184, 140, 103),
    solid_text: rgb(255, 255, 255),
    text: rgb(242, 225, 202),
    text_subtle: rgb(219, 181, 148),
  )
}

pub fn bronze_dark() -> ColourScale {
  ColourScale(
    bg: rgb(28, 25, 23),
    bg_subtle: rgb(20, 17, 16),
    tint: rgb(48, 42, 39),
    tint_subtle: rgb(38, 34, 32),
    tint_strong: rgb(59, 51, 48),
    accent: rgb(90, 76, 71),
    accent_subtle: rgb(73, 62, 58),
    accent_strong: rgb(111, 95, 88),
    solid: rgb(161, 128, 114),
    solid_subtle: rgb(146, 116, 103),
    solid_strong: rgb(174, 140, 126),
    solid_text: rgb(255, 255, 255),
    text: rgb(237, 224, 217),
    text_subtle: rgb(212, 179, 165),
  )
}

pub fn gold_dark() -> ColourScale {
  ColourScale(
    bg: rgb(27, 26, 23),
    bg_subtle: rgb(18, 18, 17),
    tint: rgb(45, 43, 38),
    tint_subtle: rgb(36, 35, 31),
    tint_strong: rgb(56, 53, 46),
    accent: rgb(84, 79, 70),
    accent_subtle: rgb(68, 64, 57),
    accent_strong: rgb(105, 98, 86),
    solid: rgb(151, 131, 101),
    solid_subtle: rgb(134, 117, 91),
    solid_strong: rgb(163, 144, 115),
    solid_text: rgb(255, 255, 255),
    text: rgb(232, 226, 217),
    text_subtle: rgb(203, 185, 159),
  )
}

pub fn sky_dark() -> ColourScale {
  ColourScale(
    bg: rgb(17, 26, 39),
    bg_subtle: rgb(13, 20, 31),
    tint: rgb(17, 53, 85),
    tint_subtle: rgb(17, 40, 64),
    tint_strong: rgb(21, 68, 103),
    accent: rgb(31, 102, 146),
    accent_subtle: rgb(27, 83, 123),
    accent_strong: rgb(25, 124, 174),
    solid: rgb(124, 226, 254),
    solid_subtle: rgb(80, 215, 252),
    solid_strong: rgb(168, 238, 255),
    solid_text: rgb(17, 26, 39),
    text: rgb(194, 243, 255),
    text_subtle: rgb(117, 199, 240),
  )
}

pub fn mint_dark() -> ColourScale {
  ColourScale(
    bg: rgb(15, 27, 27),
    bg_subtle: rgb(14, 21, 21),
    tint: rgb(0, 58, 56),
    tint_subtle: rgb(9, 44, 43),
    tint_strong: rgb(0, 71, 68),
    accent: rgb(30, 104, 95),
    accent_subtle: rgb(16, 86, 80),
    accent_strong: rgb(39, 127, 112),
    solid: rgb(134, 234, 212),
    solid_subtle: rgb(104, 218, 193),
    solid_strong: rgb(168, 245, 229),
    solid_text: rgb(15, 27, 27),
    text: rgb(196, 245, 225),
    text_subtle: rgb(88, 213, 186),
  )
}

pub fn lime_dark() -> ColourScale {
  ColourScale(
    bg: rgb(21, 26, 16),
    bg_subtle: rgb(17, 19, 12),
    tint: rgb(41, 55, 29),
    tint_subtle: rgb(31, 41, 23),
    tint_strong: rgb(51, 68, 35),
    accent: rgb(73, 98, 49),
    accent_subtle: rgb(61, 82, 42),
    accent_strong: rgb(87, 117, 56),
    solid: rgb(189, 238, 99),
    solid_subtle: rgb(171, 215, 91),
    solid_strong: rgb(212, 255, 112),
    solid_text: rgb(21, 26, 16),
    text: rgb(227, 247, 186),
    text_subtle: rgb(189, 229, 108),
  )
}

pub fn yellow_dark() -> ColourScale {
  ColourScale(
    bg: rgb(27, 24, 15),
    bg_subtle: rgb(20, 18, 11),
    tint: rgb(54, 43, 0),
    tint_subtle: rgb(45, 35, 5),
    tint_strong: rgb(67, 53, 0),
    accent: rgb(102, 84, 23),
    accent_subtle: rgb(82, 66, 2),
    accent_strong: rgb(131, 106, 33),
    solid: rgb(255, 230, 41),
    solid_subtle: rgb(250, 220, 0),
    solid_strong: rgb(255, 255, 87),
    solid_text: rgb(27, 24, 15),
    text: rgb(246, 238, 180),
    text_subtle: rgb(245, 225, 71),
  )
}

pub fn amber_dark() -> ColourScale {
  ColourScale(
    bg: rgb(29, 24, 15),
    bg_subtle: rgb(22, 18, 12),
    tint: rgb(63, 39, 0),
    tint_subtle: rgb(48, 32, 8),
    tint_strong: rgb(77, 48, 0),
    accent: rgb(113, 79, 25),
    accent_subtle: rgb(92, 61, 5),
    accent_strong: rgb(143, 100, 36),
    solid: rgb(255, 197, 61),
    solid_subtle: rgb(255, 212, 111),
    solid_strong: rgb(255, 214, 10),
    solid_text: rgb(29, 24, 15),
    text: rgb(255, 231, 179),
    text_subtle: rgb(255, 202, 22),
  )
}

pub fn orange_dark() -> ColourScale {
  ColourScale(
    bg: rgb(30, 22, 15),
    bg_subtle: rgb(23, 18, 14),
    tint: rgb(70, 33, 0),
    tint_subtle: rgb(51, 30, 11),
    tint_strong: rgb(86, 40, 0),
    accent: rgb(126, 69, 29),
    accent_subtle: rgb(102, 53, 12),
    accent_strong: rgb(163, 88, 41),
    solid: rgb(247, 107, 21),
    solid_subtle: rgb(233, 99, 16),
    solid_strong: rgb(255, 128, 31),
    solid_text: rgb(255, 255, 255),
    text: rgb(255, 224, 194),
    text_subtle: rgb(255, 160, 87),
  )
}
