# Task Brief — Bonny (Dev B): Doctor Invitations & Super Admin Clinic Management + Access Requests

**Repo:** `A2SV-ASTU/Afya`, `backend/` (Go, Gin, Postgres). **Scope:** backend only. This brief is grounded in the four spec docs (ERD, PRD, API Contract, Workflows, Roadmap) *and* the actual current state of the cloned repo — not just the docs, since the docs disagree with each other and with the code in several places (Section 1).

---

## 0. Your scope — touch only these

**Own and edit freely:**
- `backend/src/invitations/` (full rewrite — see Section 1.A, current code is stale)
- `backend/src/access-requests/` (new — currently just a README stub)
- Three endpoints inside `backend/src/clinics/`: `POST /clinics`, `GET /clinics`, `PATCH /clinics/:id/deactivate` (super_admin-scoped only)
- A new migration file for `doctor_invitations` and `access_requests` tables
- Additive wiring in `backend/cmd/api/main.go` (repos/services/handlers/routes for your packages only)

**Do NOT touch:**
- `auth/`, `users/`, `token/` (Dev A, done)
- The rest of `clinics/`: `GET /clinics/:id`, `GET /clinics/:clinicId/doctors`, `GET /clinics/:clinicId/invitations` — these are clinic_admin-scoped and owned by a teammate (Dev C in the roadmap's feature table). Same package folder, different owner — see the conflict in 1.B before writing any shared `clinics/` file.
- `encounters/`, `clinical-evaluations/`, `vitals/`, `labs/`, `diagnoses/`, `prescriptions/`, `appointments/` — all downstream of your access-request guard but not yours to build. They only need your guard to be importable.

---

## 1. Read this before writing code — real conflicts I found across the docs and the repo

I cross-checked the ERD, PRD, Workflows, Roadmap, API Contract, *and* your actual repo against each other. These aren't nitpicks — they change what you'd actually build. Get sign-off from whoever owns the contract/roadmap before committing to an interpretation.

### 1.A ⚠️ Biggest one: two contradictory doctor-onboarding models in the source docs

- **Model B (token invite/accept)** — ERD has a `doctor_invitations` table (`clinic_id, email, token, status: pending/accepted/expired/revoked, expires_at`) and `users.invited_by`. PRD §4/§6/§11 and the Workflows doc (Ch. 2–3, in full narrative detail: "Invite Doctor" button → emailed link → doctor clicks, sets password + license info, submits, instantly logged in) both describe this. The Roadmap's entire `invitations/` package plan (`POST /clinics/:clinicId/invitations`, `POST /invitations/:token/accept`, `doctor-invitations.jobs.go`) is Model B. The contract's own Conventions section and cross-cutting rule table also reference `doctor-invitations.jobs.go` and a public `POST /invitations/:token/accept` route.
- **Model A (direct creation)** — API Contract §4 "Doctor Accounts" explicitly describes a *different* mechanism: `POST /clinics/:clinicId/doctors` creates the doctor account immediately, server generates a random temp password, emails it, doctor logs in via normal `/auth/login`. It states in plain text: **"No dedicated invite/accept endpoint or token flow is needed."**

These can't both be right. 4 of 5 documents (ERD, PRD, Workflows, Roadmap) converge on Model B; the contract's §4 prose is the outlier, and it even conflicts with the *rest of the same contract* (the Conventions line and cross-cutting table both assume Model B exists). **Your actual repo has already committed to Model B** — `src/invitations/` exists with token/accept mechanics; there's no `clinics/doctors` direct-create code anywhere.

**Recommendation:** build Model B (token invite/accept), matching your repo's existing direction and the majority of the docs. But flag §4 of the contract as stale/superseded — the same way the roadmap already flags the `/ecnouters/` typo and the medication-logs mismatch — rather than silently picking a side. Don't build both.

### 1.B `clinics/` package ownership disagrees across the roadmap's own sections

The roadmap's **Feature descriptions (§3)** — the section titled exactly like your two assignments — explicitly says the 3 super_admin routes (`POST /clinics`, `GET /clinics`, `PATCH /clinics/:id/deactivate`) were **"moved from Clinics"** to you, while the clinic_admin routes stay with Dev C (Rebira). But:
- §2 Team Structure table credits the whole `clinics/` package to Dev A (Merga).
- §4's endpoint checklist lists all 6 clinics endpoints under "Clinics — Dev C."
- The Round-based plan (Round 2) gives Dev C all 6 endpoints, and your Round 3 task list never mentions `POST/GET /clinics` at all.
- Your repo's `clinics/README.md` also lists all 7 endpoints (including the doctor-deactivate one) as one undivided package with no ownership split reflected in code yet.

Three different owners are named for the same three endpoints depending which section you read. **Confirm with your team lead/Dev A/Dev C before writing to `clinics/`** — you're about to add code to a shared package directory (`handler.go`, `routes.go`, `repository.go`, `dto.go` likely need one shared file per the roadmap's "one service/repo/routes per feature" convention), and stepping on it without confirming is exactly the "touching someone else's work" risk you flagged.

