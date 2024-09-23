import { List, Ok, Error } from "../prelude.mjs";

export const assigned_elements = (slot) => {
  if (slot instanceof HTMLSlotElement) {
    return new Ok(slot.assignedElements());
  }

  return new Error(List.fromArray([]));
};
