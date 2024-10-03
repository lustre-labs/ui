// IMPORTS ---------------------------------------------------------------------

import { List, Ok, Error } from "../prelude.mjs";

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
 * @returns {Result<List<Element>, List<never>>} A decoded list of elements. If
 * the slot is not an instance of `HTMLSlotElement`, an empty list of decode
 * errors is returned.
 */
export const assigned_elements = (slot) => {
  if (slot instanceof HTMLSlotElement) {
    return new Ok(List.fromArray(slot.assignedElements()));
  }

  return new Error(List.fromArray([]));
};
