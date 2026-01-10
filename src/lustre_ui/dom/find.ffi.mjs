// IMPORTS ---------------------------------------------------------------------

import { Filter$isAccept, Filter$isReject, Filter$isSkip } from "./find.mjs";
import {
  Result$Ok,
  Result$isOk,
  Result$Ok$0,
  Result$Error,
} from "../../gleam.mjs";

// CONSTRUCTORS ----------------------------------------------------------------

function createTreeWalker(root, pierceShadowRoot, matcher) {
  return document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT, (node) => {
    const filter = matcher(node);

    if (Filter$isAccept(filter)) {
      return NodeFilter.FILTER_ACCEPT;
    } else if (Filter$isReject(filter)) {
      return NodeFilter.FILTER_REJECT;
    } else if (
      pierceShadowRoot &&
      (node.shadowRoot || node instanceof HTMLSlotElement)
    ) {
      return NodeFilter.FILTER_ACCEPT;
    } else {
      return NodeFilter.FILTER_SKIP;
    }
  });
}

// QUERIES ---------------------------------------------------------------------

export function findFirstDescendant(root, pierceShadowRoot, matcher) {
  let walker = createTreeWalker(root, pierceShadowRoot, matcher);
  let current = null;

  while ((current = walker.nextNode())) {
    if (Filter$isAccept(matcher(current))) {
      return Result$Ok(current);
    }

    if (pierceShadowRoot && current.shadowRoot) {
      const firstDescendantInShadowRoot = findFirstDescendant(
        current.shadowRoot,
        pierceShadowRoot,
        matcher,
      );

      if (Result$isOk(firstDescendantInShadowRoot)) {
        return firstDescendantInShadowRoot;
      }
    } else if (pierceShadowRoot && current instanceof HTMLSlotElement) {
      const assignedNodes = current.assignedElements();

      for (const assignedNode of assignedNodes) {
        const firstDescendantInAssignedNode = findFirstDescendant(
          assignedNode,
          pierceShadowRoot,
          matcher,
        );

        if (Result$isOk(firstDescendantInAssignedNode)) {
          return firstDescendantInAssignedNode;
        }
      }
    } else {
      return Result$Ok(current);
    }
  }

  return Result$Error(undefined);
}

export function findPreviousDescendant(
  root,
  before,
  pierceShadowRoot,
  matcher,
) {
  return findNextDescendant(root, before, pierceShadowRoot, matcher, {
    reverse: true,
  });
}

export function findNextDescendant(
  root,
  after,
  pierceShadowRoot,
  matcher,
  { reverse = false } = {},
) {
  let walker = createTreeWalker(root, pierceShadowRoot, matcher);
  let current = null;

  if (after !== null) walker.currentNode = after;

  while ((current = reverse ? walker.previousNode() : walker.nextNode())) {
    if (Filter$isAccept(matcher(current))) {
      return Result$Ok(current);
    }

    if (pierceShadowRoot && current.shadowRoot) {
      const nextDescendantInShadowRoot = findNextDescendant(
        current.shadowRoot,
        reverse
          ? (Result$Ok$0(
              findLastDescendant(current.shadowRoot, pierceShadowRoot, matcher),
            ) ?? null)
          : null,
        pierceShadowRoot,
        matcher,
        { reverse },
      );

      if (Result$isOk(nextDescendantInShadowRoot)) {
        return nextDescendantInShadowRoot;
      }
    } else if (pierceShadowRoot && current instanceof HTMLSlotElement) {
      const assignedNodes = current.assignedElements();

      for (
        let i = reverse ? assignedNodes.length - 1 : 0;
        reverse ? i >= 0 : i < assignedNodes.length;
        reverse ? i-- : i++
      ) {
        const assignedNode = assignedNodes[i];
        const nextDescendantInAssignedNode = findNextDescendant(
          assignedNode,
          reverse
            ? (Result$Ok$0(
                findLastDescendant(assignedNode, pierceShadowRoot, matcher),
              ) ?? null)
            : null,
          pierceShadowRoot,
          matcher,
          { reverse },
        );

        if (Result$isOk(nextDescendantInAssignedNode)) {
          return nextDescendantInAssignedNode;
        }
      }
    } else {
      return Result$Ok(current);
    }
  }

  return Result$Error(undefined);
}

export function findLastDescendant(root, pierceShadowRoot, matcher) {
  let walker = createTreeWalker(root, pierceShadowRoot, matcher);
  let current = null;
  let last = null;

  while ((current = walker.nextNode())) {
    if (Filter$isAccept(matcher(current))) {
      last = current;
    } else if (pierceShadowRoot && current.shadowRoot) {
      const lastDescendantInShadowRoot = findLastDescendant(
        current.shadowRoot,
        pierceShadowRoot,
        matcher,
      );

      if (Result$isOk(lastDescendantInShadowRoot)) {
        last = Result$Ok$0(lastDescendantInShadowRoot);
      }
    } else if (pierceShadowRoot && current instanceof HTMLSlotElement) {
      const assignedNodes = current.assignedElements();

      for (let i = assignedNodes.length - 1; i >= 0; i--) {
        const assignedNode = assignedNodes[i];
        const lastDescendantInAssignedNode = findLastDescendant(
          assignedNode,
          pierceShadowRoot,
          matcher,
        );

        if (Result$isOk(lastDescendantInAssignedNode)) {
          last = Result$Ok$0(lastDescendantInAssignedNode);
        }
      }
    } else {
      last = current;
    }
  }

  return last ? Result$Ok(last) : Result$Error(undefined);
}
