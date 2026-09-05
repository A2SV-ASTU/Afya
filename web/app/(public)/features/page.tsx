import { ShieldCheck } from "lucide-react";
import { FeatureBentoGrid } from "@/components/sections/FeatureBentoGrid";

export default function FeaturesPage() {
  return (
    <main className="flex-grow pt-24 pb-16">
      {/* Hero Section */}
      <section className="pb-16 px-6 md:px-10 max-w-7xl mx-auto text-center">
        <div className="inline-flex items-center gap-2 px-5 py-2 rounded-full bg-[var(--color-main-subtle)] border border-[var(--color-main-border)] text-[var(--color-main)] font-semibold text-sm mb-8 shadow-sm">
          <ShieldCheck className="w-4 h-4" />
          Comprehensive Care Features
        </div>
        <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[var(--color-main-dark)] mb-6 max-w-4xl mx-auto leading-tight tracking-tight">
          Advanced Clinical Tools for a Seamless Health Journey
        </h1>
        <p className="text-lg md:text-xl text-gray-600 max-w-3xl mx-auto mb-10 leading-relaxed">
          Discover how AfyaMind integrates medical history, vital monitoring, and medication management into a secure, highly intuitive platform designed to empower your wellness.
        </p>
      </section>

      <FeatureBentoGrid />

    </main>
  );
}
