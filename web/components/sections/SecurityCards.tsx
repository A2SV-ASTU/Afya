import { Shield } from "lucide-react";

export function SecurityCards() {
  return (
    <section className="max-w-7xl mx-auto px-6 md:px-10 py-16">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

        <div className="order-2 lg:order-1 grid grid-cols-1 sm:grid-cols-2 gap-6">
          {[
            { title: "End-to-End Encryption", desc: "Your health data is encrypted before it leaves your device. Only you hold the key." },
            { title: "HIPAA Compliant", desc: "Built from the ground up to exceed enterprise healthcare security standards." },
            { title: "Zero-Knowledge", desc: "We cannot read your personal health records. Privacy is baked into our architecture." },
            { title: "Granular Control", desc: "You decide exactly which doctors or family members can view specific history." }
          ].map((item, i) => (
            <div key={i} className={`bg-white rounded-3xl p-8 shadow-xl shadow-[var(--color-main-dark)]/5 border border-[var(--color-main-border)] hover:border-[var(--color-main)] transition-colors ${i % 2 === 1 ? 'sm:mt-10' : ''}`}>
              <Shield className="w-8 h-8 text-[var(--color-main)] mb-4" />
              <h4 className="text-lg font-bold text-gray-900 mb-2">{item.title}</h4>
              <p className="text-gray-600 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>

        <div className="order-1 lg:order-2 flex flex-col gap-6 lg:pl-10">
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-gray-900 tracking-tight leading-tight">
            Uncompromising Security &amp; Privacy.
          </h2>
          <p className="text-lg text-gray-600 leading-relaxed">
            We understand that health data is the most sensitive information you possess. That&apos;s why we don&apos;t just protect it; we mathematically guarantee its privacy through advanced end-to-end encryption. Trust is the foundation of Afya.
          </p>
        </div>

      </div>
    </section>
  );
}
