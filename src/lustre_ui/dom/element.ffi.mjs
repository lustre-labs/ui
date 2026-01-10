// IMPORTS ---------------------------------------------------------------------

import { List, Result$Ok, Result$Error } from "../../gleam.mjs";
import {
  Order$Lt,
  Order$Eq,
  Order$Gt,
} from "../../../gleam_stdlib/gleam/order.mjs";

// CONSTRUCTORS ----------------------------------------------------------------

export function coerce(value) {
  return value;
}

export function createHtmlElement(tag) {
  return document.createElement(tag);
}

// QUERIES ---------------------------------------------------------------------

export function assignedElements(slot) {
  if (!(slot instanceof HTMLSlotElement)) return List.fromArray([]);

  return List.fromArray(Array.from(slot.assignedElements()));
}

export function attribute(element, name) {
  if (element.hasAttribute(name)) {
    return Result$Ok(element.getAttribute(name));
  } else {
    return Result$Error(undefined);
  }
}

export function closest(element, selector) {
  const result = element.closest(selector);

  if (result !== null) {
    return Result$Ok(result);
  } else {
    return Result$Error(undefined);
  }
}

export function compare(left, right) {
  if (left === right) {
    return Order$Eq();
  }

  const position = left.compareDocumentPosition(right);

  if (position & Node.DOCUMENT_POSITION_FOLLOWING) {
    return Order$Lt();
  } else {
    return Order$Gt();
  }
}

export function contains(parent, child) {
  return parent.contains(child);
}

export function host(element) {
  const root = element instanceof ShadowRoot ? element : element.getRootNode();

  if (root instanceof ShadowRoot) {
    return Result$Ok(root.host);
  } else {
    return Result$Error(undefined);
  }
}

export function is(element, other) {
  return element.isSameNode(other);
}

export function isHtmlElement(node) {
  return node instanceof HTMLElement;
}

export function isShadowRoot(node) {
  return node instanceof ShadowRoot;
}

export function matches(element, selector) {
  return element.matches(selector);
}

export function querySelector(element, selector) {
  const result = element.querySelector(selector);

  if (result !== null) {
    return Result$Ok(result);
  } else {
    return Result$Error(undefined);
  }
}

export function querySelectorAll(element, selector) {
  return List.fromArray(Array.from(element.querySelectorAll(selector)));
}

export function root(element) {
  return element.getRootNode();
}

export function selection(element) {
  const selectionStart = element.selectionStart;
  const selectionEnd = element.selectionEnd;

  if (typeof selectionStart === "number" && typeof selectionEnd === "number") {
    return Result$Ok([selectionStart, selectionEnd]);
  } else {
    return Result$Error(undefined);
  }
}

export function tag(element) {
  return element.tagName.toLowerCase();
}

export function value(element) {
  if (typeof element.value === "string") {
    return Result$Ok(element.value);
  } else {
    return Result$Error(undefined);
  }
}

// MANIPULATIONS ---------------------------------------------------------------

export function focus(element) {
  element.focus();
}

export function setAttribute(element, key, value) {
  element.setAttribute(key, value);
}

export function removeAttribute(element, key) {
  element.removeAttribute(key);
}
