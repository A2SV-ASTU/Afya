import { LandingNavbar } from "@/components/layout/LandingNavbar";
import { LandingFooter } from "@/components/layout/LandingFooter";

export default function HowItWorksPage() {
  return (
    <div className="min-h-screen bg-[var(--color-canvas)] font-jakarta text-gray-900 selection:bg-[var(--color-main-light)] selection:text-[var(--color-main-dark)]">
      <LandingNavbar />

      <main className="py-24">
        <div className="mx-auto max-w-[1280px] px-6 md:px-10">
          <div className="text-center max-w-2xl mx-auto">
            <span className="font-manrope text-sm font-semibold uppercase tracking-widest text-[var(--color-main)]">Process</span>
            <h1 className="mt-4 font-manrope text-4xl font-bold tracking-tight text-gray-900 md:text-5xl">
              Getting started is simple.
            </h1>
            <p className="mt-6 text-lg text-gray-600">
              Join a secure ecosystem designed to give you ownership of your health records. Our straightforward onboarding gets you connected to your clinical history in minutes.
            </p>
          </div>

          <div className="mt-20 grid gap-16 lg:grid-cols-2 lg:items-center">
            <div className="relative h-80 overflow-hidden rounded-3xl shadow-md lg:h-[500px] border border-[var(--color-main-border)]">
              <img src="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=1200" alt="Doctor Consultation" className="h-full w-full object-cover" />
            </div>

            <div className="space-y-10">
                {[
                  {
                    num: "1",
                    title: "Self-Register Account",
                    desc: "Create your secure profile in minutes through our intuitive onboarding process on your mobile device or web browser."
                  },
                  {
                    num: "2",
                    title: "Approve Clinic Access",
                    desc: "Verify your identity in person at partner clinics to establish a secure data link. Our 5-minute access window keeps you in control."
                  },
                  {
                    num: "3",
                    title: "Manage Your Health",
                    desc: "Track vitals, manage prescriptions, and review encounter histories all in one place. Your data remains yours."
                  }
                ].map((step, i) => (
                  <div key={i} className="flex gap-6">
                    <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full border-2 border-[var(--color-main)] bg-[var(--color-main-subtle)] font-manrope text-xl font-bold text-[var(--color-main)] shadow-sm">
                      {step.num}
                    </div>
                    <div>
                      <h3 className="font-manrope text-2xl font-semibold text-gray-900">{step.title}</h3>
                      <p className="mt-2 text-lg text-gray-600 leading-relaxed">{step.desc}</p>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        </div>
      </main>

      <LandingFooter />
    </div>
  );
}
