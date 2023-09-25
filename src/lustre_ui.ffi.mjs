export function scroll_into_view(
  selector,
  behaviour = "smooth",
  block = "start"
) {
  document.querySelector(selector)?.scrollIntoView({ behaviour, block });
}

export function focus(selector) {
  document.querySelector(selector)?.focus();
}
