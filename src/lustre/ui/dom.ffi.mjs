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

export const text_content = (element) => element.textContent;

export const children = (element) =>
  List.fromArray(Array.from(element.children));

//

export const is_event = (dynamic) => dynamic instanceof Event;

//

export const with_cleanup = (root, callback) => {
  const host = root instanceof ShadowRoot ? root.host : root;
  const cleanup = callback();

  let observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.removedNodes) {
        if (node === host) {
          observer.disconnect();
          observer = null;
          cleanup?.();

          return;
        }
      }
    }
  });

  observer.observe(host.parentNode, {
    childList: true,
  });
};
