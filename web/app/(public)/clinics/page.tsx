import Image from "next/image";
import { Building2, ShieldCheck, Database, FolderSync, ArrowRight, CheckCircle2, Server, LockKeyhole } from "lucide-react";

export default function ClinicsPage() {
  return (
    <main className="flex-grow pt-24 pb-16 bg-white">
      {/* B2B Hero Section */}
      <section className="relative pb-16 lg:pb-24 overflow-hidden border-b border-[var(--color-main-border)]">
        <div className="max-w-7xl mx-auto px-6 md:px-10 flex flex-col items-center text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[var(--color-main-subtle)] border border-[var(--color-main-border)] text-[var(--color-main-dark)] font-bold text-xs uppercase tracking-widest mb-8 shadow-sm">
            <Building2 className="w-4 h-4" />
            Enterprise Edition
          </div>
          <h1 className="text-4xl md:text-5xl lg:text-7xl font-extrabold text-gray-900 mb-6 tracking-tight leading-tight max-w-4xl">
            The Modern OS for <span className="text-[var(--color-main)]">Clinical Data</span>.
          </h1>
          <p className="text-lg md:text-xl text-gray-600 leading-relaxed mb-10 max-w-2xl font-medium">
            Equip your medical staff with an encounter-based, highly secure architecture that eliminates data silos and integrates seamlessly into collaborative workflows.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 mb-16">
            <a href="#demo" className="inline-flex justify-center items-center gap-2 bg-[var(--color-main-dark)] text-white font-bold px-8 py-4 rounded-xl hover:bg-[var(--color-main)] transition-colors shadow-lg hover:shadow-xl">
              Request Platform Demo <ArrowRight className="w-5 h-5" />
            </a>
          </div>

          <div className="relative w-full h-[400px] md:h-[600px] rounded-[2rem] overflow-hidden shadow-2xl border border-[var(--color-main-border)]">
             <Image
              src="https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=1600"
              alt="Hospital command center dashboard"
              fill
              className="object-cover"
              priority
            />
          </div>
        </div>
      </section>

      {/* Feature Grid: B2B Focused */}
      <section className="py-16 px-6 md:px-10 max-w-7xl mx-auto bg-white">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-extrabold text-gray-900 mb-4 tracking-tight">Engineered for Clinical Excellence</h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto font-medium">
            Built to meet the rigorous demands of multi-specialty hospitals, providing a secure, deeply integrated data ecosystem.
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">

          {/* Feature 1 */}
          <div className="flex flex-col group">
            <div className="relative h-[300px] w-full rounded-[2rem] overflow-hidden shadow-md border border-[var(--color-main-border)] mb-8">
              <Image
                src="https://images.unsplash.com/photo-1587854692152-cbe660dbde88?auto=format&fit=crop&q=80&w=1000"
                alt="Secure medical dashboard and network graphic"
                fill
                className="object-cover group-hover:scale-105 transition-transform duration-700"
              />
              <div className="absolute inset-0 bg-[var(--color-main)]/5"></div>
            </div>
            <div className="flex items-center gap-4 mb-4">
              <div className="w-12 h-12 bg-[var(--color-canvas)] text-[var(--color-main-dark)] rounded-xl flex items-center justify-center shadow-sm border border-[var(--color-main-border)]">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <h3 className="text-2xl font-extrabold text-gray-900 tracking-tight">Institutional Grants</h3>
            </div>
            <p className="text-gray-600 text-lg leading-relaxed font-medium">
              Access requests belong to the <strong>Clinic as a whole</strong>, allowing seamless, audited collaboration across all specialists without repeatedly burdening the patient for consent.
            </p>
          </div>

          {/* Feature 2 */}
          <div className="flex flex-col group">
            <div className="relative h-[300px] w-full rounded-[2rem] overflow-hidden shadow-md border border-[var(--color-main-border)] mb-8">
              <Image
                src="https://images.unsplash.com/photo-1530497610245-94d3c16cda28?auto=format&fit=crop&q=80&w=1000"
                alt="Cryptographic data lock graphic representing security"
                fill
                className="object-cover group-hover:scale-105 transition-transform duration-700"
              />
            </div>
            <div className="flex items-center gap-4 mb-4">
              <div className="w-12 h-12 bg-[var(--color-canvas)] text-[var(--color-main-dark)] rounded-xl flex items-center justify-center shadow-sm border border-[var(--color-main-border)]">
                <Database className="w-6 h-6" />
              </div>
              <h3 className="text-2xl font-extrabold text-gray-900 tracking-tight">Immutable Audit Trails</h3>
            </div>
            <p className="text-gray-600 text-lg leading-relaxed font-medium">
              We operate strictly on a <strong>Deactivation over Deletion</strong> principle. Every action is logged immutably in a cryptographic ledger, ensuring absolute medical history integrity.
            </p>
          </div>

          {/* Feature 3 */}
          <div className="flex flex-col group lg:col-span-2 mt-8">
             <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center bg-[var(--color-canvas)] rounded-[2.5rem] p-8 lg:p-12 border border-[var(--color-main-border)]">
                <div>
                  <div className="flex items-center gap-4 mb-6">
                    <div className="w-12 h-12 bg-white text-[var(--color-main-dark)] rounded-xl flex items-center justify-center shadow-sm border border-[var(--color-main-border)]">
                      <FolderSync className="w-6 h-6" />
                    </div>
                    <h3 className="text-3xl font-extrabold text-gray-900 tracking-tight">Encounter-Based Architecture</h3>
                  </div>
                  <p className="text-gray-600 text-lg leading-relaxed mb-8 font-medium">
                    Move beyond chaotic, flat lists of patient notes. Our system groups vitals, diagnoses, and prescriptions <strong>logically per visit</strong>, creating a perfectly organized, chronological narrative of patient care.
                  </p>
                  <ul className="space-y-4">
                    {[
                      "Unified vital and prescription clustering",
                      "Timeline-based clinical narrative",
                      "Seamless cross-referencing of past visits"
                    ].map((item, index) => (
                      <li key={index} className="flex items-center gap-3 text-gray-800 font-bold">
                        <CheckCircle2 className="w-6 h-6 text-[var(--color-main)]" /> {item}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="relative h-[300px] lg:h-[400px] w-full rounded-[2rem] overflow-hidden shadow-md border border-white">
                  <Image
                    src="https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80"
                    alt="Close-up of a digital medical record"
                    fill
                    className="object-cover group-hover:scale-105 transition-transform duration-700"
                  />
                </div>
             </div>
          </div>

        </div>
      </section>

      {/* CTA Section */}
      <section id="demo" className="py-16 px-6 md:px-10">
        <div className="max-w-5xl mx-auto bg-[var(--color-main-dark)] rounded-[2.5rem] p-12 md:p-20 text-center text-white shadow-2xl overflow-hidden relative">
          <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2"></div>

          <h2 className="relative z-10 text-3xl md:text-5xl font-extrabold mb-6 tracking-tight">
            Ready to modernize your clinic?
          </h2>
          <p className="relative z-10 text-[var(--color-main-light)] text-lg md:text-xl max-w-2xl mx-auto mb-10 font-medium">
            Join leading healthcare providers using AfyaMind to streamline workflows, protect patient data, and deliver superior care.
          </p>
          <div className="relative z-10 flex flex-col sm:flex-row justify-center gap-4">
            <button className="bg-[var(--color-main)] text-white font-extrabold text-lg px-8 py-4 rounded-xl hover:bg-white hover:text-[var(--color-main-dark)] transition-colors shadow-lg">
              Contact Enterprise Sales
            </button>
          </div>
        </div>
      </section>

    </main>
  );
}
