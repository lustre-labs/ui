// IMPORTS ---------------------------------------------------------------------

import lustre_ui/dom/element.{type HtmlElement}

// QUERIES ---------------------------------------------------------------------

@external(javascript, "./document.ffi.mjs", "activeElement")
pub fn active_element() -> Result(HtmlElement, Nil)
