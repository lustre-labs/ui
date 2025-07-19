// IMPORTS ---------------------------------------------------------------------

import { List, Ok, Error } from "../../../prelude.mjs";
import { BoundingClientRect } from "./dom.mjs";

// DECODERS --------------------------------------------------------------------

export const assigned_elements = (slot) => {
  if (!(slot instanceof HTMLSlotElement)) return new Error(undefined);

  const elements = slot.assignedElements();

  return new Ok(List.fromArray(elements));
};

export const bounding_client_rect = (element) => {
  if (!(element instanceof HTMLElement)) return new Error(undefined);

  const rect = element.getBoundingClientRect();

  return new Ok(
    new BoundingClientRect(
      rect.top,
      rect.right,
      rect.bottom,
      rect.left,
      rect.width,
      rect.height,
    ),
  );
};

export const attribute = (element, name) => {
  if (!(element instanceof HTMLElement)) return new Error(undefined);
  if (typeof name !== "string") return new Error(undefined);

  const value = element.getAttribute(name);

  if (value === null) {
    return new Error(undefined);
  } else {
    return new Ok(value);
  }
};

// EFFECTS ---------------------------------------------------------------------

export const prevent_default = (event) => {
  if (!(event instanceof Event)) return;

  event.preventDefault();
};

export const find_element = (selector, root = document) => {
  if (typeof selector !== "string") return new Error(undefined);
  if (!(root instanceof Document || root instanceof Element))
    return new Error(undefined);

  const element = root.querySelector(selector);

  if (element === null) {
    return new Error(undefined);
  } else {
    return new Ok(element);
  }
};

export const focus = (element) => {
  if (!(element instanceof HTMLElement)) return;

  element.focus();
};
