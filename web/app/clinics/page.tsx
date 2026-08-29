import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";
import { Lock, ShieldAlert } from "lucide-react";

export default function ClinicsPage() {
  return (
    <div className="min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]">
      <LandingNavbar />

      <main className="py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">

          <div className="grid gap-16 lg:grid-cols-2 lg:items-center">
            <div className="max-w-xl">
              <h1 className="font-manrope text-4xl font-bold tracking-tight text-gray-900 md:text-5xl">
                Partner Clinics Network
              </h1>
              <p className="mt-6 text-lg text-gray-600">
                AfyaMind partners with leading clinics to provide seamless integration of your health records. When visiting a partner clinic, you maintain absolute control over who accesses your clinical records.
              </p>

              <div className="mt-10 rounded-3xl border border-[var(--color-main-border)] bg-white/80 p-8 shadow-sm backdrop-blur-sm">
                <div className="flex items-center gap-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--color-main-subtle)] border border-[var(--color-main-border)]">
                    <ShieldAlert className="h-6 w-6 text-[var(--color-main)]" />
                  </div>
                  <h3 className="font-manrope text-xl font-bold text-gray-900">5-Minute Access Window</h3>
                </div>
                <p className="mt-4 text-[16px] leading-relaxed text-gray-600">
                  When a clinic requests your records, you receive a temporal alert on your device. You have exactly 5 minutes to approve or deny the request, ensuring in-the-moment consent before any doctor can view your history.
                </p>
              </div>
            </div>

            <div className="relative h-96 overflow-hidden rounded-3xl shadow-md border border-[var(--color-main-border)]">
              <img src="https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=1200" alt="Partner Clinic Building" className="h-full w-full object-cover" />
            </div>
          </div>

        </div>
      </main>

      <LandingFooter />
    </div>
  );
}