### 1.C Non-obvious but load-bearing: how "revoked" actually works

`access_requests.status` in the ERD is only `pending | approved | denied | expired` — **there is no `revoked` status value.** The contract's revoke response confirms this isn't a typo: `{ "status": "approved", "revoked_at": "<timestamp>" }`. So an "active grant" = `status == 'approved' AND revoked_at IS NULL`. Your guard (`access-requests.guard.go`) and the revoke endpoint both need to check/set it this way — don't invent a `revoked` enum value, and don't treat `status` alone as sufficient for the guard check.

### 1.D Smaller things worth a quick confirm, not blockers

- **Notification channel:** Roadmap v2 and the contract are explicit and internally consistent — access-request approve/deny is **email-only** now (`GET /patients/me/access-requests` was deliberately removed). The Workflows doc (Ch. 5, Appendix B) still describes it as a push notification the patient acts on in-app. Treat the Roadmap/Contract's email model as current; the Workflows doc reads like it predates that pivot.
- **Invitation cancel/resend:** Workflows Ch. 2 describes the clinic being able to resend an expired invite or cancel a pending one before it's used, and the ERD's `revoked` status on `doctor_invitations` supports this — but no such endpoint appears in the Roadmap or Contract. Ask whether this is in scope for the 3-week MVP or deliberately cut; don't build it speculatively.
- **`clinic_admin` password at clinic creation:** the Contract/Roadmap have `POST /clinics` take `admin_password` directly in the request body (super_admin sets it). The Workflows doc (Ch. 1) instead describes the admin getting a "set your password" email link. Contract + Roadmap agree with each other here, so treat the direct-password version as authoritative and the Workflows chapter as a simplified narrative.
- **ERD gap on `users.invited_by`:** it's an FK to `users.id` (i.e., which admin invited this doctor), but the ERD's `doctor_invitations` table has no column recording who created the invitation. You'll likely need to add one (`created_by` or `invited_by` on `doctor_invitations`) in your migration — flag this addition explicitly since it's a schema change beyond what's drawn.

---

## 2. Current repo state for what you own (read before writing)

I cloned the repo and checked. This is more useful than "build from the roadmap" because the existing code is further from done than the roadmap implies.

**`src/invitations/` exists but is pre-pivot leftover code, not a partial implementation of your feature. Plan for a rewrite, not a refactor:**
- `model.go` defines `AdminInvitation{ID int64, UserID int64, TokenHash, ExpiresAt, UsedAt, CreatedAt}` — wrong shape entirely (no `ClinicID`, no `Email`, no `Status` enum; `int64` IDs instead of `uuid.UUID`).
- `routes.go` registers `POST /admin/invitations` and `POST /admin/invitations/accept` — wrong paths (need `POST /clinics/:clinicId/invitations` and `POST /invitations/:token/accept`), wrong role guard (`RequireSuperAdmin()` instead of clinic_admin-own-clinic).
- `repository.go` queries columns that **don't exist in the current schema** — `name`, `status`, `age_attested_18` on `users` — these are pre-pivot mental-health-app columns. This code would fail at runtime against the actual `users` table (`first_name/last_name/role` enum, no `status`, no `age_attested_18`).
- Migration `000002_admin_invitations.up.sql` creates `admin_invitations.user_id BIGINT REFERENCES users(id)` — but `users.id` is `UUID`. **This is a broken foreign key type mismatch as written.**
- Net effect: don't try to salvage this package incrementally. Design the correct `doctor_invitations` table/model/routes per Section 1.A and 3, then replace this package's contents, including retiring migration `000002` (via a new migration, coordinate with whoever owns migration sequencing before dropping anything already applied to a shared dev DB).

**`src/access-requests/` and `src/clinics/` are just README stubs — no code yet.** You're building from scratch here, which is simpler than invitations/.

