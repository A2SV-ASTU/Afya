import Image from "next/image";
import { ShieldCheck, Pill, Activity, History, LockKeyhole } from "lucide-react";

export function FeatureBentoGrid() {
  return (
    <section className="py-10 px-6 md:px-10 max-w-7xl mx-auto">
      <div className="grid grid-cols-1 md:grid-cols-12 gap-6">

        {/* Feature 1: Medication Management (Large Card - 8 cols) */}
        <div className="md:col-span-8 bg-white rounded-[2rem] shadow-xl shadow-[var(--color-main-dark)]/5 border border-[var(--color-main-border)] overflow-hidden group flex flex-col md:flex-row transition-all hover:shadow-2xl hover:-translate-y-1">
          <div className="p-10 flex-1 flex flex-col justify-center">
            <div className="w-14 h-14 bg-[var(--color-main-subtle)] text-[var(--color-main)] rounded-2xl flex items-center justify-center mb-6 border border-[var(--color-main-border)]">
              <Pill className="w-7 h-7" />
            </div>
            <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-4 tracking-tight">Medication Management</h3>
            <p className="text-gray-600 text-lg leading-relaxed mb-6">
              Never miss a dose. Our intelligent reminder system tracks your adherence, alerts you to potential interactions, and securely logs your daily intake history for physician review.
            </p>
            <ul className="space-y-3">
              <li className="flex items-center gap-3 text-gray-800 font-medium">
                <ShieldCheck className="text-[var(--color-main)] w-5 h-5" /> Smart timing reminders
              </li>
              <li className="flex items-center gap-3 text-gray-800 font-medium">
                <ShieldCheck className="text-[var(--color-main)] w-5 h-5" /> Adherence tracking dashboards
              </li>
            </ul>
          </div>
          <div className="relative md:w-2/5 min-h-[250px] bg-[var(--color-main-light)] overflow-hidden">
            <Image
              src="https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&q=80&w=800"
              alt="Medication and digital tracking"
              fill
              className="object-cover group-hover:scale-105 transition-transform duration-700"
            />
          </div>
        </div>

        {/* Feature 2: Vital Signs (Square Card - 4 cols) */}
        <div className="md:col-span-4 bg-[var(--color-main)] text-white rounded-[2rem] shadow-xl shadow-[var(--color-main-dark)]/20 border border-[var(--color-main-hover)] overflow-hidden relative group transition-all hover:shadow-2xl hover:-translate-y-1">
          <div className="absolute inset-0 opacity-20">
            <Image
              src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&q=80&w=800"
              alt="Data charts graphic"
              fill
              className="object-cover group-hover:scale-110 transition-transform duration-1000 mix-blend-overlay"
            />
          </div>
          <div className="relative z-10 p-10 flex flex-col h-full">
            <div className="w-14 h-14 bg-white/20 backdrop-blur-md rounded-2xl flex items-center justify-center mb-6 border border-white/10">
              <Activity className="w-7 h-7 text-white" />
            </div>
            <h3 className="text-2xl font-bold mb-4 tracking-tight">Vital Signs Monitoring</h3>
            <p className="text-[var(--color-main-light)] text-lg leading-relaxed mb-6">
              Log Blood Pressure, SpO2, and Heart Rate. View intuitive charts that highlight trends and anomalies over time.
            </p>
          </div>
        </div>

        {/* Feature 3: Medical History (Square Card - 5 cols) */}
        <div className="md:col-span-5 bg-white rounded-[2rem] shadow-xl shadow-[var(--color-main-dark)]/5 border border-[var(--color-main-border)] overflow-hidden group transition-all hover:shadow-2xl hover:-translate-y-1 flex flex-col">
          <div className="relative h-48 bg-gray-100 overflow-hidden">
            <Image
              src="https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=80&w=800"
              alt="Doctor reviewing digital charts"
              fill
              className="object-cover group-hover:scale-105 transition-transform duration-700"
            />
          </div>
          <div className="p-8 flex-1">
            <div className="w-12 h-12 bg-[var(--color-main-subtle)] text-[var(--color-main)] rounded-xl flex items-center justify-center mb-6 border border-[var(--color-main-border)] -mt-14 relative z-10 shadow-sm">
              <History className="w-6 h-6" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-3 tracking-tight">Unified Medical History</h3>
            <p className="text-gray-600 leading-relaxed">
              A comprehensive timeline of your past visits, laboratory results, and clinical notes, ensuring true continuity of care wherever you go.
            </p>
          </div>
        </div>

        {/* Feature 4: Clinic Access (Wide Card - 7 cols) */}
        <div className="md:col-span-7 bg-white rounded-[2rem] shadow-xl shadow-[var(--color-main-dark)]/5 border border-[var(--color-main-border)] overflow-hidden group flex flex-col sm:flex-row transition-all hover:shadow-2xl hover:-translate-y-1">
          <div className="p-10 flex-1 flex flex-col justify-center">
            <div className="w-14 h-14 bg-[var(--color-main-subtle)] text-[var(--color-main)] rounded-2xl flex items-center justify-center mb-6 border border-[var(--color-main-border)]">
              <LockKeyhole className="w-7 h-7" />
            </div>
            <h3 className="text-2xl lg:text-3xl font-bold text-gray-900 mb-4 tracking-tight">Secure Clinic Access</h3>
            <p className="text-gray-600 text-lg leading-relaxed mb-8">
              Granular consent management puts you in control. Securely grant or revoke access to your health records for specific providers or clinics with robust end-to-end encryption.
            </p>
            <button className="self-start text-[var(--color-main)] font-semibold border-2 border-[var(--color-main)] px-6 py-2.5 rounded-full hover:bg-[var(--color-main)] hover:text-white transition-colors">
              Learn about security
            </button>
          </div>
          <div className="relative sm:w-2/5 min-h-[250px] bg-gray-100 overflow-hidden">
            <Image
              src="https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&q=80&w=800"
              alt="Security and data lock graphic"
              fill
              className="object-cover group-hover:scale-105 transition-transform duration-700"
            />
            <div className="absolute inset-0 bg-gradient-to-r from-white via-transparent to-transparent sm:block hidden"></div>
            <div className="absolute inset-0 bg-gradient-to-t from-white via-transparent to-transparent sm:hidden block"></div>
          </div>
        </div>

      </div>
    </section>
  );
}
