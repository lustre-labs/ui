export function getComponentElement(shadowRoot) {
  return shadowRoot.host;
}

export function addEventListener(element, name, handler) {
  element.addEventListener(name, handler);
}
