import { List, Empty, Ok, Error } from "../../gleam.mjs";

//

export const is_element = (dynamic) => dynamic instanceof HTMLElement;

export const get_attribute = (element, key) => {
  if (element.hasAttribute(key)) {
    return new Ok(element.getAttribute(key));
  } else {
    return new Error(undefined);
  }
};

//

export const make_fallback_element = () => document.createElement("div");

export const assigned_elements = (slot) => {
  if (slot instanceof HTMLSlotElement) {
    return List.fromArray(Array.from(slot.assignedElements()));
  } else {
    return new Empty();
  }
};

export const tag = (element) => element.localName;
