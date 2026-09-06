import { ShieldCheck, Download, Activity } from "lucide-react";

export function HomeHeroSection() {
  return (
    <section className="relative overflow-hidden bg-[var(--color-canvas)]">
      {/* Background Image / Overlay - Semi-transparent, blended */}
      <div className="absolute inset-0 z-0">
        <img
          src="https://images.unsplash.com/photo-1584982751601-97dcc096659c?auto=format&fit=crop&q=80&w=2000"
          alt="Secure clinical workspace"
          className="h-full w-full object-cover opacity-60 mix-blend-multiply"
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
  );
}
