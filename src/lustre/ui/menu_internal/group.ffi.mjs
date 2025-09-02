export const inject_id = (name) => {
  const component = window.customElements.get(name);

  if (component) {
    Object.defineProperty(component.prototype, "group-id", {
      enumerable: true,
      get() {
        return (
          this._group_id ??
          (this._group_id = `group-${window.crypto.randomUUID()}`)
        );
      },
    });
  }
};