**Reusable infra already in place — don't rebuild these:**
- `shared/email.Sender` + `email.LoadSMTPConfig()` (SMTP-based, reads `SMTP_HOST/PORT/USERNAME/PASSWORD/FROM_EMAIL` env vars) — already used by the old invitations code, wire it into both your invitation emails and access-request emails. The Roadmap's "New dependency: outbound email, not yet owned by anyone" risk is already resolved in code.
- `shared/errors` — `ErrForbiddenGrant()`, `ErrNotFound()`, `ErrConflict()`, `ErrExpired()` (410), `ErrValidationError()` etc. already match the contract's error-code table exactly. Use these, don't redefine.
- `shared/response` — `response.JSON`, `response.List`, `response.RespondAppError` already implement the contract's envelope conventions.
- `shared/middleware.RequireAuth(jwtSecret)` and `RequireRole(roles ...string)` already exist and work off the `access_token` cookie.
- `database.WithTransaction(ctx, db, func(tx database.DBTX) error {...})` — use this for `POST /clinics` (must create `Clinic` + `clinic_admin` `User` atomically).

**Gap you'll hit immediately:** JWT claims (`token.Claims`) only carry `UserID` and `Role` — **no `clinic_id`**. Every one of your "own clinic" checks (clinic_admin managing their invitations, submitting/revoking access requests, viewing their clinic's access-request list) needs the caller's `clinic_id`, which isn't in the token. You'll need to look it up from `users` (e.g. via `users.Repository.FindByID`) inside your services, or propose adding `clinic_id` to the claims (touches `token/` and `auth/`, which are Dev A's — ask before changing).

---

## 3. Feature A — Doctor Invitations & Super Admin Clinic Management

### Endpoints you own

