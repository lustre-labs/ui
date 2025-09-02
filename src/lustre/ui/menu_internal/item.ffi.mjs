export const add_click_handler = (shadowRoot, callback) => {
  const host = shadowRoot.host;

  host.addEventListener("click", callback);
};

export const set_aria_checked = (shadowRoot, checked) => {
  const host = shadowRoot.host;

  if (host.internals) {
    host.internals.ariaChecked = checked;
  }
};
