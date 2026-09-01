# Commit Convention — AfyaMind

> Every commit is enforced locally (pre-commit hook) and in CI (GitHub Actions).
> Commits that don't follow this format will be **rejected** at both stages.

---

## Pattern

```
type(track): short present-tense summary
```

| Part | Rules |
|------|-------|
| `type` | lowercase, one of the six types below |
| `track` | lowercase, one of the six tracks below — **required, never omit it** |
| `summary` | lowercase, present tense, no trailing period, ≤ 72 chars total |

---

## Types

| Type | When to use |
|------|-------------|
| `feat` | New behaviour the user can see or call |
| `fix` | Something broken, now correct |
| `docs` | README, API contract — no product behaviour change |
| `chore` | Tooling, `.gitignore`, CI — no product behaviour change |
| `test` | Tests only — no production code change |
| `refactor` | Same behaviour, clearer code |

## Tracks (scopes)

| Track | Covers |
|-------|--------|
| `web` | Next.js frontend (`/web`) |
| `backend` | Go API (`/backend`) |
| `mobile` | Flutter app (`/mobile`) |
| `docs` | Markdown docs, ADRs (`/docs`) |
| `api` | API specifications, contracts, Swagger (`/docs`, `/backend/docs`) |
| `content` | Static copy, resources, translations |
| `ci` | GitHub Actions, pre-commit, tooling config |

---

## Good examples

```
feat(web): show active listings on the map
fix(backend): stop a listing being reserved twice
docs(api): add pickup-code to the reserve response
chore(ci): run tests on every pull request
test(backend): cover the double-reserve edge case
refactor(web): extract map marker into its own component
```

## Bad examples — will be rejected

```
# ✗ No scope
feat: add map view

# ✗ Wrong scope (not in the list)
fix(frontend): button color

# ✗ Type not in the list
update(web): tweak styles

# ✗ Capital letter in summary
feat(web): Add map view

# ✗ Trailing period
fix(backend): stop double-reserve.

# ✗ Past tense
feat(mobile): added crisis helpline screen
```

---

## Local setup

Make sure you have **Python** and **Node.js** installed on your system, then run:

```bash
pip install pre-commit
# Installs the pre-commit checks (whitespace, EOF, yaml syntax, etc.)
pre-commit install
# Installs the commit message linter
pre-commit install --hook-type commit-msg
```

The hooks run automatically on every `git commit`.
If your message is invalid you will see a clear error before the commit is created.

---

## CI enforcement

The [`commitlint.yml`](.github/workflows/commitlint.yml) workflow checks **every commit** in a pull request.
A PR with even one non-conforming commit message will not be mergeable.
