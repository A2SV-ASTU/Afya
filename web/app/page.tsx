import { Manrope, Plus_Jakarta_Sans } from "next/font/google";
import {
  Activity, Calendar, FileText, Lock, Shield,
  Stethoscope, User, ShieldCheck, WifiOff, FileCheck, ShieldAlert, Download
} from "lucide-react";
import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";

const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-manrope",
});

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-jakarta",
});

export default function LandingPage() {
  return (
    <div className={`${manrope.variable} ${plusJakarta.variable} min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]`}>
      <LandingNavbar />

      {/* HERO SECTION */}
      <section className="relative overflow-hidden bg-[var(--color-canvas)]">
        {/* Background Image / Overlay - Semi-transparent, blended */}
        <div className="absolute inset-0 z-0">
          <img
            src="https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&q=80&w=2000"
            alt="Secure clinical workspace"
            className="h-full w-full object-cover opacity-[0.12] mix-blend-multiply"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-[var(--color-canvas)]/30 via-transparent to-[var(--color-canvas)]" />
        </div>

        <div className="mx-auto flex min-h-[600px] max-w-[1280px] flex-col justify-center px-6 py-20 md:px-10 lg:flex-row lg:items-center lg:justify-between">

          {/* Hero Content */}
          <div className="relative z-10 max-w-2xl lg:w-1/2">
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-[var(--color-main-border)] bg-white/60 px-4 py-1.5 backdrop-blur-md shadow-sm">
              <ShieldCheck className="h-4 w-4 text-[var(--color-main)]" />
              <span className="font-manrope text-xs font-semibold uppercase tracking-wider text-[var(--color-main-dark)]">Patient-Centric Care</span>
            </div>

            <h1 className="font-manrope text-4xl font-bold leading-tight tracking-tight text-gray-900 md:text-5xl lg:text-6xl">
              Your Digital Healthcare Assistant
            </h1>

            <p className="mt-6 text-lg font-normal leading-relaxed text-gray-600 md:text-xl">
              Seamlessly manage medication adherence, track clinical history, and take control of your health journey with our institutional-grade secure platform.
            </p>

            <div className="mt-10 flex flex-col gap-4 sm:flex-row">
              <a href="#get-started" className="flex items-center justify-center rounded-lg bg-[var(--color-main)] px-8 py-4 font-manrope text-base font-semibold text-white transition-colors hover:bg-[var(--color-main-hover)] shadow-md">
                Get Started
              </a>
              <a href="#download-app" className="flex items-center justify-center gap-2 rounded-lg border-2 border-[var(--color-main)] bg-white/80 px-8 py-4 font-manrope text-base font-semibold text-[var(--color-main)] transition-colors hover:bg-[var(--color-main-subtle)] backdrop-blur-sm">
                <Download className="h-5 w-5" />
                Download App
              </a>
            </div>
          </div>

          {/* Hero Floating Card (Glassmorphism) */}
          <div className="relative z-10 mt-16 hidden lg:block lg:w-5/12">
            <div className="relative mx-auto w-full max-w-sm rounded-[24px] border border-[var(--color-main-border)] bg-white/80 p-6 shadow-[0_8px_32px_rgba(56,142,60,0.1)] backdrop-blur-md">

              <div className="mb-6 flex items-center gap-4">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--color-main)] text-white shadow-sm">
                  <span className="font-manrope text-xl font-bold">B</span>
                </div>
                <div>
                  <h3 className="font-manrope text-lg font-bold text-gray-900">Amoxicillin</h3>
                  <p className="text-sm text-gray-500">500mg • 2x Daily</p>
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between rounded-xl bg-white p-4 shadow-sm border border-[var(--color-main-border)]">
                  <span className="font-medium text-gray-700">Morning Dose</span>
                  <div className="flex items-center gap-2 rounded-full bg-[var(--color-main-subtle)] px-3 py-1 text-sm font-semibold text-[var(--color-main)]">
                    <Activity className="h-4 w-4" />
                    Taken
                  </div>
                </div>
                <div className="flex items-center justify-between rounded-xl border border-[var(--color-main-border)] bg-white p-4 shadow-sm">
                  <span className="font-medium text-gray-700">Evening Dose</span>
                  <span className="font-manrope font-semibold text-amber-600">8:00 PM</span>
                </div>
              </div>

              {/* Animated Live Status Indicator */}
              <div className="mt-8 flex flex-col items-center justify-center h-24 w-full rounded-xl bg-[var(--color-canvas)]/50 border border-[var(--color-main-light)]">
                 <div className="relative flex h-12 w-12 items-center justify-center">
                    <div className="absolute h-full w-full animate-ping rounded-full bg-[var(--color-main-light)] opacity-75"></div>
                    <div className="relative flex h-4 w-4 items-center justify-center rounded-full bg-[var(--color-main)]"></div>
                 </div>
                 <span className="mt-3 text-xs font-bold tracking-wide uppercase text-[var(--color-main)]">Live Sync Active</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CORE FEATURES (TOP) */}
      <section className="bg-[var(--color-canvas)] py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="mx-auto max-w-2xl text-center">
            <h2 className="font-manrope text-3xl font-bold tracking-tight text-gray-900 md:text-4xl">
              Empowering patients with their own health data.
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              A unified platform bridging the gap between clinical settings and daily patient lives, prioritizing transparency and offline reliability.
            </p>
          </div>

          <div className="mt-16 grid gap-8 md:grid-cols-3">
            {[
              {
                icon: User,
                title: "Patient-Centered",
                desc: "Take charge of your daily vitals and medication schedules with intuitive tracking tools designed for your lifestyle.",
              },
              {
                icon: Stethoscope,
                title: "Doctor-Anchored",
                desc: "View verified clinical encounters and prescriptions exactly as recorded by your healthcare providers.",
              },
              {
                icon: WifiOff,
                title: "Offline-First",
                desc: "Log vitals and check reminders even without connectivity. Data syncs seamlessly when you're back online.",
              }
            ].map((feature, i) => (
              <div key={i} className="rounded-2xl border border-[var(--color-main-border)] bg-white/80 backdrop-blur-sm p-8 shadow-sm transition-all hover:shadow-md hover:-translate-y-1">
                <div className="mb-6 inline-flex h-12 w-12 items-center justify-center rounded-xl bg-[var(--color-main-light)] text-[var(--color-main)]">
                  <feature.icon className="h-6 w-6" />
                </div>
                <h3 className="font-manrope text-xl font-semibold text-gray-900">{feature.title}</h3>
                <p className="mt-3 text-base leading-relaxed text-gray-600">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ADVANCED CLINICAL TOOLS */}
      <section className="bg-[var(--color-canvas)] py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="text-center">
            <span className="font-manrope text-sm font-semibold uppercase tracking-widest text-[var(--color-main)]">Features</span>
            <h2 className="mt-4 font-manrope text-3xl font-bold tracking-tight text-gray-900 md:text-4xl">
              Advanced Clinical Tools for a Seamless Journey
            </h2>
          </div>

          <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {[
              {
                icon: FileCheck,
                title: "Medication Adherence",
                desc: "Smart reminders with bounded snoozing to ensure you never miss a dose, reducing clinical risk."
              },
              {
                icon: Activity,
                title: "Vital Self Logging",
                desc: "Capture your daily vitals offline. Hands sync them seamlessly for your doctor's review during your next visit."
              },
              {
                icon: FileText,
                title: "Clinical Encounters",
                desc: "Access your complete medical history organized as verified clinic visits, providing total transparency."
              },
              {
                icon: Calendar,
                title: "Appointments",
                desc: "Track upcoming visits with local device reminders, keeping your schedule organized and accessible."
              }
            ].map((tool, i) => (
              <div key={i} className="rounded-2xl border border-[var(--color-main-border)] bg-[var(--color-main-subtle)] p-6 shadow-sm transition-shadow hover:shadow-md">
                <div className="mb-5 inline-flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--color-main-light)] text-[var(--color-main-dark)]">
                  <tool.icon className="h-5 w-5" />
                </div>
                <h3 className="font-manrope text-lg font-semibold text-gray-900">{tool.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-gray-600">{tool.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* HOW IT WORKS / PROCESS */}
      <section className="bg-white py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
            {/* Left Image Collage */}
            <div className="relative grid grid-cols-2 gap-4 rounded-3xl bg-[var(--color-main-subtle)] p-4 border border-[var(--color-main-border)]">
              <img
                src="https://images.unsplash.com/photo-1511174511562-58f115a4ce36?auto=format&fit=crop&q=80&w=600"
                alt="App on phone"
                className="col-span-1 row-span-2 h-full w-full rounded-2xl object-cover shadow-sm"
              />
              <img
                src="https://images.unsplash.com/photo-1579684385127-1ef15d508118?auto=format&fit=crop&q=80&w=600"
                alt="Clinic reception"
                className="col-span-1 h-48 w-full rounded-2xl object-cover shadow-sm"
              />
              <img
                src="https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=80&w=600"
                alt="Doctor consultation"
                className="col-span-1 h-48 w-full rounded-2xl object-cover shadow-sm"
              />
            </div>

            {/* Right Content */}
            <div>
              <span className="font-manrope text-sm font-semibold uppercase tracking-widest text-[var(--color-main)]">Process</span>
              <h2 className="mt-4 font-manrope text-3xl font-bold tracking-tight text-gray-900 md:text-4xl">
                Getting started is simple.
              </h2>
              <p className="mt-4 text-lg text-gray-600">
                Join a secure ecosystem designed to give you ownership of your health records.
              </p>

              <div className="mt-10 space-y-8">
                {[
                  {
                    num: "1",
                    title: "Self-Register Account",
                    desc: "Create your secure profile in minutes through our intuitive onboarding process."
                  },
                  {
                    num: "2",
                    title: "Approve Clinic Access",
                    desc: "Verify your identity in person at partner clinics to establish a secure data link."
                  },
                  {
                    num: "3",
                    title: "Manage Your Health",
                    desc: "Track vitals, manage prescriptions, and review encounter histories all in one place."
                  }
                ].map((step, i) => (
                  <div key={i} className="flex gap-4">
                    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border-2 border-[var(--color-main)] bg-[var(--color-main-subtle)] font-manrope text-lg font-bold text-[var(--color-main)] shadow-sm">
                      {step.num}
                    </div>
                    <div>
                      <h3 className="font-manrope text-xl font-semibold text-gray-900">{step.title}</h3>
                      <p className="mt-1 text-gray-600">{step.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* SECURITY & PRIVACY */}
      <section className="bg-[var(--color-main)] py-24 text-white">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="grid gap-16 lg:grid-cols-2 lg:items-center">

            <div className="max-w-xl">
              <h2 className="font-manrope text-3xl font-bold tracking-tight md:text-4xl lg:text-5xl text-white">
                Uncompromising Security & Privacy
              </h2>
              <p className="mt-6 text-lg text-[var(--color-main-light)]">
                Your health data belongs to you. Our platform architecture ensures that you maintain absolute control over who accesses your clinical records.
              </p>

              <div className="mt-10 rounded-2xl border border-white/20 bg-[var(--color-main-dark)] p-6 shadow-md backdrop-blur-sm">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[var(--color-main)] border border-white/20">
                    <ShieldAlert className="h-5 w-5 text-white" />
                  </div>
                  <h3 className="font-manrope text-lg font-bold text-white">5-Minute Access Window</h3>
                </div>
                <p className="mt-4 text-[15px] leading-relaxed text-[var(--color-main-light)]">
                  When a clinic requests your records, you receive a temporal alert. You have exactly 5 minutes to approve or deny the request, ensuring in-the-moment consent.
                </p>
              </div>
            </div>

            <div className="flex justify-center lg:justify-end">
              <div className="relative flex h-64 w-64 items-center justify-center rounded-full border-[1px] border-dashed border-[var(--color-main-border)] lg:h-80 lg:w-80 opacity-80">
                <div className="flex h-48 w-48 items-center justify-center rounded-full border border-[var(--color-main-light)] lg:h-64 lg:w-64">
                  <div className="flex h-32 w-32 items-center justify-center rounded-full bg-[var(--color-main-dark)] shadow-2xl lg:h-40 lg:w-40 border border-white/10">
                    <Lock className="h-10 w-10 text-[var(--color-main-light)] lg:h-12 lg:w-12" strokeWidth={1.5} />
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* CTA SECTION */}
      <section className="bg-[var(--color-canvas)] py-24 border-t border-[var(--color-main-border)]">
        <div className="mx-auto max-w-3xl px-6 text-center md:px-10">
          <h2 className="font-manrope text-3xl font-bold tracking-tight text-gray-900 md:text-4xl">
            Ready to experience clinical calm?
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Join thousands of patients taking control of their healthcare journey today.
          </p>
          <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
            <a href="/signup" className="inline-flex items-center justify-center rounded-lg bg-[var(--color-main)] px-8 py-4 font-manrope text-base font-semibold text-white shadow-sm transition-colors hover:bg-[var(--color-main-hover)]">
              Create Free Account
            </a>
            <a href="#download" className="inline-flex items-center justify-center gap-2 rounded-lg border-2 border-[var(--color-main)] bg-transparent px-8 py-4 font-manrope text-base font-semibold text-[var(--color-main)] shadow-sm transition-colors hover:bg-[var(--color-main-subtle)]">
              <Download className="h-5 w-5" />
              Download App
            </a>
          </div>
        </div>
      </section>

      <LandingFooter />
    </div>
  );
}
