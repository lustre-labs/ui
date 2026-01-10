// QUERIES ---------------------------------------------------------------------

export function animate(shadowRoot, open, dispatch) {
  if (!(shadowRoot instanceof ShadowRoot)) return;

  const panel = shadowRoot.host;

  if (open) {
    dispatch([`${panel.scrollWidth}px`, `${panel.scrollHeight}px`]);

    window.requestAnimationFrame(() => {
      Promise.all(panel.getAnimations().map((a) => a.finished))
        .then(() => dispatch(["auto", "auto"]))
        .catch(() => {});
    });
  } else {
    dispatch([`${panel.scrollWidth}px`, `${panel.scrollHeight}px`]);

    window.requestAnimationFrame(() => {
      dispatch(["0px", "0px"]);
    });
  }
}
