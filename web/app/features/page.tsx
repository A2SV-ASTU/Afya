import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";
import { User, Stethoscope, WifiOff, FileCheck, Activity, Calendar } from "lucide-react";

export default function FeaturesPage() {
  return (
    <div className="min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]">
      <LandingNavbar />

      <main className="py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="grid gap-12 lg:grid-cols-2 lg:items-center">
            <div>
              <h1 className="font-manrope text-4xl font-bold tracking-tight text-gray-900 md:text-5xl">
                Comprehensive Features
              </h1>
              <p className="mt-6 text-lg text-gray-600">
                Explore the tools designed to empower you on your healthcare journey. Our unified platform bridges the gap between clinical settings and daily patient lives.
              </p>
            </div>
            <div className="relative h-64 overflow-hidden rounded-3xl shadow-md lg:h-96 border border-[var(--color-main-border)]">
              <img src="https://images.unsplash.com/photo-1576091160399-11cb9ed20fab?auto=format&fit=crop&q=80&w=1200" alt="Features overview" className="h-full w-full object-cover" />
            </div>
          </div>

          <div className="mt-24 grid gap-8 md:grid-cols-2 lg:grid-cols-3">
             {[
              { icon: User, title: "Patient-Centered", desc: "Take charge of your daily vitals and medication schedules with intuitive tracking tools designed for your lifestyle." },
              { icon: Stethoscope, title: "Doctor-Anchored", desc: "View verified clinical encounters and prescriptions exactly as recorded by your healthcare providers." },
              { icon: WifiOff, title: "Offline-First", desc: "Log vitals and check reminders even without connectivity. Data syncs seamlessly when you're back online." },
              { icon: FileCheck, title: "Medication Adherence", desc: "Smart reminders with bounded snoozing to ensure you never miss a dose, reducing clinical risk." },
              { icon: Activity, title: "Vital Self Logging", desc: "Capture your daily vitals offline. Hands sync them seamlessly for your doctor's review during your next visit." },
              { icon: Calendar, title: "Appointments", desc: "Track upcoming visits with local device reminders, keeping your schedule organized and accessible." }
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
      </main>

      <LandingFooter />
    </div>
  );
}
