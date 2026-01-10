// IMPORTS ---------------------------------------------------------------------

import { Result$Ok, Result$Error } from "../../gleam.mjs";

// QUERIES ---------------------------------------------------------------------

export function activeElement() {
  const element = document.activeElement;

  if (element !== null) {
    return Result$Ok(element);
  } else {
    return Result$Error(undefined);
  }
}