| Method & Path | Role | Notes |
|---|---|---|
| `POST /clinics` | super_admin | Creates `Clinic` + `clinic_admin` `User` in one transaction. Body: `{name, email, phone, address, admin_first_name, admin_last_name, admin_password}`. `409 clinic_email_already_registered` on dup. |
| `GET /clinics` | super_admin | Lists all clinics, no pagination in the contract as written. |
| `PATCH /clinics/:id/deactivate` | super_admin | Sets `status=deactivated`. `409` if already deactivated. Doctors/encounters underneath stay intact and keep working read-wise; they just can't log in / act. |
| `POST /clinics/:clinicId/invitations` | clinic_admin (own clinic only) | Creates a `doctor_invitations` row: `clinic_id`, `email`, a raw token (emailed, never stored in plaintext — hash it, e.g. SHA-256 like the old code did), `expires_at` **hard-capped server-side at 24h regardless of any client input**, `status=pending`. |
| `POST /invitations/:token/accept` | Public (no auth — the token *is* the auth) | Body needs at minimum `password`, plus doctor-specific fields the Workflows doc calls out: `license_number`, `specialization`, presumably `first_name/last_name` (contract has no literal schema for this route — see 1.A — so you're designing this shape; base it on `doctor_invitations` + the `users` doctor fields). On success: create the `User` row (`role=doctor`, `clinic_id` from invitation, `invited_by` = whoever created the invitation), flip invitation `status=accepted`, `accepted_at=now()`, and log the doctor in (issue cookie) — same one-shot pattern Workflows Ch.3 describes ("three things happen together as one unit"). Wrap in a transaction. `404` invalid token, `410`/`409` expired or already-used token. |
| `PATCH /clinics/:clinicId/doctors/:doctorId/deactivate` | clinic_admin (own clinic) | Sets `doctor_status=deactivated` on the target user. Doctor loses login/write ability; past entries stay attributed and intact. `409` if already deactivated, `404` if doctor not found or not in this clinic. |

### Business rules to enforce
- `expires_at` on invitations is capped at 24h **server-side**, never trust a client-supplied value.
- A `doctor_invitations.jobs.go`-style reconciliation (can be a simple scheduled function, doesn't need a real job queue for the MVP) must flip any `pending` row past `expires_at` to `expired` — don't rely on read-time checks alone, since the cross-cutting rule table calls this out explicitly as "server-authoritative regardless of what the client sends."
- No `DELETE` anywhere — deactivation only.
- `clinic_admin` scoping: every invitation/doctor-deactivate route must verify the caller's `clinic_id` matches the `:clinicId` in the path (`403 not_own_clinic`), not just that they hold the `clinic_admin` role.

---

## 4. Feature B — Access Requests

### Endpoints you own

| Method & Path | Role | Notes |
|---|---|---|
| `GET /patients/lookup?email=` | clinic_admin (own clinic) | Exact-email lookup, returns `{id, first_name, last_name, email}` only — **no clinical data, ever, even implicitly**, since this happens before any grant exists. `404 patient_not_found`. |
| `POST /access-requests` | clinic_admin or doctor (own clinic) | Body: `{patient_id, reason}`. `submitted_by_doctor_id` recorded for audit even when a clinic_admin submits (use the calling doctor's id if a doctor called it, otherwise presumably null or the admin — contract doesn't fully spell this out, confirm). `expires_at = now()+5min`, hard-capped server-side. On success, send the approve/deny email — this is the *only* way the patient learns of it (no in-app list). |
| `POST /access-requests/:id/approve` | patient (must be the target) | `403 not_target_patient` if not theirs. `409` if not pending, `410` if expired. Grants full history immediately, not a preview. |
| `POST /access-requests/:id/deny` | patient (target) | Same shape as approve, sets `status=denied`. |
| `POST /access-requests/:id/revoke` | clinic_admin | Only valid on a currently `approved` request (`409 access_request_not_approved` otherwise). Sets `revoked_at`, **leaves `status=\"approved\"` unchanged** (see 1.C). Revokes clinic-wide, not per-doctor. |
| `GET /clinics/:clinicId/access-requests?status=` | clinic_admin, doctor (own clinic) | Own-clinic history, optional status filter. |

### The guard (this is the critical-path piece — everything downstream depends on it)
`access-requests.guard.go` — export a Gin middleware other packages (`encounters`, `vitals`, `labs`, `diagnoses`, `prescriptions`, `appointments`) import directly. It must:
1. Resolve the calling doctor's `clinic_id` (see the JWT-claims gap in Section 2).
2. Look up whether an `access_requests` row exists with `requesting_clinic_id = <that clinic>`, `patient_id = <target patient>`, `status = 'approved'`, `revoked_at IS NULL`.
3. Key the check on **`clinic_id`, not `doctor_id`** — every doctor at a clinic shares the same grant, this is explicit in both the PRD and the roadmap's "rules most likely to get missed" list.
4. Return `403 forbidden_grant` (already defined in `shared/errors`) if no active grant.

### Business rules to enforce
- `expires_at` capped at 5 minutes server-side, same "never trust the client" rule as invitations.
- A reconciliation pass (`access-requests.jobs.go`) flips stale `pending` rows to `expired` — this matters because `approve` must still fail with `410` even if it's hit after the window lapses but before the job runs; don't rely solely on the job, check `expires_at` at approve/deny time too.
- No standing/automatic grants ever, including a patient's very first clinic — every request goes through this flow, no exceptions (PRD §5.2, Workflows Ch. 5/10/12).

---

## 5. Suggested build order

Matches the Roadmap's Round 3, adjusted for what's actually in the repo:

1. Resolve the two conflicts in 1.A and 1.B with your team before writing code that depends on the answer — everything else here assumes Model B and that the 3 super_admin `clinics/` endpoints are yours.
2. New migration: replace the broken `admin_invitations` table with a correct `doctor_invitations` table (UUID FKs, `clinic_id`, `email`, `token_hash`, `status` enum `pending/accepted/expired/revoked`, `expires_at`, `accepted_at`, `created_at`, plus whatever column you add for "who created it" per 1.D) and a new `access_requests` table matching the ERD.
3. Rewrite `src/invitations/` end to end (model/dto/handler/service/repository/routes) against the new schema and correct paths.
4. `PATCH /clinics/:clinicId/doctors/:doctorId/deactivate` — needs Round 2's real clinics to exist to test against.
5. Build your 3 `clinics/` super_admin endpoints (coordinate on the shared files first).
6. Build `access-requests/`, guard last-in-file-but-first-in-priority — everything from Rounds 4–7 (other devs) is blocked on `access-requests.guard.go` merging, so don't let this slip.
7. Wire everything into `cmd/api/main.go` additively.

---

## 6. Definition of done
- [ ] Model A vs B conflict (1.A) resolved and documented in a PR comment or commit message, not just assumed
- [ ] `clinics/` ownership (1.B) confirmed with Dev A/Dev C before merging
- [ ] All new/changed routes match contract paths exactly (including the correctly-spelled ones where the source contract has typos elsewhere in the project — not your endpoints, but stay consistent with that convention)
- [ ] `expires_at` on both invitations (24h) and access requests (5min) is enforced server-side regardless of client input
- [ ] Grant guard keys on `clinic_id`, not `doctor_id`
- [ ] Revoke sets `revoked_at` without inventing a `revoked` status value
- [ ] `GET /patients/lookup` returns identity fields only, never clinical data
- [ ] No `DELETE` verb anywhere in your routes
- [ ] Old `admin_invitations`/pre-pivot code fully removed, not left dead
- [ ] Emails (invitation + access-request) actually send via `shared/email.Sender` in dev, with a graceful log-only fallback when SMTP env vars are unset (matches existing pattern)
