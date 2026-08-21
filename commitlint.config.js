module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // ── Types ────────────────────────────────────────────────────────────────
    // Only the six A2SV-approved types are allowed.
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'chore', 'test', 'refactor'],
    ],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],

    // ── Scope (track) ────────────────────────────────────────────────────────
    // Scope is REQUIRED — every commit must declare which track it belongs to.
    'scope-enum': [
      2,
      'always',
      ['backend', 'web', 'mobile', 'content', 'docs', 'ci'],
    ],
    'scope-case': [2, 'always', 'lower-case'],
    'scope-empty': [2, 'never'], // scope cannot be omitted

    // ── Subject ──────────────────────────────────────────────────────────────
    // Short, present-tense, no trailing period.
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],

    // ── Body / footer ────────────────────────────────────────────────────────
    'body-leading-blank': [1, 'always'],
    'footer-leading-blank': [1, 'always'],
  },
};