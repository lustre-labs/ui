export function preventDefault(event) {
  if (event instanceof Event) {
    event.preventDefault();
  }
}

export function stopPropagation(event) {
  if (event instanceof Event) {
    event.stopPropagation();
  }
}
