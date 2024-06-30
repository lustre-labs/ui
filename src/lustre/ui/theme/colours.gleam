// IMPORTS ---------------------------------------------------------------------

import gleam_community/colour.{type Colour}

// TYPES -----------------------------------------------------------------------

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

pub fn gray() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(252, 252, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(249, 249, 249)
  let assert Ok(tint) = colour.from_rgb255(232, 232, 232)
  let assert Ok(tint_subtle) = colour.from_rgb255(240, 240, 240)
  let assert Ok(tint_strong) = colour.from_rgb255(224, 224, 224)
  let assert Ok(accent) = colour.from_rgb255(206, 206, 206)
  let assert Ok(accent_subtle) = colour.from_rgb255(217, 217, 217)
  let assert Ok(accent_strong) = colour.from_rgb255(187, 187, 187)
  let assert Ok(solid) = colour.from_rgb255(141, 141, 141)
  let assert Ok(solid_subtle) = colour.from_rgb255(151, 151, 151)
  let assert Ok(solid_strong) = colour.from_rgb255(131, 131, 131)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(32, 32, 32)
  let assert Ok(text_subtle) = colour.from_rgb255(100, 100, 100)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn mauve() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 252, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(250, 249, 251)
  let assert Ok(tint) = colour.from_rgb255(234, 231, 236)
  let assert Ok(tint_subtle) = colour.from_rgb255(242, 239, 243)
  let assert Ok(tint_strong) = colour.from_rgb255(227, 223, 230)
  let assert Ok(accent) = colour.from_rgb255(208, 205, 215)
  let assert Ok(accent_subtle) = colour.from_rgb255(219, 216, 224)
  let assert Ok(accent_strong) = colour.from_rgb255(188, 186, 199)
  let assert Ok(solid) = colour.from_rgb255(142, 140, 153)
  let assert Ok(solid_subtle) = colour.from_rgb255(152, 150, 163)
  let assert Ok(solid_strong) = colour.from_rgb255(132, 130, 142)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(33, 31, 38)
  let assert Ok(text_subtle) = colour.from_rgb255(101, 99, 109)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn slate() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(252, 252, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(249, 249, 251)
  let assert Ok(tint) = colour.from_rgb255(232, 232, 236)
  let assert Ok(tint_subtle) = colour.from_rgb255(240, 240, 243)
  let assert Ok(tint_strong) = colour.from_rgb255(224, 225, 230)
  let assert Ok(accent) = colour.from_rgb255(205, 206, 214)
  let assert Ok(accent_subtle) = colour.from_rgb255(217, 217, 224)
  let assert Ok(accent_strong) = colour.from_rgb255(185, 187, 198)
  let assert Ok(solid) = colour.from_rgb255(139, 141, 152)
  let assert Ok(solid_subtle) = colour.from_rgb255(150, 152, 162)
  let assert Ok(solid_strong) = colour.from_rgb255(128, 131, 141)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(28, 32, 36)
  let assert Ok(text_subtle) = colour.from_rgb255(96, 100, 108)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sage() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(251, 253, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(247, 249, 248)
  let assert Ok(tint) = colour.from_rgb255(230, 233, 232)
  let assert Ok(tint_subtle) = colour.from_rgb255(238, 241, 240)
  let assert Ok(tint_strong) = colour.from_rgb255(223, 226, 224)
  let assert Ok(accent) = colour.from_rgb255(203, 207, 205)
  let assert Ok(accent_subtle) = colour.from_rgb255(215, 218, 217)
  let assert Ok(accent_strong) = colour.from_rgb255(184, 188, 186)
  let assert Ok(solid) = colour.from_rgb255(134, 142, 139)
  let assert Ok(solid_subtle) = colour.from_rgb255(144, 151, 148)
  let assert Ok(solid_strong) = colour.from_rgb255(124, 132, 129)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(26, 33, 30)
  let assert Ok(text_subtle) = colour.from_rgb255(95, 101, 99)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn olive() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(252, 253, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(248, 250, 248)
  let assert Ok(tint) = colour.from_rgb255(231, 233, 231)
  let assert Ok(tint_subtle) = colour.from_rgb255(239, 241, 239)
  let assert Ok(tint_strong) = colour.from_rgb255(223, 226, 223)
  let assert Ok(accent) = colour.from_rgb255(204, 207, 204)
  let assert Ok(accent_subtle) = colour.from_rgb255(215, 218, 215)
  let assert Ok(accent_strong) = colour.from_rgb255(185, 188, 184)
  let assert Ok(solid) = colour.from_rgb255(137, 142, 135)
  let assert Ok(solid_subtle) = colour.from_rgb255(147, 151, 145)
  let assert Ok(solid_strong) = colour.from_rgb255(127, 132, 125)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(29, 33, 28)
  let assert Ok(text_subtle) = colour.from_rgb255(96, 101, 95)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sand() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 253, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(249, 249, 248)
  let assert Ok(tint) = colour.from_rgb255(233, 232, 230)
  let assert Ok(tint_subtle) = colour.from_rgb255(241, 240, 239)
  let assert Ok(tint_strong) = colour.from_rgb255(226, 225, 222)
  let assert Ok(accent) = colour.from_rgb255(207, 206, 202)
  let assert Ok(accent_subtle) = colour.from_rgb255(218, 217, 214)
  let assert Ok(accent_strong) = colour.from_rgb255(188, 187, 181)
  let assert Ok(solid) = colour.from_rgb255(141, 141, 134)
  let assert Ok(solid_subtle) = colour.from_rgb255(151, 151, 144)
  let assert Ok(solid_strong) = colour.from_rgb255(130, 130, 124)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(33, 32, 28)
  let assert Ok(text_subtle) = colour.from_rgb255(99, 99, 94)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn tomato() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(255, 252, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(255, 248, 247)
  let assert Ok(tint) = colour.from_rgb255(255, 220, 211)
  let assert Ok(tint_subtle) = colour.from_rgb255(254, 235, 231)
  let assert Ok(tint_strong) = colour.from_rgb255(255, 205, 194)
  let assert Ok(accent) = colour.from_rgb255(245, 168, 152)
  let assert Ok(accent_subtle) = colour.from_rgb255(253, 189, 175)
  let assert Ok(accent_strong) = colour.from_rgb255(236, 142, 123)
  let assert Ok(solid) = colour.from_rgb255(229, 77, 46)
  let assert Ok(solid_subtle) = colour.from_rgb255(236, 86, 55)
  let assert Ok(solid_strong) = colour.from_rgb255(221, 68, 37)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(92, 39, 31)
  let assert Ok(text_subtle) = colour.from_rgb255(209, 52, 21)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn red() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(255, 252, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(255, 247, 247)
  let assert Ok(tint) = colour.from_rgb255(255, 219, 220)
  let assert Ok(tint_subtle) = colour.from_rgb255(254, 235, 236)
  let assert Ok(tint_strong) = colour.from_rgb255(255, 205, 206)
  let assert Ok(accent) = colour.from_rgb255(244, 169, 170)
  let assert Ok(accent_subtle) = colour.from_rgb255(253, 189, 190)
  let assert Ok(accent_strong) = colour.from_rgb255(235, 142, 144)
  let assert Ok(solid) = colour.from_rgb255(229, 72, 77)
  let assert Ok(solid_subtle) = colour.from_rgb255(236, 83, 88)
  let assert Ok(solid_strong) = colour.from_rgb255(220, 62, 66)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(100, 23, 35)
  let assert Ok(text_subtle) = colour.from_rgb255(206, 44, 49)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn ruby() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(255, 252, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(255, 247, 248)
  let assert Ok(tint) = colour.from_rgb255(255, 220, 225)
  let assert Ok(tint_subtle) = colour.from_rgb255(254, 234, 237)
  let assert Ok(tint_strong) = colour.from_rgb255(255, 206, 214)
  let assert Ok(accent) = colour.from_rgb255(239, 172, 184)
  let assert Ok(accent_subtle) = colour.from_rgb255(248, 191, 200)
  let assert Ok(accent_strong) = colour.from_rgb255(229, 146, 163)
  let assert Ok(solid) = colour.from_rgb255(229, 70, 102)
  let assert Ok(solid_subtle) = colour.from_rgb255(236, 82, 113)
  let assert Ok(solid_strong) = colour.from_rgb255(220, 59, 93)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(100, 23, 43)
  let assert Ok(text_subtle) = colour.from_rgb255(202, 36, 77)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn crimson() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(255, 252, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(254, 247, 249)
  let assert Ok(tint) = colour.from_rgb255(254, 220, 231)
  let assert Ok(tint_subtle) = colour.from_rgb255(255, 233, 240)
  let assert Ok(tint_strong) = colour.from_rgb255(250, 206, 221)
  let assert Ok(accent) = colour.from_rgb255(234, 172, 195)
  let assert Ok(accent_subtle) = colour.from_rgb255(243, 190, 209)
  let assert Ok(accent_strong) = colour.from_rgb255(224, 147, 178)
  let assert Ok(solid) = colour.from_rgb255(233, 61, 130)
  let assert Ok(solid_subtle) = colour.from_rgb255(241, 71, 139)
  let assert Ok(solid_strong) = colour.from_rgb255(223, 52, 120)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(98, 22, 57)
  let assert Ok(text_subtle) = colour.from_rgb255(203, 29, 99)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn pink() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(255, 252, 254)
  let assert Ok(bg_subtle) = colour.from_rgb255(254, 247, 251)
  let assert Ok(tint) = colour.from_rgb255(251, 220, 239)
  let assert Ok(tint_subtle) = colour.from_rgb255(254, 233, 245)
  let assert Ok(tint_strong) = colour.from_rgb255(246, 206, 231)
  let assert Ok(accent) = colour.from_rgb255(231, 172, 208)
  let assert Ok(accent_subtle) = colour.from_rgb255(239, 191, 221)
  let assert Ok(accent_strong) = colour.from_rgb255(221, 147, 194)
  let assert Ok(solid) = colour.from_rgb255(214, 64, 159)
  let assert Ok(solid_subtle) = colour.from_rgb255(220, 72, 166)
  let assert Ok(solid_strong) = colour.from_rgb255(207, 56, 151)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(101, 18, 73)
  let assert Ok(text_subtle) = colour.from_rgb255(194, 41, 138)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn plum() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(254, 252, 255)
  let assert Ok(bg_subtle) = colour.from_rgb255(253, 247, 253)
  let assert Ok(tint) = colour.from_rgb255(247, 222, 248)
  let assert Ok(tint_subtle) = colour.from_rgb255(251, 235, 251)
  let assert Ok(tint_strong) = colour.from_rgb255(242, 209, 243)
  let assert Ok(accent) = colour.from_rgb255(222, 173, 227)
  let assert Ok(accent_subtle) = colour.from_rgb255(233, 194, 236)
  let assert Ok(accent_strong) = colour.from_rgb255(207, 145, 216)
  let assert Ok(solid) = colour.from_rgb255(171, 74, 186)
  let assert Ok(solid_subtle) = colour.from_rgb255(177, 85, 191)
  let assert Ok(solid_strong) = colour.from_rgb255(161, 68, 175)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(83, 25, 93)
  let assert Ok(text_subtle) = colour.from_rgb255(149, 62, 163)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn purple() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(254, 252, 254)
  let assert Ok(bg_subtle) = colour.from_rgb255(251, 247, 254)
  let assert Ok(tint) = colour.from_rgb255(242, 226, 252)
  let assert Ok(tint_subtle) = colour.from_rgb255(247, 237, 254)
  let assert Ok(tint_strong) = colour.from_rgb255(234, 213, 249)
  let assert Ok(accent) = colour.from_rgb255(209, 175, 236)
  let assert Ok(accent_subtle) = colour.from_rgb255(224, 196, 244)
  let assert Ok(accent_strong) = colour.from_rgb255(190, 147, 228)
  let assert Ok(solid) = colour.from_rgb255(142, 78, 198)
  let assert Ok(solid_subtle) = colour.from_rgb255(152, 86, 209)
  let assert Ok(solid_strong) = colour.from_rgb255(131, 71, 185)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(64, 32, 96)
  let assert Ok(text_subtle) = colour.from_rgb255(129, 69, 181)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn violet() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 252, 254)
  let assert Ok(bg_subtle) = colour.from_rgb255(250, 248, 255)
  let assert Ok(tint) = colour.from_rgb255(235, 228, 255)
  let assert Ok(tint_subtle) = colour.from_rgb255(244, 240, 254)
  let assert Ok(tint_strong) = colour.from_rgb255(225, 217, 255)
  let assert Ok(accent) = colour.from_rgb255(194, 181, 245)
  let assert Ok(accent_subtle) = colour.from_rgb255(212, 202, 254)
  let assert Ok(accent_strong) = colour.from_rgb255(170, 153, 236)
  let assert Ok(solid) = colour.from_rgb255(110, 86, 207)
  let assert Ok(solid_subtle) = colour.from_rgb255(120, 96, 216)
  let assert Ok(solid_strong) = colour.from_rgb255(101, 77, 196)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(47, 38, 95)
  let assert Ok(text_subtle) = colour.from_rgb255(101, 80, 185)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn iris() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 253, 255)
  let assert Ok(bg_subtle) = colour.from_rgb255(248, 248, 255)
  let assert Ok(tint) = colour.from_rgb255(230, 231, 255)
  let assert Ok(tint_subtle) = colour.from_rgb255(240, 241, 254)
  let assert Ok(tint_strong) = colour.from_rgb255(218, 220, 255)
  let assert Ok(accent) = colour.from_rgb255(184, 186, 248)
  let assert Ok(accent_subtle) = colour.from_rgb255(203, 205, 255)
  let assert Ok(accent_strong) = colour.from_rgb255(155, 158, 240)
  let assert Ok(solid) = colour.from_rgb255(91, 91, 214)
  let assert Ok(solid_subtle) = colour.from_rgb255(101, 101, 222)
  let assert Ok(solid_strong) = colour.from_rgb255(81, 81, 205)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(39, 41, 98)
  let assert Ok(text_subtle) = colour.from_rgb255(87, 83, 198)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn indigo() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 253, 254)
  let assert Ok(bg_subtle) = colour.from_rgb255(247, 249, 255)
  let assert Ok(tint) = colour.from_rgb255(225, 233, 255)
  let assert Ok(tint_subtle) = colour.from_rgb255(237, 242, 254)
  let assert Ok(tint_strong) = colour.from_rgb255(210, 222, 255)
  let assert Ok(accent) = colour.from_rgb255(171, 189, 249)
  let assert Ok(accent_subtle) = colour.from_rgb255(193, 208, 255)
  let assert Ok(accent_strong) = colour.from_rgb255(141, 164, 239)
  let assert Ok(solid) = colour.from_rgb255(62, 99, 221)
  let assert Ok(solid_subtle) = colour.from_rgb255(73, 110, 229)
  let assert Ok(solid_strong) = colour.from_rgb255(51, 88, 212)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(31, 45, 92)
  let assert Ok(text_subtle) = colour.from_rgb255(58, 91, 199)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn blue() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(251, 253, 255)
  let assert Ok(bg_subtle) = colour.from_rgb255(244, 250, 255)
  let assert Ok(tint) = colour.from_rgb255(213, 239, 255)
  let assert Ok(tint_subtle) = colour.from_rgb255(230, 244, 254)
  let assert Ok(tint_strong) = colour.from_rgb255(194, 229, 255)
  let assert Ok(accent) = colour.from_rgb255(142, 200, 246)
  let assert Ok(accent_subtle) = colour.from_rgb255(172, 216, 252)
  let assert Ok(accent_strong) = colour.from_rgb255(94, 177, 239)
  let assert Ok(solid) = colour.from_rgb255(0, 144, 255)
  let assert Ok(solid_subtle) = colour.from_rgb255(5, 148, 260)
  let assert Ok(solid_strong) = colour.from_rgb255(5, 136, 240)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(17, 50, 100)
  let assert Ok(text_subtle) = colour.from_rgb255(13, 116, 206)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn cyan() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(250, 253, 254)
  let assert Ok(bg_subtle) = colour.from_rgb255(242, 250, 251)
  let assert Ok(tint) = colour.from_rgb255(202, 241, 246)
  let assert Ok(tint_subtle) = colour.from_rgb255(222, 247, 249)
  let assert Ok(tint_strong) = colour.from_rgb255(181, 233, 240)
  let assert Ok(accent) = colour.from_rgb255(125, 206, 220)
  let assert Ok(accent_subtle) = colour.from_rgb255(157, 221, 231)
  let assert Ok(accent_strong) = colour.from_rgb255(61, 185, 207)
  let assert Ok(solid) = colour.from_rgb255(0, 162, 199)
  let assert Ok(solid_subtle) = colour.from_rgb255(247, 172, 213)
  let assert Ok(solid_strong) = colour.from_rgb255(7, 151, 185)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(13, 60, 72)
  let assert Ok(text_subtle) = colour.from_rgb255(16, 125, 152)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn teal() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(250, 254, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(243, 251, 249)
  let assert Ok(tint) = colour.from_rgb255(204, 243, 234)
  let assert Ok(tint_subtle) = colour.from_rgb255(224, 248, 243)
  let assert Ok(tint_strong) = colour.from_rgb255(184, 234, 224)
  let assert Ok(accent) = colour.from_rgb255(131, 205, 193)
  let assert Ok(accent_subtle) = colour.from_rgb255(161, 222, 210)
  let assert Ok(accent_strong) = colour.from_rgb255(83, 185, 171)
  let assert Ok(solid) = colour.from_rgb255(18, 165, 148)
  let assert Ok(solid_subtle) = colour.from_rgb255(23, 174, 156)
  let assert Ok(solid_strong) = colour.from_rgb255(13, 155, 138)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(13, 61, 56)
  let assert Ok(text_subtle) = colour.from_rgb255(0, 133, 115)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn jade() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(251, 254, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(244, 251, 247)
  let assert Ok(tint) = colour.from_rgb255(214, 241, 227)
  let assert Ok(tint_subtle) = colour.from_rgb255(230, 247, 237)
  let assert Ok(tint_strong) = colour.from_rgb255(195, 233, 215)
  let assert Ok(accent) = colour.from_rgb255(139, 206, 182)
  let assert Ok(accent_subtle) = colour.from_rgb255(172, 222, 200)
  let assert Ok(accent_strong) = colour.from_rgb255(86, 186, 159)
  let assert Ok(solid) = colour.from_rgb255(41, 163, 131)
  let assert Ok(solid_subtle) = colour.from_rgb255(44, 172, 139)
  let assert Ok(solid_strong) = colour.from_rgb255(38, 153, 123)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(29, 59, 49)
  let assert Ok(text_subtle) = colour.from_rgb255(32, 131, 104)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn green() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(251, 254, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(244, 251, 246)
  let assert Ok(tint) = colour.from_rgb255(214, 241, 223)
  let assert Ok(tint_subtle) = colour.from_rgb255(230, 246, 235)
  let assert Ok(tint_strong) = colour.from_rgb255(196, 232, 209)
  let assert Ok(accent) = colour.from_rgb255(142, 206, 170)
  let assert Ok(accent_subtle) = colour.from_rgb255(173, 221, 192)
  let assert Ok(accent_strong) = colour.from_rgb255(91, 185, 139)
  let assert Ok(solid) = colour.from_rgb255(48, 164, 108)
  let assert Ok(solid_subtle) = colour.from_rgb255(53, 173, 115)
  let assert Ok(solid_strong) = colour.from_rgb255(43, 154, 102)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(25, 59, 45)
  let assert Ok(text_subtle) = colour.from_rgb255(33, 131, 88)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn grass() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(251, 254, 251)
  let assert Ok(bg_subtle) = colour.from_rgb255(245, 251, 245)
  let assert Ok(tint) = colour.from_rgb255(218, 241, 219)
  let assert Ok(tint_subtle) = colour.from_rgb255(233, 246, 233)
  let assert Ok(tint_strong) = colour.from_rgb255(201, 232, 202)
  let assert Ok(accent) = colour.from_rgb255(148, 206, 154)
  let assert Ok(accent_subtle) = colour.from_rgb255(178, 221, 181)
  let assert Ok(accent_strong) = colour.from_rgb255(101, 186, 116)
  let assert Ok(solid) = colour.from_rgb255(70, 167, 88)
  let assert Ok(solid_subtle) = colour.from_rgb255(79, 177, 97)
  let assert Ok(solid_strong) = colour.from_rgb255(62, 155, 79)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(32, 60, 37)
  let assert Ok(text_subtle) = colour.from_rgb255(42, 126, 59)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn brown() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(254, 253, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(252, 249, 246)
  let assert Ok(tint) = colour.from_rgb255(240, 228, 217)
  let assert Ok(tint_subtle) = colour.from_rgb255(246, 238, 231)
  let assert Ok(tint_strong) = colour.from_rgb255(235, 218, 202)
  let assert Ok(accent) = colour.from_rgb255(220, 188, 159)
  let assert Ok(accent_subtle) = colour.from_rgb255(228, 205, 183)
  let assert Ok(accent_strong) = colour.from_rgb255(206, 163, 126)
  let assert Ok(solid) = colour.from_rgb255(173, 127, 88)
  let assert Ok(solid_subtle) = colour.from_rgb255(181, 136, 97)
  let assert Ok(solid_strong) = colour.from_rgb255(160, 117, 83)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(62, 51, 46)
  let assert Ok(text_subtle) = colour.from_rgb255(129, 94, 70)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn bronze() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 252, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(253, 247, 245)
  let assert Ok(tint) = colour.from_rgb255(239, 228, 223)
  let assert Ok(tint_subtle) = colour.from_rgb255(246, 237, 234)
  let assert Ok(tint_strong) = colour.from_rgb255(231, 217, 211)
  let assert Ok(accent) = colour.from_rgb255(211, 188, 179)
  let assert Ok(accent_subtle) = colour.from_rgb255(223, 205, 197)
  let assert Ok(accent_strong) = colour.from_rgb255(194, 164, 153)
  let assert Ok(solid) = colour.from_rgb255(161, 128, 114)
  let assert Ok(solid_subtle) = colour.from_rgb255(172, 138, 124)
  let assert Ok(solid_strong) = colour.from_rgb255(149, 116, 104)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(67, 48, 43)
  let assert Ok(text_subtle) = colour.from_rgb255(125, 94, 84)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn gold() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 253, 252)
  let assert Ok(bg_subtle) = colour.from_rgb255(250, 249, 242)
  let assert Ok(tint) = colour.from_rgb255(234, 230, 219)
  let assert Ok(tint_subtle) = colour.from_rgb255(242, 240, 231)
  let assert Ok(tint_strong) = colour.from_rgb255(225, 220, 207)
  let assert Ok(accent) = colour.from_rgb255(203, 192, 170)
  let assert Ok(accent_subtle) = colour.from_rgb255(216, 208, 191)
  let assert Ok(accent_strong) = colour.from_rgb255(185, 168, 141)
  let assert Ok(solid) = colour.from_rgb255(151, 131, 101)
  let assert Ok(solid_subtle) = colour.from_rgb255(159, 139, 110)
  let assert Ok(solid_strong) = colour.from_rgb255(140, 122, 94)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(59, 53, 43)
  let assert Ok(text_subtle) = colour.from_rgb255(113, 98, 75)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sky() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(249, 254, 255)
  let assert Ok(bg_subtle) = colour.from_rgb255(241, 250, 253)
  let assert Ok(tint) = colour.from_rgb255(209, 240, 250)
  let assert Ok(tint_subtle) = colour.from_rgb255(225, 246, 253)
  let assert Ok(tint_strong) = colour.from_rgb255(190, 231, 245)
  let assert Ok(accent) = colour.from_rgb255(141, 202, 227)
  let assert Ok(accent_subtle) = colour.from_rgb255(169, 218, 237)
  let assert Ok(accent_strong) = colour.from_rgb255(96, 179, 215)
  let assert Ok(solid) = colour.from_rgb255(124, 226, 254)
  let assert Ok(solid_subtle) = colour.from_rgb255(133, 231, 258)
  let assert Ok(solid_strong) = colour.from_rgb255(116, 218, 248)
  let assert Ok(solid_text) = colour.from_rgb255(29, 62, 86)
  let assert Ok(text) = colour.from_rgb255(29, 62, 86)
  let assert Ok(text_subtle) = colour.from_rgb255(0, 116, 158)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn mint() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(249, 254, 253)
  let assert Ok(bg_subtle) = colour.from_rgb255(242, 251, 249)
  let assert Ok(tint) = colour.from_rgb255(200, 244, 233)
  let assert Ok(tint_subtle) = colour.from_rgb255(221, 249, 242)
  let assert Ok(tint_strong) = colour.from_rgb255(179, 236, 222)
  let assert Ok(accent) = colour.from_rgb255(126, 207, 189)
  let assert Ok(accent_subtle) = colour.from_rgb255(156, 224, 208)
  let assert Ok(accent_strong) = colour.from_rgb255(76, 187, 165)
  let assert Ok(solid) = colour.from_rgb255(134, 234, 212)
  let assert Ok(solid_subtle) = colour.from_rgb255(144, 242, 220)
  let assert Ok(solid_strong) = colour.from_rgb255(125, 224, 203)
  let assert Ok(solid_text) = colour.from_rgb255(22, 67, 60)
  let assert Ok(text) = colour.from_rgb255(22, 67, 60)
  let assert Ok(text_subtle) = colour.from_rgb255(2, 120, 100)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn lime() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(252, 253, 250)
  let assert Ok(bg_subtle) = colour.from_rgb255(248, 250, 243)
  let assert Ok(tint) = colour.from_rgb255(226, 240, 189)
  let assert Ok(tint_subtle) = colour.from_rgb255(238, 246, 214)
  let assert Ok(tint_strong) = colour.from_rgb255(211, 231, 166)
  let assert Ok(accent) = colour.from_rgb255(171, 201, 120)
  let assert Ok(accent_subtle) = colour.from_rgb255(194, 218, 145)
  let assert Ok(accent_strong) = colour.from_rgb255(141, 182, 84)
  let assert Ok(solid) = colour.from_rgb255(189, 238, 99)
  let assert Ok(solid_subtle) = colour.from_rgb255(201, 244, 123)
  let assert Ok(solid_strong) = colour.from_rgb255(176, 230, 76)
  let assert Ok(solid_text) = colour.from_rgb255(55, 64, 28)
  let assert Ok(text) = colour.from_rgb255(55, 64, 28)
  let assert Ok(text_subtle) = colour.from_rgb255(92, 124, 47)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn yellow() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(253, 253, 249)
  let assert Ok(bg_subtle) = colour.from_rgb255(254, 252, 233)
  let assert Ok(tint) = colour.from_rgb255(255, 243, 148)
  let assert Ok(tint_subtle) = colour.from_rgb255(255, 250, 184)
  let assert Ok(tint_strong) = colour.from_rgb255(255, 231, 112)
  let assert Ok(accent) = colour.from_rgb255(228, 199, 103)
  let assert Ok(accent_subtle) = colour.from_rgb255(243, 215, 104)
  let assert Ok(accent_strong) = colour.from_rgb255(213, 174, 57)
  let assert Ok(solid) = colour.from_rgb255(255, 230, 41)
  let assert Ok(solid_subtle) = colour.from_rgb255(255, 234, 82)
  let assert Ok(solid_strong) = colour.from_rgb255(255, 220, 0)
  let assert Ok(solid_text) = colour.from_rgb255(71, 59, 31)
  let assert Ok(text) = colour.from_rgb255(71, 59, 31)
  let assert Ok(text_subtle) = colour.from_rgb255(158, 108, 0)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn amber() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(254, 253, 251)
  let assert Ok(bg_subtle) = colour.from_rgb255(254, 251, 233)
  let assert Ok(tint) = colour.from_rgb255(255, 238, 156)
  let assert Ok(tint_subtle) = colour.from_rgb255(255, 247, 194)
  let assert Ok(tint_strong) = colour.from_rgb255(251, 229, 119)
  let assert Ok(accent) = colour.from_rgb255(233, 193, 98)
  let assert Ok(accent_subtle) = colour.from_rgb255(243, 214, 115)
  let assert Ok(accent_strong) = colour.from_rgb255(226, 163, 54)
  let assert Ok(solid) = colour.from_rgb255(255, 197, 61)
  let assert Ok(solid_subtle) = colour.from_rgb255(255, 208, 97)
  let assert Ok(solid_strong) = colour.from_rgb255(255, 186, 24)
  let assert Ok(solid_text) = colour.from_rgb255(79, 52, 34)
  let assert Ok(text) = colour.from_rgb255(79, 52, 34)
  let assert Ok(text_subtle) = colour.from_rgb255(171, 100, 0)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn orange() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(254, 252, 251)
  let assert Ok(bg_subtle) = colour.from_rgb255(255, 247, 237)
  let assert Ok(tint) = colour.from_rgb255(255, 223, 181)
  let assert Ok(tint_subtle) = colour.from_rgb255(255, 239, 214)
  let assert Ok(tint_strong) = colour.from_rgb255(255, 209, 154)
  let assert Ok(accent) = colour.from_rgb255(245, 174, 115)
  let assert Ok(accent_subtle) = colour.from_rgb255(255, 193, 130)
  let assert Ok(accent_strong) = colour.from_rgb255(236, 148, 85)
  let assert Ok(solid) = colour.from_rgb255(247, 107, 21)
  let assert Ok(solid_subtle) = colour.from_rgb255(240, 126, 56)
  let assert Ok(solid_strong) = colour.from_rgb255(239, 95, 0)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(88, 45, 29)
  let assert Ok(text_subtle) = colour.from_rgb255(204, 78, 0)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn gray_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(25, 25, 25)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 17, 17)
  let assert Ok(tint) = colour.from_rgb255(42, 42, 42)
  let assert Ok(tint_subtle) = colour.from_rgb255(34, 34, 34)
  let assert Ok(tint_strong) = colour.from_rgb255(49, 49, 49)
  let assert Ok(accent) = colour.from_rgb255(72, 72, 72)
  let assert Ok(accent_subtle) = colour.from_rgb255(58, 58, 58)
  let assert Ok(accent_strong) = colour.from_rgb255(96, 96, 96)
  let assert Ok(solid) = colour.from_rgb255(110, 110, 110)
  let assert Ok(solid_subtle) = colour.from_rgb255(97, 97, 97)
  let assert Ok(solid_strong) = colour.from_rgb255(123, 123, 123)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(238, 238, 238)
  let assert Ok(text_subtle) = colour.from_rgb255(180, 180, 180)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn mauve_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(26, 25, 27)
  let assert Ok(bg_subtle) = colour.from_rgb255(18, 17, 19)
  let assert Ok(tint) = colour.from_rgb255(43, 41, 45)
  let assert Ok(tint_subtle) = colour.from_rgb255(35, 34, 37)
  let assert Ok(tint_strong) = colour.from_rgb255(50, 48, 53)
  let assert Ok(accent) = colour.from_rgb255(73, 71, 78)
  let assert Ok(accent_subtle) = colour.from_rgb255(60, 57, 63)
  let assert Ok(accent_strong) = colour.from_rgb255(98, 95, 105)
  let assert Ok(solid) = colour.from_rgb255(111, 109, 120)
  let assert Ok(solid_subtle) = colour.from_rgb255(98, 96, 106)
  let assert Ok(solid_strong) = colour.from_rgb255(124, 122, 133)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(238, 238, 240)
  let assert Ok(text_subtle) = colour.from_rgb255(181, 178, 188)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn slate_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(24, 25, 27)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 17, 19)
  let assert Ok(tint) = colour.from_rgb255(39, 42, 45)
  let assert Ok(tint_subtle) = colour.from_rgb255(33, 34, 37)
  let assert Ok(tint_strong) = colour.from_rgb255(46, 49, 53)
  let assert Ok(accent) = colour.from_rgb255(67, 72, 78)
  let assert Ok(accent_subtle) = colour.from_rgb255(54, 58, 63)
  let assert Ok(accent_strong) = colour.from_rgb255(90, 97, 105)
  let assert Ok(solid) = colour.from_rgb255(105, 110, 119)
  let assert Ok(solid_subtle) = colour.from_rgb255(91, 96, 105)
  let assert Ok(solid_strong) = colour.from_rgb255(119, 123, 132)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(237, 238, 240)
  let assert Ok(text_subtle) = colour.from_rgb255(176, 180, 186)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sage_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(23, 25, 24)
  let assert Ok(bg_subtle) = colour.from_rgb255(16, 18, 17)
  let assert Ok(tint) = colour.from_rgb255(39, 42, 41)
  let assert Ok(tint_subtle) = colour.from_rgb255(32, 34, 33)
  let assert Ok(tint_strong) = colour.from_rgb255(46, 49, 48)
  let assert Ok(accent) = colour.from_rgb255(68, 73, 71)
  let assert Ok(accent_subtle) = colour.from_rgb255(55, 59, 57)
  let assert Ok(accent_strong) = colour.from_rgb255(91, 98, 95)
  let assert Ok(solid) = colour.from_rgb255(99, 112, 107)
  let assert Ok(solid_subtle) = colour.from_rgb255(85, 98, 93)
  let assert Ok(solid_strong) = colour.from_rgb255(113, 125, 121)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(236, 238, 237)
  let assert Ok(text_subtle) = colour.from_rgb255(173, 181, 178)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn olive_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(24, 25, 23)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 18, 16)
  let assert Ok(tint) = colour.from_rgb255(40, 42, 39)
  let assert Ok(tint_subtle) = colour.from_rgb255(33, 34, 32)
  let assert Ok(tint_strong) = colour.from_rgb255(47, 49, 46)
  let assert Ok(accent) = colour.from_rgb255(69, 72, 67)
  let assert Ok(accent_subtle) = colour.from_rgb255(56, 58, 54)
  let assert Ok(accent_strong) = colour.from_rgb255(92, 98, 91)
  let assert Ok(solid) = colour.from_rgb255(104, 112, 102)
  let assert Ok(solid_subtle) = colour.from_rgb255(90, 98, 88)
  let assert Ok(solid_strong) = colour.from_rgb255(118, 125, 116)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(236, 238, 236)
  let assert Ok(text_subtle) = colour.from_rgb255(175, 181, 173)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sand_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(25, 25, 24)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 17, 16)
  let assert Ok(tint) = colour.from_rgb255(42, 42, 40)
  let assert Ok(tint_subtle) = colour.from_rgb255(34, 34, 33)
  let assert Ok(tint_strong) = colour.from_rgb255(49, 49, 46)
  let assert Ok(accent) = colour.from_rgb255(73, 72, 68)
  let assert Ok(accent_subtle) = colour.from_rgb255(59, 58, 55)
  let assert Ok(accent_strong) = colour.from_rgb255(98, 96, 91)
  let assert Ok(solid) = colour.from_rgb255(111, 109, 102)
  let assert Ok(solid_subtle) = colour.from_rgb255(97, 95, 88)
  let assert Ok(solid_strong) = colour.from_rgb255(124, 123, 116)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(238, 238, 236)
  let assert Ok(text_subtle) = colour.from_rgb255(181, 179, 173)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn tomato_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(31, 21, 19)
  let assert Ok(bg_subtle) = colour.from_rgb255(24, 17, 17)
  let assert Ok(tint) = colour.from_rgb255(78, 21, 17)
  let assert Ok(tint_subtle) = colour.from_rgb255(57, 23, 20)
  let assert Ok(tint_strong) = colour.from_rgb255(94, 28, 22)
  let assert Ok(accent) = colour.from_rgb255(133, 58, 45)
  let assert Ok(accent_subtle) = colour.from_rgb255(110, 41, 32)
  let assert Ok(accent_strong) = colour.from_rgb255(172, 77, 57)
  let assert Ok(solid) = colour.from_rgb255(229, 77, 46)
  let assert Ok(solid_subtle) = colour.from_rgb255(215, 63, 32)
  let assert Ok(solid_strong) = colour.from_rgb255(236, 97, 66)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(251, 211, 203)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 151, 125)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn red_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(32, 19, 20)
  let assert Ok(bg_subtle) = colour.from_rgb255(25, 17, 17)
  let assert Ok(tint) = colour.from_rgb255(80, 15, 28)
  let assert Ok(tint_subtle) = colour.from_rgb255(59, 18, 25)
  let assert Ok(tint_strong) = colour.from_rgb255(97, 22, 35)
  let assert Ok(accent) = colour.from_rgb255(140, 51, 58)
  let assert Ok(accent_subtle) = colour.from_rgb255(114, 35, 45)
  let assert Ok(accent_strong) = colour.from_rgb255(181, 69, 72)
  let assert Ok(solid) = colour.from_rgb255(229, 72, 77)
  let assert Ok(solid_subtle) = colour.from_rgb255(220, 52, 57)
  let assert Ok(solid_strong) = colour.from_rgb255(236, 93, 94)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(255, 209, 217)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 149, 146)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn ruby_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(30, 21, 23)
  let assert Ok(bg_subtle) = colour.from_rgb255(25, 17, 19)
  let assert Ok(tint) = colour.from_rgb255(78, 19, 37)
  let assert Ok(tint_subtle) = colour.from_rgb255(58, 20, 30)
  let assert Ok(tint_strong) = colour.from_rgb255(94, 26, 46)
  let assert Ok(accent) = colour.from_rgb255(136, 52, 71)
  let assert Ok(accent_subtle) = colour.from_rgb255(111, 37, 57)
  let assert Ok(accent_strong) = colour.from_rgb255(179, 68, 90)
  let assert Ok(solid) = colour.from_rgb255(229, 70, 102)
  let assert Ok(solid_subtle) = colour.from_rgb255(220, 51, 85)
  let assert Ok(solid_strong) = colour.from_rgb255(236, 90, 114)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(254, 210, 225)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 148, 157)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn crimson_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(32, 19, 24)
  let assert Ok(bg_subtle) = colour.from_rgb255(25, 17, 20)
  let assert Ok(tint) = colour.from_rgb255(77, 18, 47)
  let assert Ok(tint_subtle) = colour.from_rgb255(56, 21, 37)
  let assert Ok(tint_strong) = colour.from_rgb255(92, 24, 57)
  let assert Ok(accent) = colour.from_rgb255(135, 51, 86)
  let assert Ok(accent_subtle) = colour.from_rgb255(109, 37, 69)
  let assert Ok(accent_strong) = colour.from_rgb255(176, 67, 110)
  let assert Ok(solid) = colour.from_rgb255(233, 61, 130)
  let assert Ok(solid_subtle) = colour.from_rgb255(227, 41, 116)
  let assert Ok(solid_strong) = colour.from_rgb255(238, 81, 138)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(253, 211, 232)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 146, 173)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn pink_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(33, 18, 29)
  let assert Ok(bg_subtle) = colour.from_rgb255(25, 17, 23)
  let assert Ok(tint) = colour.from_rgb255(75, 20, 61)
  let assert Ok(tint_subtle) = colour.from_rgb255(55, 23, 47)
  let assert Ok(tint_strong) = colour.from_rgb255(89, 28, 71)
  let assert Ok(accent) = colour.from_rgb255(131, 56, 105)
  let assert Ok(accent_subtle) = colour.from_rgb255(105, 41, 85)
  let assert Ok(accent_strong) = colour.from_rgb255(168, 72, 133)
  let assert Ok(solid) = colour.from_rgb255(214, 64, 159)
  let assert Ok(solid_subtle) = colour.from_rgb255(203, 49, 147)
  let assert Ok(solid_strong) = colour.from_rgb255(222, 81, 168)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(253, 209, 234)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 141, 204)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn plum_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(32, 19, 32)
  let assert Ok(bg_subtle) = colour.from_rgb255(24, 17, 24)
  let assert Ok(tint) = colour.from_rgb255(69, 29, 71)
  let assert Ok(tint_subtle) = colour.from_rgb255(53, 26, 53)
  let assert Ok(tint_strong) = colour.from_rgb255(81, 36, 84)
  let assert Ok(accent) = colour.from_rgb255(115, 64, 121)
  let assert Ok(accent_subtle) = colour.from_rgb255(94, 48, 97)
  let assert Ok(accent_strong) = colour.from_rgb255(146, 84, 156)
  let assert Ok(solid) = colour.from_rgb255(171, 74, 186)
  let assert Ok(solid_subtle) = colour.from_rgb255(154, 68, 167)
  let assert Ok(solid_strong) = colour.from_rgb255(182, 88, 196)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(244, 212, 244)
  let assert Ok(text_subtle) = colour.from_rgb255(231, 150, 243)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn purple_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(30, 21, 35)
  let assert Ok(bg_subtle) = colour.from_rgb255(24, 17, 27)
  let assert Ok(tint) = colour.from_rgb255(61, 34, 78)
  let assert Ok(tint_subtle) = colour.from_rgb255(48, 28, 59)
  let assert Ok(tint_strong) = colour.from_rgb255(72, 41, 92)
  let assert Ok(accent) = colour.from_rgb255(102, 66, 130)
  let assert Ok(accent_subtle) = colour.from_rgb255(84, 52, 107)
  let assert Ok(accent_strong) = colour.from_rgb255(132, 87, 170)
  let assert Ok(solid) = colour.from_rgb255(142, 78, 198)
  let assert Ok(solid_subtle) = colour.from_rgb255(129, 66, 185)
  let assert Ok(solid_strong) = colour.from_rgb255(154, 92, 208)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(236, 217, 250)
  let assert Ok(text_subtle) = colour.from_rgb255(209, 157, 255)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn violet_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(27, 21, 37)
  let assert Ok(bg_subtle) = colour.from_rgb255(20, 18, 31)
  let assert Ok(tint) = colour.from_rgb255(51, 37, 91)
  let assert Ok(tint_subtle) = colour.from_rgb255(41, 31, 67)
  let assert Ok(tint_strong) = colour.from_rgb255(60, 46, 105)
  let assert Ok(accent) = colour.from_rgb255(86, 70, 139)
  let assert Ok(accent_subtle) = colour.from_rgb255(71, 56, 118)
  let assert Ok(accent_strong) = colour.from_rgb255(105, 88, 173)
  let assert Ok(solid) = colour.from_rgb255(110, 86, 207)
  let assert Ok(solid_subtle) = colour.from_rgb255(95, 71, 195)
  let assert Ok(solid_strong) = colour.from_rgb255(125, 102, 217)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(226, 221, 254)
  let assert Ok(text_subtle) = colour.from_rgb255(186, 167, 255)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn iris_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(23, 22, 37)
  let assert Ok(bg_subtle) = colour.from_rgb255(19, 19, 30)
  let assert Ok(tint) = colour.from_rgb255(38, 42, 101)
  let assert Ok(tint_subtle) = colour.from_rgb255(32, 34, 72)
  let assert Ok(tint_strong) = colour.from_rgb255(48, 51, 116)
  let assert Ok(accent) = colour.from_rgb255(74, 74, 149)
  let assert Ok(accent_subtle) = colour.from_rgb255(61, 62, 130)
  let assert Ok(accent_strong) = colour.from_rgb255(89, 88, 177)
  let assert Ok(solid) = colour.from_rgb255(91, 91, 214)
  let assert Ok(solid_subtle) = colour.from_rgb255(76, 76, 205)
  let assert Ok(solid_strong) = colour.from_rgb255(110, 106, 222)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(224, 223, 254)
  let assert Ok(text_subtle) = colour.from_rgb255(177, 169, 255)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn indigo_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(20, 23, 38)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 19, 31)
  let assert Ok(tint) = colour.from_rgb255(29, 46, 98)
  let assert Ok(tint_subtle) = colour.from_rgb255(24, 36, 73)
  let assert Ok(tint_strong) = colour.from_rgb255(37, 57, 116)
  let assert Ok(accent) = colour.from_rgb255(58, 79, 151)
  let assert Ok(accent_subtle) = colour.from_rgb255(48, 67, 132)
  let assert Ok(accent_strong) = colour.from_rgb255(67, 93, 177)
  let assert Ok(solid) = colour.from_rgb255(62, 99, 221)
  let assert Ok(solid_subtle) = colour.from_rgb255(41, 81, 212)
  let assert Ok(solid_strong) = colour.from_rgb255(84, 114, 228)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(214, 225, 255)
  let assert Ok(text_subtle) = colour.from_rgb255(158, 177, 255)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn blue_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(17, 25, 39)
  let assert Ok(bg_subtle) = colour.from_rgb255(13, 21, 32)
  let assert Ok(tint) = colour.from_rgb255(0, 51, 98)
  let assert Ok(tint_subtle) = colour.from_rgb255(13, 40, 71)
  let assert Ok(tint_strong) = colour.from_rgb255(0, 64, 116)
  let assert Ok(accent) = colour.from_rgb255(32, 93, 158)
  let assert Ok(accent_subtle) = colour.from_rgb255(16, 77, 135)
  let assert Ok(accent_strong) = colour.from_rgb255(40, 112, 189)
  let assert Ok(solid) = colour.from_rgb255(0, 144, 255)
  let assert Ok(solid_subtle) = colour.from_rgb255(0, 110, 195)
  let assert Ok(solid_strong) = colour.from_rgb255(59, 158, 255)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(194, 230, 255)
  let assert Ok(text_subtle) = colour.from_rgb255(112, 184, 255)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn cyan_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(16, 27, 32)
  let assert Ok(bg_subtle) = colour.from_rgb255(11, 22, 26)
  let assert Ok(tint) = colour.from_rgb255(0, 56, 72)
  let assert Ok(tint_subtle) = colour.from_rgb255(8, 44, 54)
  let assert Ok(tint_strong) = colour.from_rgb255(0, 69, 88)
  let assert Ok(accent) = colour.from_rgb255(18, 103, 126)
  let assert Ok(accent_subtle) = colour.from_rgb255(4, 84, 104)
  let assert Ok(accent_strong) = colour.from_rgb255(17, 128, 156)
  let assert Ok(solid) = colour.from_rgb255(0, 162, 199)
  let assert Ok(solid_subtle) = colour.from_rgb255(232, 140, 177)
  let assert Ok(solid_strong) = colour.from_rgb255(35, 175, 208)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(182, 236, 247)
  let assert Ok(text_subtle) = colour.from_rgb255(76, 204, 230)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn teal_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(17, 28, 27)
  let assert Ok(bg_subtle) = colour.from_rgb255(13, 21, 20)
  let assert Ok(tint) = colour.from_rgb255(2, 59, 55)
  let assert Ok(tint_subtle) = colour.from_rgb255(13, 45, 42)
  let assert Ok(tint_strong) = colour.from_rgb255(8, 72, 67)
  let assert Ok(accent) = colour.from_rgb255(28, 105, 97)
  let assert Ok(accent_subtle) = colour.from_rgb255(20, 87, 80)
  let assert Ok(accent_strong) = colour.from_rgb255(32, 126, 115)
  let assert Ok(solid) = colour.from_rgb255(18, 165, 148)
  let assert Ok(solid_subtle) = colour.from_rgb255(21, 151, 136)
  let assert Ok(solid_strong) = colour.from_rgb255(14, 179, 158)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(173, 240, 221)
  let assert Ok(text_subtle) = colour.from_rgb255(11, 216, 182)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn jade_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(18, 28, 24)
  let assert Ok(bg_subtle) = colour.from_rgb255(13, 21, 18)
  let assert Ok(tint) = colour.from_rgb255(11, 59, 44)
  let assert Ok(tint_subtle) = colour.from_rgb255(15, 46, 34)
  let assert Ok(tint_strong) = colour.from_rgb255(17, 72, 55)
  let assert Ok(accent) = colour.from_rgb255(36, 104, 84)
  let assert Ok(accent_subtle) = colour.from_rgb255(27, 87, 69)
  let assert Ok(accent_strong) = colour.from_rgb255(42, 126, 104)
  let assert Ok(solid) = colour.from_rgb255(41, 163, 131)
  let assert Ok(solid_subtle) = colour.from_rgb255(42, 150, 122)
  let assert Ok(solid_strong) = colour.from_rgb255(39, 176, 139)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(173, 240, 212)
  let assert Ok(text_subtle) = colour.from_rgb255(31, 216, 164)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn green_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(18, 27, 23)
  let assert Ok(bg_subtle) = colour.from_rgb255(14, 21, 18)
  let assert Ok(tint) = colour.from_rgb255(17, 59, 41)
  let assert Ok(tint_subtle) = colour.from_rgb255(19, 45, 33)
  let assert Ok(tint_strong) = colour.from_rgb255(23, 73, 51)
  let assert Ok(accent) = colour.from_rgb255(40, 104, 74)
  let assert Ok(accent_subtle) = colour.from_rgb255(32, 87, 62)
  let assert Ok(accent_strong) = colour.from_rgb255(47, 124, 87)
  let assert Ok(solid) = colour.from_rgb255(48, 164, 108)
  let assert Ok(solid_subtle) = colour.from_rgb255(44, 152, 100)
  let assert Ok(solid_strong) = colour.from_rgb255(51, 176, 116)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(177, 241, 203)
  let assert Ok(text_subtle) = colour.from_rgb255(61, 214, 140)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn grass_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(20, 26, 21)
  let assert Ok(bg_subtle) = colour.from_rgb255(14, 21, 17)
  let assert Ok(tint) = colour.from_rgb255(29, 58, 36)
  let assert Ok(tint_subtle) = colour.from_rgb255(27, 42, 30)
  let assert Ok(tint_strong) = colour.from_rgb255(37, 72, 45)
  let assert Ok(accent) = colour.from_rgb255(54, 103, 64)
  let assert Ok(accent_subtle) = colour.from_rgb255(45, 87, 54)
  let assert Ok(accent_strong) = colour.from_rgb255(62, 121, 73)
  let assert Ok(solid) = colour.from_rgb255(70, 167, 88)
  let assert Ok(solid_subtle) = colour.from_rgb255(60, 151, 77)
  let assert Ok(solid_strong) = colour.from_rgb255(83, 179, 101)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(194, 240, 194)
  let assert Ok(text_subtle) = colour.from_rgb255(113, 208, 131)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn brown_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(28, 24, 22)
  let assert Ok(bg_subtle) = colour.from_rgb255(18, 17, 15)
  let assert Ok(tint) = colour.from_rgb255(50, 41, 34)
  let assert Ok(tint_subtle) = colour.from_rgb255(40, 33, 29)
  let assert Ok(tint_strong) = colour.from_rgb255(62, 49, 40)
  let assert Ok(accent) = colour.from_rgb255(97, 74, 57)
  let assert Ok(accent_subtle) = colour.from_rgb255(77, 60, 47)
  let assert Ok(accent_strong) = colour.from_rgb255(124, 95, 70)
  let assert Ok(solid) = colour.from_rgb255(173, 127, 88)
  let assert Ok(solid_subtle) = colour.from_rgb255(155, 114, 79)
  let assert Ok(solid_strong) = colour.from_rgb255(184, 140, 103)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(242, 225, 202)
  let assert Ok(text_subtle) = colour.from_rgb255(219, 181, 148)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn bronze_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(28, 25, 23)
  let assert Ok(bg_subtle) = colour.from_rgb255(20, 17, 16)
  let assert Ok(tint) = colour.from_rgb255(48, 42, 39)
  let assert Ok(tint_subtle) = colour.from_rgb255(38, 34, 32)
  let assert Ok(tint_strong) = colour.from_rgb255(59, 51, 48)
  let assert Ok(accent) = colour.from_rgb255(90, 76, 71)
  let assert Ok(accent_subtle) = colour.from_rgb255(73, 62, 58)
  let assert Ok(accent_strong) = colour.from_rgb255(111, 95, 88)
  let assert Ok(solid) = colour.from_rgb255(161, 128, 114)
  let assert Ok(solid_subtle) = colour.from_rgb255(146, 116, 103)
  let assert Ok(solid_strong) = colour.from_rgb255(174, 140, 126)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(237, 224, 217)
  let assert Ok(text_subtle) = colour.from_rgb255(212, 179, 165)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn gold_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(27, 26, 23)
  let assert Ok(bg_subtle) = colour.from_rgb255(18, 18, 17)
  let assert Ok(tint) = colour.from_rgb255(45, 43, 38)
  let assert Ok(tint_subtle) = colour.from_rgb255(36, 35, 31)
  let assert Ok(tint_strong) = colour.from_rgb255(56, 53, 46)
  let assert Ok(accent) = colour.from_rgb255(84, 79, 70)
  let assert Ok(accent_subtle) = colour.from_rgb255(68, 64, 57)
  let assert Ok(accent_strong) = colour.from_rgb255(105, 98, 86)
  let assert Ok(solid) = colour.from_rgb255(151, 131, 101)
  let assert Ok(solid_subtle) = colour.from_rgb255(134, 117, 91)
  let assert Ok(solid_strong) = colour.from_rgb255(163, 144, 115)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(232, 226, 217)
  let assert Ok(text_subtle) = colour.from_rgb255(203, 185, 159)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn sky_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(17, 26, 39)
  let assert Ok(bg_subtle) = colour.from_rgb255(13, 20, 31)
  let assert Ok(tint) = colour.from_rgb255(17, 53, 85)
  let assert Ok(tint_subtle) = colour.from_rgb255(17, 40, 64)
  let assert Ok(tint_strong) = colour.from_rgb255(21, 68, 103)
  let assert Ok(accent) = colour.from_rgb255(31, 102, 146)
  let assert Ok(accent_subtle) = colour.from_rgb255(27, 83, 123)
  let assert Ok(accent_strong) = colour.from_rgb255(25, 124, 174)
  let assert Ok(solid) = colour.from_rgb255(124, 226, 254)
  let assert Ok(solid_subtle) = colour.from_rgb255(80, 215, 252)
  let assert Ok(solid_strong) = colour.from_rgb255(168, 238, 255)
  let assert Ok(solid_text) = colour.from_rgb255(17, 26, 39)
  let assert Ok(text) = colour.from_rgb255(194, 243, 255)
  let assert Ok(text_subtle) = colour.from_rgb255(117, 199, 240)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn mint_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(15, 27, 27)
  let assert Ok(bg_subtle) = colour.from_rgb255(14, 21, 21)
  let assert Ok(tint) = colour.from_rgb255(0, 58, 56)
  let assert Ok(tint_subtle) = colour.from_rgb255(9, 44, 43)
  let assert Ok(tint_strong) = colour.from_rgb255(0, 71, 68)
  let assert Ok(accent) = colour.from_rgb255(30, 104, 95)
  let assert Ok(accent_subtle) = colour.from_rgb255(16, 86, 80)
  let assert Ok(accent_strong) = colour.from_rgb255(39, 127, 112)
  let assert Ok(solid) = colour.from_rgb255(134, 234, 212)
  let assert Ok(solid_subtle) = colour.from_rgb255(104, 218, 193)
  let assert Ok(solid_strong) = colour.from_rgb255(168, 245, 229)
  let assert Ok(solid_text) = colour.from_rgb255(15, 27, 27)
  let assert Ok(text) = colour.from_rgb255(196, 245, 225)
  let assert Ok(text_subtle) = colour.from_rgb255(88, 213, 186)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn lime_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(21, 26, 16)
  let assert Ok(bg_subtle) = colour.from_rgb255(17, 19, 12)
  let assert Ok(tint) = colour.from_rgb255(41, 55, 29)
  let assert Ok(tint_subtle) = colour.from_rgb255(31, 41, 23)
  let assert Ok(tint_strong) = colour.from_rgb255(51, 68, 35)
  let assert Ok(accent) = colour.from_rgb255(73, 98, 49)
  let assert Ok(accent_subtle) = colour.from_rgb255(61, 82, 42)
  let assert Ok(accent_strong) = colour.from_rgb255(87, 117, 56)
  let assert Ok(solid) = colour.from_rgb255(189, 238, 99)
  let assert Ok(solid_subtle) = colour.from_rgb255(171, 215, 91)
  let assert Ok(solid_strong) = colour.from_rgb255(212, 255, 112)
  let assert Ok(solid_text) = colour.from_rgb255(21, 26, 16)
  let assert Ok(text) = colour.from_rgb255(227, 247, 186)
  let assert Ok(text_subtle) = colour.from_rgb255(189, 229, 108)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn yellow_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(27, 24, 15)
  let assert Ok(bg_subtle) = colour.from_rgb255(20, 18, 11)
  let assert Ok(tint) = colour.from_rgb255(54, 43, 0)
  let assert Ok(tint_subtle) = colour.from_rgb255(45, 35, 5)
  let assert Ok(tint_strong) = colour.from_rgb255(67, 53, 0)
  let assert Ok(accent) = colour.from_rgb255(102, 84, 23)
  let assert Ok(accent_subtle) = colour.from_rgb255(82, 66, 2)
  let assert Ok(accent_strong) = colour.from_rgb255(131, 106, 33)
  let assert Ok(solid) = colour.from_rgb255(255, 230, 41)
  let assert Ok(solid_subtle) = colour.from_rgb255(250, 220, 0)
  let assert Ok(solid_strong) = colour.from_rgb255(255, 255, 87)
  let assert Ok(solid_text) = colour.from_rgb255(27, 24, 15)
  let assert Ok(text) = colour.from_rgb255(246, 238, 180)
  let assert Ok(text_subtle) = colour.from_rgb255(245, 225, 71)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn amber_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(29, 24, 15)
  let assert Ok(bg_subtle) = colour.from_rgb255(22, 18, 12)
  let assert Ok(tint) = colour.from_rgb255(63, 39, 0)
  let assert Ok(tint_subtle) = colour.from_rgb255(48, 32, 8)
  let assert Ok(tint_strong) = colour.from_rgb255(77, 48, 0)
  let assert Ok(accent) = colour.from_rgb255(113, 79, 25)
  let assert Ok(accent_subtle) = colour.from_rgb255(92, 61, 5)
  let assert Ok(accent_strong) = colour.from_rgb255(143, 100, 36)
  let assert Ok(solid) = colour.from_rgb255(255, 197, 61)
  let assert Ok(solid_subtle) = colour.from_rgb255(255, 212, 111)
  let assert Ok(solid_strong) = colour.from_rgb255(255, 214, 10)
  let assert Ok(solid_text) = colour.from_rgb255(29, 24, 15)
  let assert Ok(text) = colour.from_rgb255(255, 231, 179)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 202, 22)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}

