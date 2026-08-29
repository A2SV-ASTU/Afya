import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";

export default function AboutUsPage() {
  return (
    <div className="min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]">
      <LandingNavbar />

      <main className="py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="text-center max-w-3xl mx-auto">
            <span className="font-manrope text-sm font-semibold uppercase tracking-widest text-[var(--color-main)]">Our Mission</span>
            <h1 className="mt-4 font-manrope text-4xl font-bold tracking-tight text-gray-900 md:text-5xl">
              An AI For Healing Project
            </h1>
            <p className="mt-6 text-lg text-gray-600">
              AfyaMind is transforming healthcare transparency through AI-driven record accessibility and patient-centric design. We believe that your health data belongs to you, and we are building the infrastructure to make that a reality.
            </p>
          </div>

          <div className="mt-16 relative h-[400px] lg:h-[500px] overflow-hidden rounded-3xl shadow-lg border border-[var(--color-main-border)]">
            <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&q=80&w=1200" alt="Healthcare professionals collaborating" className="h-full w-full object-cover" />
          </div>

          <div className="mt-24 grid gap-12 lg:grid-cols-3">
             <div className="rounded-2xl border border-[var(--color-main-border)] bg-white/80 p-8 shadow-sm">
                <h3 className="font-manrope text-2xl font-bold text-gray-900">Transparency</h3>
                <p className="mt-4 text-gray-600 leading-relaxed">
                  We demystify clinical encounters by giving patients direct, readable access to their own medical histories and prescriptions.
                </p>
             </div>
             <div className="rounded-2xl border border-[var(--color-main-border)] bg-[var(--color-main)] text-white p-8 shadow-md">
                <h3 className="font-manrope text-2xl font-bold">Security</h3>
                <p className="mt-4 text-[var(--color-main-light)] leading-relaxed">
                  With our temporal consent model, data only flows when you explicitly authorize it, guaranteeing absolute privacy.
                </p>
             </div>
             <div className="rounded-2xl border border-[var(--color-main-border)] bg-white/80 p-8 shadow-sm">
                <h3 className="font-manrope text-2xl font-bold text-gray-900">Empowerment</h3>
                <p className="mt-4 text-gray-600 leading-relaxed">
                  By providing tools for medication adherence and offline vital tracking, we empower individuals to take charge of their health.
                </p>
             </div>
          </div>
        </div>
      </main>

      <LandingFooter />
    </div>
  );
}
