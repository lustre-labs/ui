export function setTimeout(after, callback) {
  return window.setTimeout(callback, after);
}

export function cancelTimeout(timeoutId) {
  window.clearTimeout(timeoutId);
}