pub fn orange_dark() -> ColourScale {
  let assert Ok(bg) = colour.from_rgb255(30, 22, 15)
  let assert Ok(bg_subtle) = colour.from_rgb255(23, 18, 14)
  let assert Ok(tint) = colour.from_rgb255(70, 33, 0)
  let assert Ok(tint_subtle) = colour.from_rgb255(51, 30, 11)
  let assert Ok(tint_strong) = colour.from_rgb255(86, 40, 0)
  let assert Ok(accent) = colour.from_rgb255(126, 69, 29)
  let assert Ok(accent_subtle) = colour.from_rgb255(102, 53, 12)
  let assert Ok(accent_strong) = colour.from_rgb255(163, 88, 41)
  let assert Ok(solid) = colour.from_rgb255(247, 107, 21)
  let assert Ok(solid_subtle) = colour.from_rgb255(233, 99, 16)
  let assert Ok(solid_strong) = colour.from_rgb255(255, 128, 31)
  let assert Ok(solid_text) = colour.from_rgb255(255, 255, 255)
  let assert Ok(text) = colour.from_rgb255(255, 224, 194)
  let assert Ok(text_subtle) = colour.from_rgb255(255, 160, 87)

  ColourScale(
    bg,
    bg_subtle,
    tint,
    tint_subtle,
    tint_strong,
    accent,
    accent_subtle,
    accent_strong,
    solid,
    solid_subtle,
    solid_strong,
    solid_text,
    text,
    text_subtle,
  )
}
