// import base from '@staplify/eslint-config/base'
// import globals from 'globals'

// export default [
//   ...base,
//   {
//     ignores: ['eslint.config.mjs'],
//   },
//   {
//     files: ['**/*.ts'],
//     languageOptions: {
//       globals: {
//         ...globals.node,
//         ...globals.jest,
//       },
//       parserOptions: {
//         projectService: true,
//         tsconfigRootDir: import.meta.dirname,
//       },
//     },
//     settings: {
//       'import/resolver': {
//         typescript: {
//           project: './tsconfig.json',
//         },
//       },
//     },
//     rules: {
//       '@typescript-eslint/no-explicit-any': 'off',
//       '@typescript-eslint/no-floating-promises': 'warn',
//       '@typescript-eslint/no-unsafe-argument': 'warn',
//     },
//   },
// ]

// apps/api/eslint.config.js
import base from '@staplify/eslint-config/base'
import globals from 'globals'

export default [
  ...base,
  {
    ignores: ['eslint.config.mjs'],
  },
  {
    // Config pour les fichiers src/
    files: ['src/**/*.ts'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest,
      },
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    settings: {
      'import/resolver': {
        typescript: {
          project: './tsconfig.json',
        },
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-floating-promises': 'warn',
      '@typescript-eslint/no-unsafe-argument': 'warn',
    },
  },
  {
    // Config spéciale pour les tests (sans projectService)
    files: ['test/**/*.ts'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest,
      },
      parserOptions: {
        project: null, // ✅ Pas de type checking strict
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
    rules: {
      // Rules plus relaxées pour les tests
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/no-unused-vars': 'off',
    },
  },
]
