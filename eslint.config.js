// =====================================================================
// ESLint flat config · template workflow-base
// =====================================================================
// Set mínimo de 4 reglas (anti-pattern "no sobre-configurar"). El preset
// completo de eslint-config-next o eslint-config-airbnb genera cientos
// de errores legacy que bloquean CI sin agregar valor en proyectos
// nuevos. Las reglas estrictas se agregan gradualmente conforme se
// limpia el codebase del adopter.
// =====================================================================

const tseslint = require('typescript-eslint')
const reactPlugin = require('eslint-plugin-react')
const importPlugin = require('eslint-plugin-import')
// @next/next plugin registrado SIN reglas activas: necesario para que
// las directivas `// eslint-disable-next-line @next/next/no-img-element`
// que el codebase pueda heredar de presets previos sean válidas. Sin
// esto, ESLint reporta "Definition for rule was not found" como error
// y rompe el job. Activar reglas concretas opt-in según necesidad.
const nextPlugin = require('@next/eslint-plugin-next')
const globals = require('globals')

const minimalRules = {
  '@typescript-eslint/no-unused-vars': [
    'warn',
    {
      argsIgnorePattern: '^_',
      varsIgnorePattern: '^_',
      caughtErrorsIgnorePattern: '^_',
    },
  ],
  'react/jsx-key': 'error',
  'import/no-duplicates': 'warn',
  // 'import/order' opt-in cuando el codebase tenga import order consistente.
}

module.exports = [
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: { sourceType: 'module' },
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      '@typescript-eslint': tseslint.plugin,
      react: reactPlugin,
      import: importPlugin,
      '@next/next': nextPlugin,
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: minimalRules,
  },
  {
    files: ['**/*.{js,jsx,mjs,cjs}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      react: reactPlugin,
      import: importPlugin,
      '@next/next': nextPlugin,
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: {
      'react/jsx-key': 'error',
      'import/no-duplicates': 'warn',
    },
  },
  {
    // linterOptions.reportUnusedDisableDirectives: false — tolera directivas
    // `// eslint-disable-next-line <rule>` que apunten a reglas no activas
    // en el set mínimo. Útil cuando el codebase hereda directivas de
    // presets más estrictos. Cerrar a `true` cuando el set de reglas
    // activas se estabilice.
    linterOptions: {
      reportUnusedDisableDirectives: false,
    },
  },
  {
    ignores: [
      '.next/**',
      'out/**',
      'build/**',
      'next-env.d.ts',
      'node_modules/**',
      'tests/manual/**',
      'tests/test-results/**',
      'playwright-report/**',
      '.husky/**',
      'docs/**', // demos JSX + HTML + design references no entran a CI
      'public/**',
    ],
  },
]
