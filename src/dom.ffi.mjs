// IMPORTS ---------------------------------------------------------------------

import { List, Ok, Error } from "../prelude.mjs";
import {
  ComponentAlreadyRegistered,
  NotABrowser,
  is_browser,
} from "../lustre/lustre.mjs";

// TYPES -----------------------------------------------------------------------

/**
 * @template A
 * @typedef {import("../build/dev/javascript/prelude.mjs").List} List<A>
 */

/**
 * @template A, E
 * @typedef {import("../build/dev/javascript/prelude.mjs").Result} Result<A, E>
 */

// QUERIES ---------------------------------------------------------------------

/**
 * Access the assigned elements of a Web Component's slot.
 *
 * @param {HTMLSlotElement} slot
 *
 * @returns {Result<List<HTMLElement>, List<never>>} A decoded list of elements. If
 * the slot is not an instance of `HTMLSlotElement`, an empty list of decode
 * errors is returned.
 */
export const assigned_elements = (slot) => {
  if (slot instanceof HTMLSlotElement) {
    return new Ok(List.fromArray(slot.assignedElements()));
  }

  return new Error(List.fromArray([]));
};

/**
 *
 */
export const animation_time = () => {
  return window.document.timeline.currentTime;
};

/**
 * @param {string} name
 *
 * @returns {(element: HTMLElement) => Result<string, List<never>>}
 */
export const get_attribute = (name) => (element) => {
  if (!(element instanceof HTMLElement)) {
    return new Error(List.fromArray([]));
  }

  if (element.hasAttribute(name)) {
    return new Ok(element.getAttribute(name));
  } else {
    return new Error(List.fromArray([]));
  }
};

/**
 * @param {string} name
 *
 * @returns {(element: HTMLElement) => Result<HTMLElement, List<never>>}
 */
export const get_element = (selector) => (element) => {
  if (!("querySelector" in element)) {
    return new Error(List.fromArray([]));
  }

  const result = element.querySelector(selector);

  if (result) {
    return new Ok(result);
  } else {
    return new Error(List.fromArray([]));
  }
};

/**
 * @param {HTMLElement} element
 *
 * @returns {Result<HTMLElement, List<never>>}
 */
export const get_root = (element) => {
  if (!(element instanceof HTMLElement)) {
    return new Error(List.fromArray([]));
  }

  return new Ok(element.getRootNode());
};

// EFFECTS ---------------------------------------------------------------------

/**
 * @param {HTMLElement} element
 */
export const focus = (element) => {
  element.focus();
};

export const set_state = (value, shadow_root) => {
  if (!(shadow_root instanceof ShadowRoot)) return;
  if (!(shadow_root.host.internals instanceof ElementInternals)) return;

  shadow_root.host.internals.states.add(value);
};

export const remove_state = (value, shadow_root) => {
  if (!(shadow_root instanceof ShadowRoot)) return;
  if (!(shadow_root.host.internals instanceof ElementInternals)) return;

  shadow_root.host.internals.states.delete(value);
};

// COMPONENTS ------------------------------------------------------------------

export const register_intersection_observer = () => {
  if (!is_browser()) return new Error(new NotABrowser());
  if (window.customElements.get("lustre-ui-intersection-observer")) {
    return new Error(
      new ComponentAlreadyRegistered("lustre-ui-intersection-observer"),
    );
  }

  customElements.define(
    "lustre-ui-intersection-observer",
    class LustreUiIntersectionObserver extends HTMLElement {
      constructor() {
        super();
        this.observer = null;
      }

      connectedCallback() {
        const options = {
          root: null,
          rootMargin: "0px",
          threshold: [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        };

        this.style.display = "contents";
        this.observer = new IntersectionObserver((entries) => {
          for (const entry of entries) {
            const intersectionEvent = new CustomEvent("intersection", {
              detail: {
                target: entry.target,
                isIntersecting: entry.isIntersecting,
                intersectionRatio: entry.intersectionRatio,
              },
              bubbles: true,
              composed: true,
            });

            this.dispatchEvent(intersectionEvent);
          }
        }, options);

        // Observe self
        this.observer.observe(this);
      }

      disconnectedCallback() {
        if (this.observer) {
          this.observer.disconnect();
        }
      }
    },
  );

  return new Ok(undefined);
};
