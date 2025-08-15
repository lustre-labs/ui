export const reset_selection = (root) => {
  const input = root.querySelector("input.otp-input");

  input.selectionStart = input.selectionEnd = input.value.length;
};
