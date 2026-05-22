import baseConfig from "../../eslint.config.mjs";

export default [
  ...baseConfig,
  {
    files: ["scripts/**/*.ts"],
    rules: {
      "no-console": "off",
    },
  },
];
