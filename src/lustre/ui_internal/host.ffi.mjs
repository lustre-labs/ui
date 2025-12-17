export const inject_unique_id = (component_name) => {
  const component = window.customElements.get(component_name);

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

export const add_event_listener = (shadow_root, name, handler) => {
  const host = shadow_root.host;

  if (host) {
    host.listeners ??= {};
    host.listeners[name] = handler;
    host.addEventListener(name, handler);
  }
};

export const remove_event_listener = (shadow_root, name) => {
  const host = shadow_root.host;

  if (host && host.listeners?.[name]) {
    host.removeEventListener(name, host.listeners[name]);
    delete host.listeners[name];
  }
};

export const set_tabindex = (shadow_root, index) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.tabIndex = index;
  }
};

export const set_role = (shadow_root, role) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.role = role;
  }
};

export const set_aria_has_popup = (shadow_root, value) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.ariaHasPopup = value;
  }
};

export const set_aria_expanded = (shadow_root, value) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.ariaExpanded = value;
  }
};

export const set_aria_controls = (shadow_root, value) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.ariaControls = [value];
  }
};
