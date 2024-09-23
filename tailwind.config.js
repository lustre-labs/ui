module.exports = {
  content: ["./src/**/*.{js,gleam}"],
  plugins: [require("./priv/static/tw.js")],
  theme: {
    extend: {
      transitionProperty: {
        height: "height",
      },
    },
  },
};
