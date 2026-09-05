import Image from "next/image";
import { Activity, BellRing, Link as LinkIcon, Stethoscope, ChevronRight } from "lucide-react";

export default function HowItWorksPage() {
  return (
    <main className="flex-grow pt-24 pb-16">
      {/* Hero Section */}
      <section className="relative overflow-hidden pb-16 border-b border-[var(--color-main-border)] bg-white/40 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-6 md:px-10">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
            <div className="relative z-10 flex flex-col gap-6 max-w-xl">
              <span className="text-[var(--color-main)] font-semibold text-sm uppercase tracking-widest bg-[var(--color-main-subtle)] px-4 py-1.5 rounded-full inline-flex w-fit border border-[var(--color-main-border)] shadow-sm">
                Our Methodology
              </span>
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[var(--color-main-dark)] tracking-tight leading-tight">
                A Seamless Clinical Workflow.
              </h1>
              <p className="text-lg text-gray-600 leading-relaxed">
                AfyaMind reimagines the patient journey by connecting the moments between clinic visits. Our PRD v2.0 workflow guarantees data integrity while giving you absolute control.
              </p>
              <div className="mt-4">
                <a href="#timeline" className="inline-flex items-center gap-2 bg-[var(--color-main)] text-white font-semibold px-6 py-3 rounded-full hover:bg-[var(--color-main-hover)] transition-colors shadow-md hover:shadow-lg">
                  Explore the Workflow <ChevronRight className="w-5 h-5" />
                </a>
              </div>
            </div>

            <div className="relative z-10">
              <div className="relative h-[450px] w-full rounded-[2rem] overflow-hidden shadow-2xl shadow-[var(--color-main-dark)]/10 border border-[var(--color-main-border)]/50 group">
                <div className="absolute inset-0 bg-gradient-to-tr from-[var(--color-main)]/20 to-transparent z-10 mix-blend-overlay"></div>
                <Image
                  src="/images/fa65dc6c2f658be30b403f01da977966.jpg"
                  alt="Patient looking at mobile health app"
                  fill
                  className="w-full h-full object-cover rounded-2xl transform scale-105 group-hover:scale-100 transition-transform duration-700 ease-in-out"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Interactive Step-by-Step Timeline Section */}
      <section id="timeline" className="py-16 max-w-7xl mx-auto px-6 md:px-10">
        <div className="text-center mb-20">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4 tracking-tight">The AfyaMind Care Journey</h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            How data securely flows from your doctor&apos;s office, into your daily life, and back again.
          </p>
        </div>

        <div className="relative max-w-5xl mx-auto">
          <div className="hidden md:block absolute left-1/2 top-10 bottom-10 w-0.5 bg-gradient-to-b from-[var(--color-main)] via-[var(--color-main-light)] to-transparent -translate-x-1/2 rounded-full"></div>

          <div className="space-y-24">

            {/* Step 1 */}
            <div className="relative flex flex-col md:flex-row items-center justify-between group">
              <div className="md:w-5/12 flex justify-end md:pr-10 mb-8 md:mb-0">
                <div className="relative w-full h-[300px] rounded-[2rem] overflow-hidden shadow-xl shadow-[var(--color-main-dark)]/10 border border-[var(--color-main-border)] group-hover:-translate-y-2 transition-transform duration-300">
                  <Image src="https://images.unsplash.com/photo-1631549916768-4119b2e5f926?auto=format&fit=crop&q=80&w=800" alt="Doctor capturing vitals" fill className="w-full h-full object-cover rounded-2xl" />
                </div>
              </div>

              <div className="absolute left-1/2 -translate-x-1/2 w-14 h-14 bg-white border-4 border-[var(--color-main)] rounded-full hidden md:flex items-center justify-center shadow-lg z-10 text-[var(--color-main)] font-bold text-xl">
                1
              </div>

              <div className="md:w-5/12 md:pl-10">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--color-main-subtle)] text-[var(--color-main)] mb-6 border border-[var(--color-main-border)]">
                  <Stethoscope className="w-6 h-6" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">The Encounter</h3>
                <p className="text-lg text-gray-600 leading-relaxed bg-white/60 p-6 rounded-2xl backdrop-blur-md border border-white shadow-sm">
                  Doctors open an encounter during your visit. Instead of scattered files, vitals, lab orders, diagnoses, and prescriptions are captured as a single, immutable unit of care, instantly mirrored to your personal device.
                </p>
              </div>
            </div>

            {/* Step 2 */}
            <div className="relative flex flex-col md:flex-row-reverse items-center justify-between group">
              <div className="md:w-5/12 flex justify-start md:pl-10 mb-8 md:mb-0">
                <div className="relative w-full h-[300px] rounded-[2rem] overflow-hidden shadow-xl shadow-[var(--color-main-dark)]/10 border border-[var(--color-main-border)] group-hover:-translate-y-2 transition-transform duration-300">
                  <Image src="/images/how-it-works-tracking.jpg" alt="Patient tracking on mobile dashboard" fill className="w-full h-full object-cover rounded-2xl" />
                </div>
              </div>

              <div className="absolute left-1/2 -translate-x-1/2 w-14 h-14 bg-white border-4 border-[var(--color-main)] rounded-full hidden md:flex items-center justify-center shadow-lg z-10 text-[var(--color-main)] font-bold text-xl">
                2
              </div>

              <div className="md:w-5/12 md:pr-10 text-left md:text-right flex flex-col md:items-end">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--color-main-subtle)] text-[var(--color-main)] mb-6 border border-[var(--color-main-border)]">
                  <BellRing className="w-6 h-6" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Self-Tracking &amp; Reminders</h3>
                <p className="text-lg text-gray-600 leading-relaxed bg-white/60 p-6 rounded-2xl backdrop-blur-md border border-white shadow-sm text-left md:text-right">
                  You log against the doctor-set plan via secure mobile push notifications. Our intelligent adherence system features a strict <strong>10-minute bounded snooze</strong>, ensuring critical clinical windows are never missed.
                </p>
              </div>
            </div>

            {/* Step 3 */}
            <div className="relative flex flex-col md:flex-row items-center justify-between group">
              <div className="md:w-5/12 flex justify-end md:pr-10 mb-8 md:mb-0">
                <div className="relative w-full h-[300px] rounded-[2rem] overflow-hidden shadow-xl shadow-[var(--color-main-dark)]/10 border border-[var(--color-main-border)] group-hover:-translate-y-2 transition-transform duration-300">
                  <Image src="https://i.pinimg.com/1200x/7f/83/48/7f8348797471579c55e8818ae5c32f5e.jpg" alt="Medical professionals securely collaborating and reviewing digital health records." fill className="w-full h-full object-cover rounded-2xl" />
                </div>
              </div>

              <div className="absolute left-1/2 -translate-x-1/2 w-14 h-14 bg-[var(--color-main)] border-4 border-white rounded-full hidden md:flex items-center justify-center shadow-lg z-10 text-white font-bold text-xl">
                3
              </div>

              <div className="md:w-5/12 md:pl-10">
                <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-[var(--color-main-subtle)] text-[var(--color-main)] mb-6 border border-[var(--color-main-border)]">
                  <LinkIcon className="w-6 h-6" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Secure Cross-Clinic Sharing</h3>
                <p className="text-lg text-gray-600 leading-relaxed bg-white/60 p-6 rounded-2xl backdrop-blur-md border border-white shadow-sm">
                  When physically at a new clinic, the institution requests read access. You receive a prompt with a strict <strong>5-minute access request window</strong>. Upon your approval, the new doctor receives immediate, fully-audited read access to your comprehensive history.
                </p>
              </div>
            </div>

          </div>
        </div>
      </section>

    </main>
  );
}
