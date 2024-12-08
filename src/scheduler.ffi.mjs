/**
 * @param {() => void} k - A microtask to schedule before the DOM is next painted.
 */
export const before_paint = (k) => {
  window.queueMicrotask(k);
};

/**
 * @param {(timestamp: number) => void} k - A callback to schedule after the DOM
 * has been painted.
 */
export const after_paint = (k) => {
  window.requestAnimationFrame(k);
};
