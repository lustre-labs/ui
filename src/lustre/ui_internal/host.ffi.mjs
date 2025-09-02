export const add_event_listener = (shadow_root, name, handler) => {
  const host = shadow_root.host;

  if (host) {
    host.addEventListener(name, handler);
  }
};

export const set_role = (shadow_root, role) => {
  const host = shadow_root.host;

  if (host.internals) {
    host.internals.role = role;
  }
};
