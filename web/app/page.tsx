import { Fraunces, Inter, IBM_Plex_Mono } from "next/font/google";

const fraunces = Fraunces({
  subsets: ["latin"],
  weight: ["400", "500", "600"],
  style: ["normal", "italic"],
  variable: "--font-display",
});
const inter = Inter({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-body",
});
const plexMono = IBM_Plex_Mono({
  subsets: ["latin"],
  weight: ["400", "500"],
  variable: "--font-mono",
});

export default function LandingPage() {
  return (
    <div className={`${fraunces.variable} ${inter.variable} ${plexMono.variable} afya-root`}>
      <style>{`
        .afya-root {
          --brand: #388E3C;
          --brand-dark: #1F5722;
          --brand-deep: #14361A;
          --brand-tint: #EAF6EC;
          --brand-soft: #A9D9AC;
          --ink: #12201A;
          --muted: #5C6B62;
          --paper: #FFFFFF;
          --mist: #F5FAF6;
          --line: #DCE9DD;
          font-family: var(--font-body);
          color: var(--ink);
          background: var(--paper);
          -webkit-font-smoothing: antialiased;
        }
        .afya-root .display {
          font-family: var(--font-display);
          letter-spacing: -0.01em;
        }
        .afya-root .mono {
          font-family: var(--font-mono);
          letter-spacing: 0.02em;
        }
        .thread {
          position: relative;
        }
        .thread::before {
          content: "";
          position: absolute;
          left: 50%;
          top: 0;
          bottom: 0;
          width: 1px;
          background: linear-gradient(to bottom, transparent, var(--line) 8%, var(--line) 92%, transparent);
          transform: translateX(-50%);
          z-index: 0;
        }
        @keyframes pulse-ring {
          0% { stroke-dashoffset: 251; }
          100% { stroke-dashoffset: 40; }
        }
        @keyframes fade-up {
          from { opacity: 0; transform: translateY(14px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes soft-cycle {
          0%, 28% { opacity: 1; transform: translateY(0); }
          33%, 100% { opacity: 0; transform: translateY(-6px); }
        }
        @keyframes soft-cycle-2 {
          0%, 28% { opacity: 0; transform: translateY(10px); }
          38%, 66% { opacity: 1; transform: translateY(0); }
          71%, 100% { opacity: 0; transform: translateY(-6px); }
        }
        @keyframes soft-cycle-3 {
          0%, 66% { opacity: 0; transform: translateY(10px); }
          72%, 100% { opacity: 1; transform: translateY(0); }
        }
        .fade-up { animation: fade-up 0.7s ease both; }
        .ring-anim { animation: pulse-ring 6s linear infinite; }
        .cycle-1 { animation: soft-cycle 6s ease-in-out infinite; }
        .cycle-2 { animation: soft-cycle-2 6s ease-in-out infinite; }
        .cycle-3 { animation: soft-cycle-3 6s ease-in-out infinite; }
        @media (prefers-reduced-motion: reduce) {
          .fade-up, .ring-anim, .cycle-1, .cycle-2, .cycle-3 {
            animation: none !important;
          }
          .cycle-1 { opacity: 1; }
          .cycle-2, .cycle-3 { display: none; }
        }
      `}</style>

      {/* NAV */}
      <header className="sticky top-0 z-40 border-b border-[var(--line)] bg-[var(--paper)]/90 backdrop-blur">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
          <a href="#top" className="flex items-center gap-2.5">
            <svg width="26" height="26" viewBox="0 0 26 26" fill="none">
              <path d="M13 2c4.5 4.8 7 8.6 7 12.3C20 19 16.9 22 13 22s-7-3-7-7.7C6 10.6 8.5 6.8 13 2Z" fill="var(--brand)" />
              <path d="M13 9v8M9.5 13h7" stroke="#fff" strokeWidth="1.6" strokeLinecap="round" />
            </svg>
            <span className="display text-[1.15rem] font-medium tracking-tight">AfyaMind</span>
          </a>
          <nav className="hidden items-center gap-8 text-[0.925rem] text-[var(--muted)] md:flex">
            <a href="#how" className="hover:text-[var(--ink)]">How it works</a>
            <a href="#roles" className="hover:text-[var(--ink)]">Roles</a>
            <a href="#consent" className="hover:text-[var(--ink)]">Consent model</a>
          </nav>
          <a
            href="#get-started"
            className="rounded-full bg-[var(--brand)] px-4.5 py-2 text-[0.9rem] font-medium text-white transition hover:bg-[var(--brand-dark)]"
            style={{ padding: "0.55rem 1.15rem" }}
          >
            Request a demo
          </a>
        </div>
      </header>

      {/* HERO */}
      <section id="top" className="relative overflow-hidden bg-[var(--mist)]">
        <div className="mx-auto grid max-w-6xl gap-14 px-6 py-20 md:grid-cols-2 md:items-center md:py-28">
          <div className="fade-up relative z-10">
            <span className="mono inline-block rounded-full border border-[var(--brand-soft)] bg-white px-3 py-1 text-[0.72rem] uppercase text-[var(--brand-dark)] shadow-sm">
              A clinical record patients actually control
            </span>
            <h1 className="display mt-6 text-[2.75rem] leading-[1.05] tracking-tight md:text-[3.4rem]">
              Care that
              <br />
              <span className="italic text-[var(--brand)]">asks first.</span>
            </h1>
            <p className="mt-6 max-w-md text-[1.05rem] leading-relaxed text-[var(--muted)]">
              AfyaMind connects patients, clinics, and doctors around one rule: no clinic sees a medical history until the patient says yes — every visit, every clinic, no exceptions.
            </p>
            <div className="mt-9 flex flex-wrap items-center gap-4">
              <a href="#get-started" className="rounded-full bg-[var(--brand)] px-6 py-3 text-[0.95rem] font-medium text-white shadow-sm transition hover:bg-[var(--brand-dark)]">
                Get started
              </a>
              <a href="#consent" className="text-[0.95rem] font-medium text-[var(--ink)] underline decoration-[var(--brand-soft)] decoration-2 underline-offset-4">
                See the consent flow
              </a>
            </div>
          </div>

          {/* SIGNATURE ELEMENT — live access-request mockup over image */}
          <div className="fade-up relative mx-auto w-full max-w-md md:ml-auto" style={{ animationDelay: "0.15s" }}>
            <div className="absolute -inset-6 z-0 hidden rounded-[2rem] shadow-2xl md:block">
              <img src="https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=1000" alt="Patient using app" className="h-full w-full rounded-[2rem] object-cover opacity-90" />
              <div className="absolute inset-0 rounded-[2rem] bg-gradient-to-tr from-[var(--brand-deep)]/40 to-transparent mix-blend-multiply" />
            </div>

            <div className="relative z-10 rounded-[1.4rem] border border-[var(--line)] bg-white/95 p-5 shadow-[0_20px_60px_-24px_rgba(20,54,26,0.5)] backdrop-blur-md md:translate-x-8 md:translate-y-8">
              <div className="mb-4 flex items-center justify-between">
                <span className="mono text-[0.7rem] uppercase text-[var(--muted)]">Access request</span>
                <span className="flex h-2 w-2 rounded-full bg-[var(--brand)]" />
              </div>

              <div className="relative h-[168px]">
                {/* state 1: request sent */}
                <div className="cycle-1 absolute inset-0">
                  <p className="text-[0.95rem] font-medium">Nazrēt General Clinic</p>
                  <p className="mt-1 text-[0.85rem] text-[var(--muted)]">requests access to your history</p>
                  <p className="mono mt-3 rounded-lg bg-[var(--brand-tint)] px-3 py-2 text-[0.78rem] text-[var(--brand-dark)]">
                    Reason: follow-up hypertension review
                  </p>
                  <div className="mt-5 flex items-center gap-3">
                    <svg width="34" height="34" viewBox="0 0 36 36">
                      <circle cx="18" cy="18" r="15.5" fill="none" stroke="var(--line)" strokeWidth="3" />
                      <circle cx="18" cy="18" r="15.5" fill="none" stroke="var(--brand)" strokeWidth="3" strokeLinecap="round" strokeDasharray="251" className="ring-anim" />
                    </svg>
                    <span className="mono text-[0.8rem] text-[var(--muted)]">expires in 04:32</span>
                  </div>
                </div>

                {/* state 2: approve / deny */}
                <div className="cycle-2 absolute inset-0">
                  <p className="text-[0.95rem] font-medium">Respond to request</p>
                  <p className="mt-1 text-[0.85rem] text-[var(--muted)]">Only you can approve, deny, or revoke.</p>
                  <div className="mt-6 flex gap-3">
                    <span className="flex-1 rounded-full bg-[var(--brand)] py-2.5 text-center text-[0.85rem] font-medium text-white shadow-sm">Approve</span>
                    <span className="flex-1 rounded-full border border-[var(--line)] py-2.5 text-center text-[0.85rem] font-medium text-[var(--muted)] bg-white">Deny</span>
                  </div>
                </div>

                {/* state 3: granted */}
                <div className="cycle-3 absolute inset-0">
                  <div className="flex items-center gap-2">
                    <span className="flex h-6 w-6 items-center justify-center rounded-full bg-[var(--brand)] shadow-sm">
                      <svg width="12" height="12" viewBox="0 0 12 12">
                        <path d="M2 6.2 4.8 9 10 2.5" fill="none" stroke="#fff" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" />
                      </svg>
                    </span>
                    <p className="text-[0.95rem] font-medium">Access granted</p>
                  </div>
                  <p className="mt-2 text-[0.85rem] text-[var(--muted)]">Full history shared with Nazrēt General Clinic.</p>
                  <p className="mono mt-5 text-[0.72rem] text-[var(--muted)]">Revoke anytime from your history screen.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* PRINCIPLE STATEMENT */}
      <section className="border-y border-[var(--line)] bg-white">
        <div className="mx-auto max-w-3xl px-6 py-16 text-center">
          <p className="display text-[1.5rem] italic leading-snug text-[var(--brand-deep)] md:text-[1.75rem]">
            &ldquo;Even the very first clinic a patient ever visits goes through the same request — there is no shortcut, and no standing access.&rdquo;
          </p>
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section id="how" className="thread bg-[var(--mist)] py-24">
        <div className="mx-auto max-w-6xl px-6">
          <div className="mx-auto max-w-lg text-center">
            <span className="mono text-[0.72rem] uppercase text-[var(--brand-dark)]">How tracking works</span>
            <h2 className="display mt-3 text-[2.1rem] tracking-tight">One loop, every day</h2>
          </div>

          <div className="mt-16 grid gap-10 md:grid-cols-4">
            {[
              { n: "01", t: "Doctor sets a plan", d: "Medication or vitals target, with a schedule — during an encounter, never floating.", img: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=400" },
              { n: "02", t: "Patient logs", d: "Taken, missed, or skipped with a reason — against a plan they never had to create themselves.", img: "https://images.unsplash.com/photo-1512805147242-c5e79473be82?auto=format&fit=crop&q=80&w=400" },
              { n: "03", t: "Reminders fire", d: "Push notification at T+0, a bounded snooze at T+10 and T+20, then it resolves on its own.", img: "https://images.unsplash.com/photo-1616423640778-28d1b50a2612?auto=format&fit=crop&q=80&w=400" },
              { n: "04", t: "Doctor reviews", d: "Adherence shows up in the next encounter — read-only, attributed, never edited after the fact.", img: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=400" },
            ].map((s) => (
              <div key={s.n} className="group relative z-10 overflow-hidden rounded-2xl border border-[var(--line)] bg-white p-6 transition-shadow hover:shadow-lg">
                <img src={s.img} alt={s.t} className="absolute inset-0 z-0 h-24 w-full object-cover opacity-10 transition-opacity group-hover:opacity-20" />
                <div className="relative z-10">
                  <span className="mono text-[0.8rem] text-[var(--brand)]">{s.n}</span>
                  <h3 className="display mt-3 text-[1.15rem]">{s.t}</h3>
                  <p className="mt-2 text-[0.9rem] leading-relaxed text-[var(--muted)]">{s.d}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* THE ENCOUNTER */}
      <section className="bg-white py-24">
        <div className="mx-auto grid max-w-6xl gap-14 px-6 md:grid-cols-2 md:items-center">
          <div>
            <span className="mono text-[0.72rem] uppercase text-[var(--brand-dark)]">The encounter</span>
            <h2 className="display mt-3 text-[2.1rem] tracking-tight">One visit. One record.</h2>
            <p className="mt-4 max-w-md text-[1rem] leading-relaxed text-[var(--muted)]">
              Vitals, labs, diagnosis, prescription, and the next appointment all attach to a single encounter — not five scattered entries a patient has to piece back together.
            </p>
            <ul className="mt-6 space-y-3 text-[0.92rem] text-[var(--ink)]">
              {["Vitals", "Lab results", "Diagnosis", "Prescription → tracked automatically", "Next appointment"].map((i) => (
                <li key={i} className="flex items-center gap-2.5">
                  <span className="h-1.5 w-1.5 rounded-full bg-[var(--brand)]" />
                  {i}
                </li>
              ))}
            </ul>
          </div>

          <div className="relative rounded-2xl p-6 md:p-8">
            <img src="https://images.unsplash.com/photo-1581056771107-24ca5f033842?auto=format&fit=crop&q=80&w=1000" alt="Modern clinic" className="absolute inset-0 h-full w-full rounded-3xl object-cover opacity-30 mix-blend-multiply" />
            <div className="relative z-10 rounded-2xl border border-[var(--line)] bg-[var(--mist)]/95 p-6 shadow-xl backdrop-blur-md">
              <div className="flex items-center justify-between border-b border-[var(--line)] pb-4">
                <div>
                  <p className="text-[0.95rem] font-medium">Encounter · Outpatient</p>
                  <p className="mono text-[0.75rem] text-[var(--muted)]">Aug 27, 2026 · 10:42</p>
                </div>
                <span className="mono rounded-full bg-[var(--brand-tint)] px-3 py-1 text-[0.7rem] text-[var(--brand-dark)]">open</span>
              </div>
              <div className="mt-4 space-y-3">
                {[
                  ["Vitals", "128/82 · 76bpm · 98% SpO2"],
                  ["Diagnosis", "Essential hypertension, controlled"],
                  ["Prescription", "Lisinopril 10mg — once daily"],
                  ["Appointment", "Follow-up in 4 weeks"],
                ].map(([k, v]) => (
                  <div key={k} className="flex items-start justify-between gap-4 text-[0.85rem]">
                    <span className="text-[var(--muted)]">{k}</span>
                    <span className="text-right font-medium">{v}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ROLES */}
      <section id="roles" className="bg-[var(--mist)] py-24">
        <div className="mx-auto max-w-6xl px-6">
          <div className="mx-auto max-w-lg text-center">
            <span className="mono text-[0.72rem] uppercase text-[var(--brand-dark)]">Built for three roles</span>
            <h2 className="display mt-3 text-[2.1rem] tracking-tight">Nothing implicit, nothing extra</h2>
            <p className="mt-3 text-[0.95rem] text-[var(--muted)]">
              Every non-patient role is capped to a fixed set of actions — on purpose.
            </p>
          </div>

          <div className="mt-16 grid gap-6 md:grid-cols-3">
            {[
              {
                role: "Patient",
                sub: "Mobile app",
                img: "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&q=80&w=200",
                d: "Self-registers, logs against doctor-set plans, and is the only one who can approve, deny, or revoke access.",
                items: ["Self-registration only", "Approve / deny / revoke access", "Read-only history"],
              },
              {
                role: "Clinic",
                sub: "Web dashboard",
                img: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=200",
                d: "Invites and manages its own doctors, and requests patient access directly — never through another clinic.",
                items: ["Invite & deactivate doctors", "Request patient access", "Track request status"],
              },
              {
                role: "Doctor",
                sub: "Web dashboard",
                img: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=200",
                d: "Exists only through an accepted clinic invite. Writes history strictly inside an encounter, for granted patients.",
                items: ["Open & close encounters", "Diagnosis & prescriptions", "Schedule appointments"],
              },
            ].map((r) => (
              <div key={r.role} className="rounded-2xl border border-[var(--line)] bg-white p-7 transition hover:border-[var(--brand-soft)] hover:shadow-[0_16px_40px_-28px_rgba(20,54,26,0.4)]">
                <div className="mb-4 flex items-center gap-4">
                  <img src={r.img} alt={r.role} className="h-12 w-12 rounded-full object-cover shadow-sm" />
                  <div>
                    <span className="mono text-[0.7rem] uppercase text-[var(--muted)]">{r.sub}</span>
                    <h3 className="display text-[1.4rem]">{r.role}</h3>
                  </div>
                </div>
                <p className="mt-3 text-[0.88rem] leading-relaxed text-[var(--muted)]">{r.d}</p>
                <ul className="mt-5 space-y-2.5 border-t border-[var(--line)] pt-5">
                  {r.items.map((i) => (
                    <li key={i} className="flex items-start gap-2 text-[0.85rem]">
                      <span className="mt-1.5 h-1 w-1 flex-shrink-0 rounded-full bg-[var(--brand)]" />
                      {i}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CONSENT MODEL DETAIL */}
      <section id="consent" className="bg-white py-24">
        <div className="mx-auto max-w-4xl px-6">
          <div className="text-center">
            <span className="mono text-[0.72rem] uppercase text-[var(--brand-dark)]">The access model</span>
            <h2 className="display mt-3 text-[2.1rem] tracking-tight">Five minutes, or it lapses</h2>
          </div>

          <div className="mt-14 grid gap-0 md:grid-cols-5">
            {[
              ["Request", "Clinic states a reason, while the patient is present."],
              ["Review", "Patient sees exactly who's asking, and why."],
              ["Decide", "Only the patient approves, denies, or lets it expire."],
              ["Grant", "The whole clinic gets full read + write, attributed."],
              ["Revoke", "Patient can pull access back, at any time."],
            ].map(([t, d], idx, arr) => (
              <div key={t} className="relative flex flex-col items-center px-3 text-center">
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[var(--brand-tint)] text-[0.8rem] font-medium text-[var(--brand-dark)] shadow-sm">
                  {idx + 1}
                </div>
                {idx < arr.length - 1 && (
                  <span className="absolute left-1/2 top-4.5 hidden h-px w-full -translate-y-1/2 bg-[var(--line)] md:block" style={{ left: "calc(50% + 18px)" }} />
                )}
                <p className="mt-3 text-[0.9rem] font-medium">{t}</p>
                <p className="mt-1.5 text-[0.78rem] leading-relaxed text-[var(--muted)]">{d}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section id="get-started" className="relative overflow-hidden py-28">
        <img src="https://images.unsplash.com/photo-1551076805-e1869033e561?auto=format&fit=crop&q=80&w=2000" alt="Tech background" className="absolute inset-0 h-full w-full object-cover" />
        <div className="absolute inset-0 bg-[var(--brand-deep)]/90 backdrop-blur-sm mix-blend-multiply" />

        <div className="relative z-10 mx-auto max-w-2xl px-6 text-center">
          <h2 className="display text-[2.2rem] tracking-tight text-white md:text-[2.6rem]">
            Bring your clinic onto AfyaMind
          </h2>
          <p className="mt-4 text-[1rem] text-white/80">
            A demo account gets you a working clinic, a doctor invite, and a patient to test the full consent loop end to end.
          </p>
          <div className="mt-9 flex flex-wrap items-center justify-center gap-4">
            <a href="#" className="rounded-full bg-white px-6 py-3 text-[0.95rem] font-medium text-[var(--brand-deep)] shadow-lg transition hover:bg-[var(--brand-tint)]">
              Request a demo
            </a>
            <a href="#how" className="text-[0.95rem] font-medium text-white/80 underline decoration-white/30 decoration-2 underline-offset-4 hover:text-white">
              Walk through the flow again
            </a>
          </div>
        </div>
      </section>

      {/* FOOTER */}
      <footer className="border-t border-[var(--line)] bg-white py-10">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-6 text-[0.82rem] text-[var(--muted)] md:flex-row">
          <div className="flex items-center gap-2">
            <svg width="18" height="18" viewBox="0 0 26 26" fill="none">
              <path d="M13 2c4.5 4.8 7 8.6 7 12.3C20 19 16.9 22 13 22s-7-3-7-7.7C6 10.6 8.5 6.8 13 2Z" fill="var(--brand)" />
            </svg>
            <span>AfyaMind — a demo clinical workflow, not a production system.</span>
          </div>
          <div className="flex gap-6">
            <a href="#how" className="hover:text-[var(--ink)]">How it works</a>
            <a href="#roles" className="hover:text-[var(--ink)]">Roles</a>
            <a href="#consent" className="hover:text-[var(--ink)]">Consent</a>
          </div>
        </div>
      </footer>
    </div>
  );
}