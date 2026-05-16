import js from "@eslint/js";
import tseslint from "@typescript-eslint/eslint-plugin";
import tsparser from "@typescript-eslint/parser";

export default [
  js.configs.recommended,
  {
    files: ["**/*.ts", "**/*.tsx"],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
      },
      globals: {
        // Node.js globals
        console: "readonly",
        process: "readonly",
        Buffer: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
        global: "readonly",
        module: "readonly",
        require: "readonly",
        exports: "readonly",
        setTimeout: "readonly",
        clearTimeout: "readonly",
        setInterval: "readonly",
        clearInterval: "readonly",
        setImmediate: "readonly",
        clearImmediate: "readonly",
        // TypeScript globals
        NodeJS: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": tseslint,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      "@typescript-eslint/no-explicit-any": "warn",
      "@typescript-eslint/no-unused-vars": [
        "warn",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
        },
      ],
      "no-console": ["warn", { allow: ["warn", "error"] }],
      "no-restricted-imports": [
        "error",
        {
          paths: [
            {
              name: "axios",
              message: "Please use httpClient from '@/lib/http-client' or API modules from '@/api' instead of importing axios directly.",
            },
          ],
          patterns: [
            {
              group: ["axios"],
              message: "Please use httpClient from '@/lib/http-client' or API modules from '@/api' instead of importing axios directly.",
            },
          ],
        },
      ],
    },
  },
  {
    // Allow axios import in specific files
    files: [
      "**/lib/http-client.ts",
      "**/lib/http-client.test.ts",
      "**/__mocks__/axios.ts",
      "**/test/**/*.ts",
      "**/test/**/*.tsx",
    ],
    rules: {
      "no-restricted-imports": "off",
    },
  },
  {
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/.next/**",
      "**/coverage/**",
    ],
  },
];
