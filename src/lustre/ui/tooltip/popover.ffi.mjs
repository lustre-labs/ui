import {
  computePosition,
  offset,
  shift,
  flip,
} from "../../../lustre_ui/vendor/floating_ui/dom.ffi.mjs";

export function showPopover(popover, offset, side, align, dispatch) {
  popover.showPopover();

  calculatePosition(popover, offset, side, align, dispatch, true);
}

export function calculatePosition(
  popover,
  offset_amount,
  side,
  align,
  dispatch,
  open = false,
) {
  const root = popover.closest("lustre-tooltip");
  const trigger = root?.querySelector("lustre-tooltip-trigger");

  if (!root || !trigger) return;
  if (!open) {
    popover.showPopover();
  }

  const middleware = [offset(offset_amount)];
  const flipMiddleware = flip({
    crossAxis: "alignment",
    fallbackAxisSideDirection: "end",
  });
  const shiftMiddleware = shift();

  if (align) {
    middleware.push(flipMiddleware, shiftMiddleware);
  } else {
    middleware.push(shiftMiddleware, flipMiddleware);
  }

  const placement = align ? `${side}-${align}` : side;

  computePosition(trigger, popover, { middleware, placement }).then(
    ({ x, y }) => {
      dispatch(x, y);

      if (!open) {
        popover.hidePopover();
      }
    },
  );
}

export function hidePopover(popover) {
  Promise.all(popover.getAnimations().map((a) => a.finished))
    .then(() => popover.hidePopover())
    .catch(() => {});
}
