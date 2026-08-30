import Image from "next/image";
import { Network, HeartHandshake } from "lucide-react";
import { TeamRoster } from "@/components/sections/TeamRoster";
import { SecurityCards } from "@/components/sections/SecurityCards";

export default function AboutPage() {
  return (
    <main className="flex-grow pt-24 pb-16">
      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-6 md:px-10 pb-16">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
          <div className="flex flex-col gap-6">
            <span className="text-[var(--color-main)] font-semibold text-sm uppercase tracking-widest bg-[var(--color-main-subtle)] px-4 py-1.5 rounded-full inline-flex w-fit border border-[var(--color-main-border)] shadow-sm">
              Our Mission
            </span>
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-gray-900 tracking-tight leading-tight">
              Empowering patients with their own health data.
            </h1>
            <p className="text-lg text-gray-600 max-w-lg leading-relaxed mt-2">
              AfyaMind believes that true wellness begins with understanding. We are building a secure, intuitive platform that puts you at the center of your healthcare journey, ensuring your data is always in your hands.
            </p>
          </div>

          <div className="relative h-[450px] lg:h-[550px] rounded-[2rem] w-full overflow-hidden shadow-2xl border border-[var(--color-main-border)]/50 group">
            <div className="absolute inset-0 bg-[var(--color-main)]/10 z-10 group-hover:bg-transparent transition-colors duration-500"></div>
            <Image
              src="https://images.unsplash.com/photo-1551076805-e1869033e561?auto=format&fit=crop&q=80&w=1200"
              alt="Modern, collaborative clinical healthcare team in a premium workspace"
              fill
              className="w-full h-full object-cover transform scale-105 group-hover:scale-100 transition-transform duration-700 ease-in-out rounded-2xl"
              sizes="(max-width: 1024px) 100vw, 50vw"
              priority
            />
          </div>
        </div>
      </section>

      {/* Vision Section */}
      <section className="mt-12 bg-white/40 backdrop-blur-3xl py-16 border-y border-[var(--color-main-light)]">
        <div className="max-w-7xl mx-auto px-6 md:px-10">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4 tracking-tight">Our Vision for Care</h2>
            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
              Moving away from fragmented records to a unified, patient-centered reality.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Large Card */}
            <div className="md:col-span-2 bg-gradient-to-br from-white to-[var(--color-main-subtle)] rounded-[2rem] p-10 shadow-xl shadow-[var(--color-main-dark)]/5 border border-[var(--color-main-border)] flex flex-col justify-between min-h-[320px] transition-transform hover:-translate-y-1">
              <div>
                <div className="w-14 h-14 bg-[var(--color-main)] text-white rounded-2xl flex items-center justify-center mb-6 shadow-md">
                  <Network className="w-7 h-7" />
                </div>
                <h3 className="text-2xl font-bold text-gray-900 mb-4">Holistic Connectivity</h3>
                <p className="text-gray-600 text-lg leading-relaxed max-w-2xl">
                  We envision a world where your medical history, wearable data, and treatment plans converse seamlessly. By connecting disparate data silos, we illuminate the complete picture of your health, enabling proactive rather than reactive care.
                </p>
              </div>
            </div>

            {/* Small Card */}
            <div className="bg-[var(--color-main)] rounded-[2rem] p-10 shadow-xl shadow-[var(--color-main-dark)]/20 border border-[var(--color-main-hover)] flex flex-col justify-between min-h-[320px] text-white transition-transform hover:-translate-y-1">
              <div>
                <div className="w-14 h-14 bg-white/20 backdrop-blur-sm rounded-2xl flex items-center justify-center mb-6">
                  <HeartHandshake className="w-7 h-7 text-white" />
                </div>
                <h3 className="text-2xl font-bold mb-4">Human-Centric</h3>
                <p className="text-[var(--color-main-light)] text-lg leading-relaxed">
                  Healthcare should not feel like an administrative burden. Our design philosophy prioritizes clinical calm and profound approachability.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <SecurityCards />
      <TeamRoster />
    </main>
  );
}
