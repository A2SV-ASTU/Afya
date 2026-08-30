import {
  Activity, Calendar, FileText, Lock, Shield,
  Stethoscope, User, ShieldCheck, WifiOff, FileCheck, ShieldAlert, Download
} from "lucide-react";
import { HomeHeroSection } from "@/components/sections/HomeHeroSection";

export default function LandingPage() {
  return (
    <>
      <HomeHeroSection />

      {/* CORE FEATURES (TOP) */}
      <section className="bg-[var(--color-canvas)] py-16">
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
      <section className="bg-[var(--color-canvas)] py-16">
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
      <section className="bg-white py-16">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
            {/* Left Image Collage */}
            <div className="relative grid grid-cols-2 gap-4 rounded-3xl bg-[var(--color-main-subtle)] p-4 border border-[var(--color-main-border)]">
              <img
                src="https://images.unsplash.com/photo-1526628953301-3e589a6a8b74?auto=format&fit=crop&w=800&q=80"
                alt="Patient holding smartphone"
                className="col-span-1 row-span-2 h-full w-full rounded-2xl object-cover shadow-sm"
              />
              <img
                src="https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=800&q=80"
                alt="Digital health data and modern medical interface"
                className="col-span-1 h-48 w-full rounded-2xl object-cover shadow-sm"
              />
              <img
                src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=800&q=80"
                alt="Doctor and patient collaborating in a modern clinic"
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
      <section className="bg-[var(--color-main)] py-16 text-white">
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
      <section className="bg-[var(--color-canvas)] py-16 border-t border-[var(--color-main-border)]">
        <div className="mx-auto max-w-3xl px-6 text-center md:px-10">
          <h2 className="font-manrope text-3xl font-bold tracking-tight text-gray-900 md:text-4xl">
            Ready to experience clinical calm?
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Join thousands of patients taking control of their healthcare journey today.
          </p>
          <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
            <a href="#download" className="inline-flex items-center justify-center gap-2 rounded-lg border-2 border-[var(--color-main)] bg-transparent px-8 py-4 font-manrope text-base font-semibold text-[var(--color-main)] shadow-sm transition-colors hover:bg-[var(--color-main-subtle)]">
              <Download className="h-5 w-5" />
              Download App
            </a>
          </div>
        </div>
      </section>
    </>
  );
}
