import Image from "next/image";

export function TeamRoster() {
  return (
    <section className="bg-[var(--color-canvas)] py-16 border-t border-[var(--color-main-border)]">
      <div className="mx-auto max-w-[1280px] px-6 md:px-10">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4 tracking-tight">Meet Our Team</h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            A multidisciplinary group of clinicians, cryptographers, and designers dedicated to transforming healthcare.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-10 text-center">
          {[
            { name: "Dr. Elena Rostova", role: "Chief Medical Officer", img: "1559839734-2b71ea197ec2" },
            { name: "Marcus Chen", role: "Head of Engineering", img: "1506794778202-cad84cf45f1d" },
            { name: "Sarah Jenkins", role: "Lead Product Designer", img: "1573496359142-b8d87734a5a2" },
            { name: "David Okafor", role: "Chief Privacy Officer", img: "1537368910025-7001c08cb36a" }
          ].map((member, i) => (
            <div key={i} className="flex flex-col items-center group">
              <div className="relative w-40 h-40 rounded-[2rem] overflow-hidden mb-6 shadow-xl shadow-[var(--color-main-dark)]/10 border border-[var(--color-main-border)] bg-white transform transition-transform duration-300 group-hover:-translate-y-2 group-hover:rotate-1">
                <Image
                  src={`https://images.unsplash.com/photo-${member.img}?auto=format&fit=crop&q=80&w=400`}
                  alt={member.name}
                  fill
                  className="object-cover"
                  sizes="160px"
                />
              </div>
              <h4 className="text-xl font-bold text-gray-900">{member.name}</h4>
              <p className="text-[var(--color-main)] font-medium mt-1">{member.role}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
